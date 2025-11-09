import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../domain/entities/audit_log_entity.dart';

/// Audit Log Viewer Page
/// Features:
/// - View all admin actions
/// - Filter by date, action type, entity type, performed by
/// - View before/after changes
/// - Export to CSV
/// - Search functionality
class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  List<AuditLogEntity> _logs = [];

  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedAction;
  String? _selectedEntityType;

  @override
  void initState() {
    super.initState();
    // Default: Load last 7 days
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
    _loadLogs();
  }

  void _loadLogs() {
    context.read<AdminBloc>().add(
          LoadAuditLogsRequested(
            startDate: _startDate,
            endDate: _endDate,
            action: _selectedAction,
            entityType: _selectedEntityType,
            limit: 100, // Limit to 100 most recent
          ),
        );
  }

  Future<void> _exportLogs() async {
    context.read<AdminBloc>().add(
          ExportAuditLogsRequested(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _FilterDialog(
        startDate: _startDate,
        endDate: _endDate,
        selectedAction: _selectedAction,
        selectedEntityType: _selectedEntityType,
      ),
    );

    if (result != null) {
      setState(() {
        _startDate = result['startDate'] as DateTime?;
        _endDate = result['endDate'] as DateTime?;
        _selectedAction = result['action'] as String?;
        _selectedEntityType = result['entityType'] as String?;
      });
      _loadLogs();
    }
  }

  void _showLogDetail(AuditLogEntity log) {
    showDialog(
      context: context,
      builder: (context) => _DetailDialog(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportLogs,
            tooltip: 'Export CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuditLogsExported) {
            _handleExport(state.csvContent, state.logCount);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuditLogsLoaded) {
            _logs = state.logs;
          }

          if (_logs.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildFilterSummary(),
              Expanded(child: _buildLogList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSummary() {
    final hasFilters = _selectedAction != null || _selectedEntityType != null;
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing ${_logs.length} logs',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
              if (hasFilters)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedAction = null;
                      _selectedEntityType = null;
                    });
                    _loadLogs();
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Filters'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Date Range: ${dateFormatter.format(_startDate!)} - ${dateFormatter.format(_endDate!)}',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (_selectedAction != null || _selectedEntityType != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedAction != null)
                  Chip(
                    label: Text('Action: $_selectedAction'),
                    onDeleted: () {
                      setState(() => _selectedAction = null);
                      _loadLogs();
                    },
                  ),
                if (_selectedEntityType != null)
                  Chip(
                    label: Text('Type: $_selectedEntityType'),
                    onDeleted: () {
                      setState(() => _selectedEntityType = null);
                      _loadLogs();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogList() {
    return RefreshIndicator(
      onRefresh: () async => _loadLogs(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return _buildLogCard(log);
        },
      ),
    );
  }

  Widget _buildLogCard(AuditLogEntity log) {
    final dateFormatter = DateFormat('MMM dd, HH:mm:ss');
    final hasChanges = log.hasChanges;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: hasChanges ? () => _showLogDetail(log) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Text(
                    log.actionIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.formattedAction,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormatter.format(log.timestamp),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasChanges)
                    const Icon(
                      Icons.compare_arrows,
                      color: Colors.blue,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Details
              _buildDetailRow(
                Icons.person,
                'Performed by',
                log.performedByName,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.category,
                'Entity Type',
                log.entityType,
              ),
              if (log.reason != null) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  Icons.notes,
                  'Reason',
                  log.reason!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No audit logs found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            label: const Text('Change Filters'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(String csvContent, int logCount) async {
    try {
      // Copy CSV content to clipboard
      await Clipboard.setData(ClipboardData(text: csvContent));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported $logCount logs to clipboard'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('CSV Content'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        csvContent,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Filter Dialog Widget
class _FilterDialog extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? selectedAction;
  final String? selectedEntityType;

  const _FilterDialog({
    this.startDate,
    this.endDate,
    this.selectedAction,
    this.selectedEntityType,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  String? _selectedAction;
  String? _selectedEntityType;

  final _actionTypes = [
    'user_approved',
    'user_rejected',
    'user_suspended',
    'user_activated',
    'deed_template_created',
    'deed_template_updated',
    'deed_template_deactivated',
    'system_settings_updated',
  ];

  final _entityTypes = [
    'user',
    'deed_template',
    'system_settings',
    'penalty',
    'payment',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedAction = widget.selectedAction;
    _selectedEntityType = widget.selectedEntityType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Audit Logs'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _startDate != null
                          ? DateFormat('MMM dd').format(_startDate!)
                          : 'Start Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(
                      _endDate != null
                          ? DateFormat('MMM dd').format(_endDate!)
                          : 'End Date',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Action Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedAction,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('All actions'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All actions')),
                ..._actionTypes.map((action) {
                  return DropdownMenuItem(
                    value: action,
                    child: Text(action.replaceAll('_', ' ')),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedAction = value);
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Entity Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedEntityType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('All types'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All types')),
                ..._entityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() => _selectedEntityType = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'startDate': _startDate,
              'endDate': _endDate,
              'action': _selectedAction,
              'entityType': _selectedEntityType,
            });
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

// Detail Dialog Widget
class _DetailDialog extends StatelessWidget {
  final AuditLogEntity log;

  const _DetailDialog({required this.log});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text(log.actionIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.formattedAction,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Performed by', log.performedByName),
            _buildInfoRow('Entity Type', log.entityType),
            _buildInfoRow('Entity ID', log.entityId),
            _buildInfoRow(
              'Timestamp',
              DateFormat('MMM dd, yyyy HH:mm:ss').format(log.timestamp),
            ),
            if (log.reason != null)
              _buildInfoRow('Reason', log.reason!),

            if (log.oldValue != null || log.newValue != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              if (log.oldValue != null) ...[
                const Text(
                  'Before:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatJson(log.oldValue!),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (log.newValue != null) ...[
                const Text(
                  'After:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatJson(log.newValue!),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final buffer = StringBuffer();
    json.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }
}
