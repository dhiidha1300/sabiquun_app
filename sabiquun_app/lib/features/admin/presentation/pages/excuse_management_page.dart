import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ExcuseManagementPage extends StatefulWidget {
  const ExcuseManagementPage({super.key});

  @override
  State<ExcuseManagementPage> createState() => _ExcuseManagementPageState();
}

class _ExcuseManagementPageState extends State<ExcuseManagementPage> {
  String? _selectedStatus;
  final Set<String> _selectedExcuses = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadExcuses();
  }

  void _loadExcuses() {
    context.read<AdminBloc>().add(LoadExcusesRequested(status: _selectedStatus));
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
      _selectedExcuses.clear();
      _isSelectionMode = false;
    });
    _loadExcuses();
  }

  void _toggleSelection(String excuseId) {
    setState(() {
      if (_selectedExcuses.contains(excuseId)) {
        _selectedExcuses.remove(excuseId);
      } else {
        _selectedExcuses.add(excuseId);
      }
    });
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedExcuses.clear();
      }
    });
  }

  void _bulkApprove() {
    if (_selectedExcuses.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Approve Excuses'),
        content: Text('Approve ${_selectedExcuses.length} selected excuse(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(BulkApproveExcusesRequested(
                    excuseIds: _selectedExcuses.toList(),
                    approvedBy: authState.user.id,
                  ));
              setState(() {
                _selectedExcuses.clear();
                _isSelectionMode = false;
              });
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _bulkReject() {
    if (_selectedExcuses.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Reject Excuses'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${_selectedExcuses.length} selected excuse(s)?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Why are these excuses being rejected?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              Navigator.pop(context);
              context.read<AdminBloc>().add(BulkRejectExcusesRequested(
                    excuseIds: _selectedExcuses.toList(),
                    rejectedBy: authState.user.id,
                    reason: reasonController.text.trim(),
                  ));
              setState(() {
                _selectedExcuses.clear();
                _isSelectionMode = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showExcuseDetail(Map<String, dynamic> excuse) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => _ExcuseDetailDialog(
        excuse: excuse,
        currentUserId: authState.user.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Excuse Management'),
        actions: [
          if (_isSelectionMode && _selectedExcuses.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: _bulkApprove,
              tooltip: 'Approve Selected',
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _bulkReject,
              tooltip: 'Reject Selected',
            ),
          ],
          IconButton(
            icon: Icon(_isSelectionMode ? Icons.close : Icons.checklist),
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode ? 'Exit Selection Mode' : 'Select Multiple',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExcuses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedStatus == null,
                    onSelected: (_) => _filterByStatus(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pending'),
                    selected: _selectedStatus == 'pending',
                    onSelected: (_) => _filterByStatus('pending'),
                    avatar: const Icon(Icons.pending, size: 18),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Approved'),
                    selected: _selectedStatus == 'approved',
                    onSelected: (_) => _filterByStatus('approved'),
                    avatar: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Rejected'),
                    selected: _selectedStatus == 'rejected',
                    onSelected: (_) => _filterByStatus('rejected'),
                    avatar: const Icon(Icons.cancel, size: 18, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),

          // Excuses List
          Expanded(
            child: BlocConsumer<AdminBloc, AdminState>(
              listener: (context, state) {
                if (state is ExcuseApproved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Excuse approved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is ExcuseRejected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Excuse rejected successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is BulkExcusesApproved) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.count} excuse(s) approved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is BulkExcusesRejected) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.count} excuse(s) rejected'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadExcuses,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ExcusesLoaded) {
                  final excuses = state.excuses;

                  if (excuses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No excuses found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.appliedFilter != null
                                ? 'No ${state.appliedFilter?.toLowerCase()} excuses'
                                : 'No excuses submitted yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadExcuses(),
                    child: ListView.builder(
                      itemCount: excuses.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final excuse = excuses[index] as Map<String, dynamic>;
                        final excuseId = excuse['id'] as String;
                        final isSelected = _selectedExcuses.contains(excuseId);

                        return _ExcuseCard(
                          excuse: excuse,
                          isSelectionMode: _isSelectionMode,
                          isSelected: isSelected,
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelection(excuseId);
                            } else {
                              _showExcuseDetail(excuse);
                            }
                          },
                          onLongPress: () {
                            if (!_isSelectionMode) {
                              setState(() => _isSelectionMode = true);
                              _toggleSelection(excuseId);
                            }
                          },
                        );
                      },
                    ),
                  );
                }

                return const Center(child: Text('No data loaded'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  final Map<String, dynamic> excuse;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ExcuseCard({
    required this.excuse,
    required this.isSelectionMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getExcuseTypeIcon(String type) {
    switch (type) {
      case 'sickness':
        return Icons.sick;
      case 'travel':
        return Icons.flight;
      case 'raining':
        return Icons.cloud;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = excuse['status'] as String;
    final excuseType = excuse['excuse_type'] as String;
    final userName = excuse['user_name'] as String? ?? 'Unknown User';
    final reportDate = DateTime.parse(excuse['report_date'] as String);
    final submittedAt = DateTime.parse(excuse['submitted_at'] as String);
    final description = excuse['description'] as String?;

    // Handle affected_deeds which can be either Map or List from database
    final affectedDeedsRaw = excuse['affected_deeds'];
    Map<String, dynamic> affectedDeeds = {};

    if (affectedDeedsRaw is Map<String, dynamic>) {
      affectedDeeds = affectedDeedsRaw;
    } else if (affectedDeedsRaw is Map) {
      affectedDeeds = Map<String, dynamic>.from(affectedDeedsRaw);
    } else if (affectedDeedsRaw is List) {
      // If it's a list, convert it to the expected format
      affectedDeeds = {'deed_ids': affectedDeedsRaw, 'all': false};
    }

    final affectsAll = affectedDeeds['all'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isSelectionMode)
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onTap(),
                    ),
                  Icon(
                    _getExcuseTypeIcon(excuseType),
                    color: _getStatusColor(status),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatExcuseType(excuseType)} - ${DateFormat('MMM dd, yyyy').format(reportDate)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(status)),
                    ),
                    child: Text(
                      _formatStatus(status),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (description != null && description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Submitted ${DateFormat('MMM dd, HH:mm').format(submittedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      affectsAll ? 'All Deeds' : '${(affectedDeeds['deed_ids'] as List?)?.length ?? 0} Deed(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatExcuseType(String type) {
    switch (type) {
      case 'sickness':
        return 'Sickness';
      case 'travel':
        return 'Travel';
      case 'raining':
        return 'Raining';
      default:
        return type;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

class _ExcuseDetailDialog extends StatelessWidget {
  final Map<String, dynamic> excuse;
  final String currentUserId;

  const _ExcuseDetailDialog({
    required this.excuse,
    required this.currentUserId,
  });

  void _approve(BuildContext context) {
    Navigator.pop(context);
    context.read<AdminBloc>().add(ApproveExcuseRequested(
          excuseId: excuse['id'],
          approvedBy: currentUserId,
        ));
  }

  void _reject(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Excuse'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            hintText: 'Why is this excuse being rejected?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              context.read<AdminBloc>().add(RejectExcuseRequested(
                    excuseId: excuse['id'],
                    rejectedBy: currentUserId,
                    reason: reasonController.text.trim(),
                  ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = excuse['status'] as String;
    final isPending = status == 'pending';
    final excuseType = excuse['excuse_type'] as String;
    final userName = excuse['user_name'] as String? ?? 'Unknown User';
    final reportDate = DateTime.parse(excuse['report_date'] as String);
    final submittedAt = DateTime.parse(excuse['submitted_at'] as String);
    final description = excuse['description'] as String?;
    final reviewerName = excuse['reviewer_name'] as String?;
    final reviewedAt = excuse['reviewed_at'] != null
        ? DateTime.parse(excuse['reviewed_at'] as String)
        : null;
    final rejectionReason = excuse['rejection_reason'] as String?;

    // Handle affected_deeds which can be either Map or List from database
    final affectedDeedsRaw = excuse['affected_deeds'];
    Map<String, dynamic> affectedDeeds = {};

    if (affectedDeedsRaw is Map<String, dynamic>) {
      affectedDeeds = affectedDeedsRaw;
    } else if (affectedDeedsRaw is Map) {
      affectedDeeds = Map<String, dynamic>.from(affectedDeedsRaw);
    } else if (affectedDeedsRaw is List) {
      // If it's a list, convert it to the expected format
      affectedDeeds = {'deed_ids': affectedDeedsRaw, 'all': false};
    }

    final affectsAll = affectedDeeds['all'] == true;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.info_outline),
          const SizedBox(width: 8),
          const Text('Excuse Details'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('User', userName),
            const Divider(),
            _buildInfoRow('Excuse Type', _formatExcuseType(excuseType)),
            _buildInfoRow('Report Date', DateFormat('EEEE, MMM dd, yyyy').format(reportDate)),
            _buildInfoRow('Submitted', DateFormat('MMM dd, yyyy HH:mm').format(submittedAt)),
            const Divider(),
            _buildInfoRow('Status', _formatStatus(status)),
            if (affectsAll)
              _buildInfoRow('Affected Deeds', 'All Deeds')
            else
              _buildInfoRow('Affected Deeds', '${(affectedDeeds['deed_ids'] as List?)?.length ?? 0} deed(s)'),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(description),
            ],
            if (reviewerName != null) ...[
              const Divider(),
              _buildInfoRow('Reviewed By', reviewerName),
              if (reviewedAt != null)
                _buildInfoRow('Reviewed At', DateFormat('MMM dd, yyyy HH:mm').format(reviewedAt)),
            ],
            if (rejectionReason != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Rejection Reason:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 4),
              Text(rejectionReason),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (isPending) ...[
          TextButton(
            onPressed: () => _reject(context),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () => _approve(context),
            child: const Text('Approve'),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatExcuseType(String type) {
    switch (type) {
      case 'sickness':
        return 'Sickness';
      case 'travel':
        return 'Travel';
      case 'raining':
        return 'Raining';
      default:
        return type;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
