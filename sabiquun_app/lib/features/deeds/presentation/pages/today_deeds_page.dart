import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/di/injection.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';

class TodayDeedsPage extends StatefulWidget {
  const TodayDeedsPage({super.key});

  @override
  State<TodayDeedsPage> createState() => _TodayDeedsPageState();
}

class _TodayDeedsPageState extends State<TodayDeedsPage> {
  final Map<String, int> _deedValues = {};
  final TextEditingController _notesController = TextEditingController();
  String? _existingReportId;

  @override
  void initState() {
    super.initState();
    context.read<DeedBloc>().add(const LoadTodayReportRequested());
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Deeds'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<DeedBloc, DeedState>(
        listener: (context, state) {
          if (state is DeedError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DeedReportCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DeedBloc>().add(const LoadTodayReportRequested());
          } else if (state is DeedReportUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DeedBloc>().add(const LoadTodayReportRequested());
          } else if (state is DeedReportSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted for approval!'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is DeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TodayReportLoaded) {
            // Initialize values from existing report
            if (state.report != null && _deedValues.isEmpty) {
              _existingReportId = state.report!.id;
              _notesController.text = state.report!.notes ?? '';
              for (var entry in state.report!.entries ?? []) {
                _deedValues[entry.templateId] = entry.value;
              }
            } else if (_deedValues.isEmpty) {
              // Initialize with zeros for new report
              for (var template in state.templates) {
                _deedValues[template.id] = 0;
              }
            }

            final canEdit = state.report == null ||
                           state.report!.status.isEditable;

            return _buildForm(
              templates: state.templates,
              canEdit: canEdit,
              existingReport: state.report,
            );
          }

          return const Center(
            child: Text('Unable to load deed templates'),
          );
        },
      ),
    );
  }

  Widget _buildForm({
    required List<DeedTemplateEntity> templates,
    required bool canEdit,
    dynamic existingReport,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateCard(),
          const SizedBox(height: 24),
          _buildDeedsSection(templates, canEdit),
          const SizedBox(height: 24),
          _buildNotesSection(canEdit),
          const SizedBox(height: 24),
          _buildSummaryCard(templates),
          const SizedBox(height: 24),
          if (canEdit) _buildActionButtons(existingReport),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    final today = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF2E7D32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${today.day}/${today.month}/${today.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedsSection(List<DeedTemplateEntity> templates, bool canEdit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Deeds Checklist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) => _buildDeedItem(template, canEdit)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedItem(DeedTemplateEntity template, bool canEdit) {
    final value = _deedValues[template.id] ?? 0;
    final isCompleted = value > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (template.description.isNotEmpty)
                      Text(
                        template.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (canEdit)
                Switch(
                  value: isCompleted,
                  onChanged: (val) {
                    setState(() {
                      _deedValues[template.id] = val ? 1 : 0;
                    });
                  },
                  activeColor: const Color(0xFF2E7D32),
                )
              else
                Icon(
                  isCompleted ? Icons.check_circle : Icons.cancel,
                  color: isCompleted ? Colors.green : Colors.red,
                ),
            ],
          ),
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Penalty: \$${template.penaltyAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(bool canEdit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              enabled: canEdit,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any notes or comments...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<DeedTemplateEntity> templates) {
    int completedCount = 0;
    double totalPenalty = 0.0;

    for (var template in templates) {
      final value = _deedValues[template.id] ?? 0;
      if (value > 0) {
        completedCount++;
      } else {
        totalPenalty += template.penaltyAmount;
      }
    }

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Completed:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '$completedCount / ${templates.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Penalty:',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '\$${totalPenalty.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(dynamic existingReport) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReport(submit: false),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Save Draft',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _saveReport(submit: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Submit Report',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _saveReport({required bool submit}) {
    if (_existingReportId == null) {
      // Create new report
      context.read<DeedBloc>().add(
            CreateDeedReportRequested(
              reportDate: DateTime.now(),
              deedValues: _deedValues,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
    } else {
      // Update existing report
      context.read<DeedBloc>().add(
            UpdateDeedReportRequested(
              reportId: _existingReportId!,
              deedValues: _deedValues,
              notes: _notesController.text.isEmpty ? null : _notesController.text,
            ),
          );
    }

    // If submitting, trigger submit after save
    if (submit && _existingReportId != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        context.read<DeedBloc>().add(
              SubmitDeedReportRequested(_existingReportId!),
            );
      });
    }
  }
}
