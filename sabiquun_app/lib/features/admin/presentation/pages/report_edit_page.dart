import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../../../deeds/domain/entities/deed_report_entity.dart';
import '../../../deeds/domain/entities/deed_entry_entity.dart';

class ReportEditPage extends StatefulWidget {
  final String reportId;

  const ReportEditPage({super.key, required this.reportId});

  @override
  State<ReportEditPage> createState() => _ReportEditPageState();
}

class _ReportEditPageState extends State<ReportEditPage> {
  DeedReportEntity? _report;
  final Map<String, double> _deedValues = {};
  final Map<String, Map<String, dynamic>> _deedTemplates = {}; // id -> {name, valueType}
  final _reasonController = TextEditingController();
  bool _hasChanges = false;
  bool _templatesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeedTemplates();
    _loadReport();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadDeedTemplates() async {
    try {
      final response = await Supabase.instance.client
          .from('deed_templates')
          .select('id, deed_name, value_type')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      setState(() {
        _deedTemplates.clear();
        for (var template in response as List) {
          _deedTemplates[template['id']] = {
            'name': template['deed_name'],
            'valueType': template['value_type'],
          };
        }
        _templatesLoading = false;
      });
    } catch (e) {
      print('Error loading deed templates: $e');
      setState(() {
        _templatesLoading = false;
      });
    }
  }

  void _loadReport() {
    context.read<AdminBloc>().add(GetReportByIdRequested(reportId: widget.reportId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Report'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _showSaveConfirmation,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is ReportLoadedSuccess) {
            setState(() {
              _report = state.report as DeedReportEntity;
              _initializeDeedValues();
            });
          } else if (state is ReportUpdatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading && _report == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_report == null) {
            return const Center(child: Text('Failed to load report'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWarningBanner(),
                const SizedBox(height: 16),
                _buildReportInfo(),
                const SizedBox(height: 24),
                _buildDeedEntriesSection(),
                const SizedBox(height: 24),
                _buildSummarySection(),
                const SizedBox(height: 24),
                _buildReasonField(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Override',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Editing this report will recalculate penalties and update the user\'s balance.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              'Date',
              DateFormat('EEEE, MMM d, yyyy').format(_report!.reportDate),
            ),
            _buildInfoRow(
              'User ID',
              _report!.userId,
            ),
            _buildInfoRow(
              'Status',
              _report!.status.displayName,
            ),
            _buildInfoRow(
              'Submitted',
              _report!.submittedAt != null
                  ? DateFormat('MMM d, yyyy HH:mm').format(_report!.submittedAt!)
                  : 'Not submitted',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeedEntriesSection() {
    if (_report!.entries == null || _report!.entries!.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No deed entries found'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deed Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...(_report!.entries!.map((entry) => _buildDeedEntry(entry)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedEntry(DeedEntryEntity entry) {
    final currentValue = _deedValues[entry.deedTemplateId] ?? entry.deedValue;
    final template = _deedTemplates[entry.deedTemplateId];
    final deedName = template?['name'] ?? 'Deed ${entry.deedTemplateId.substring(0, 8)}';
    final valueType = template?['valueType'] ?? 'binary';
    final isFractional = valueType == 'fractional';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deedName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Original: ${entry.deedValue.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isFractional) ...[
            // Slider for fractional deeds
            SizedBox(
              width: 200,
              child: Slider(
                value: currentValue,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: currentValue.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _deedValues[entry.deedTemplateId] = value;
                    _hasChanges = true;
                  });
                },
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                currentValue.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ] else ...[
            // Checkbox for binary deeds
            Checkbox(
              value: currentValue == 1.0,
              onChanged: (bool? checked) {
                setState(() {
                  _deedValues[entry.deedTemplateId] = checked == true ? 1.0 : 0.0;
                  _hasChanges = true;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final originalTotal = _report!.totalDeeds;
    final newTotal = _calculateNewTotal();
    final difference = newTotal - originalTotal;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Original Total',
              originalTotal.toStringAsFixed(1),
              Colors.grey[700]!,
            ),
            _buildSummaryRow(
              'New Total',
              newTotal.toStringAsFixed(1),
              Colors.blue[700]!,
            ),
            _buildSummaryRow(
              'Difference',
              '${difference >= 0 ? '+' : ''}${difference.toStringAsFixed(1)}',
              difference >= 0 ? Colors.green[700]! : Colors.red[700]!,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What will happen:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildActionItem('Report totals will be updated'),
                  _buildActionItem('Penalties will be recalculated'),
                  _buildActionItem('User balance will be adjusted'),
                  _buildActionItem('Audit log will record this change'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Reason for change (required)',
        hintText: 'Explain why this report is being modified...',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        setState(() {}); // Trigger rebuild to update save button state
      },
    );
  }

  Widget _buildSaveButton() {
    final bool canSave = _hasChanges && _reasonController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canSave ? _showSaveConfirmation : null,
        icon: const Icon(Icons.save),
        label: const Text('Save Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          disabledBackgroundColor: Colors.grey[300],
        ),
      ),
    );
  }

  void _initializeDeedValues() {
    _deedValues.clear();
    if (_report!.entries != null) {
      for (var entry in _report!.entries!) {
        _deedValues[entry.deedTemplateId] = entry.deedValue;
      }
    }
  }

  double _calculateNewTotal() {
    return _deedValues.values.fold(0.0, (sum, value) => sum + value);
  }

  void _showSaveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Changes'),
        content: const Text(
          'Are you sure you want to save these changes? '
          'This will recalculate penalties and cannot be easily undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    context.read<AdminBloc>().add(
          UpdateReportRequested(
            reportId: widget.reportId,
            deedValues: _deedValues,
            reason: _reasonController.text.trim(),
          ),
        );
  }
}
