import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_report_entity.dart';
import 'package:sabiquun_app/features/deeds/domain/entities/deed_template_entity.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_event.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_state.dart';

class ReportDetailPage extends StatefulWidget {
  final String reportId;

  const ReportDetailPage({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<DeedBloc>().add(LoadReportByIdRequested(widget.reportId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
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
          } else if (state is DeedReportDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is DeedReportSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report submitted for approval'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<DeedBloc>().add(LoadReportByIdRequested(widget.reportId));
          }
        },
        builder: (context, state) {
          if (state is DeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportDetailLoaded) {
            return _buildContent(state.report, state.templates);
          }

          return const Center(
            child: Text('Unable to load report'),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    DeedReportEntity report,
    List<DeedTemplateEntity> templates,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(report),
          const SizedBox(height: 16),
          _buildStatsCard(report),
          const SizedBox(height: 16),
          _buildDeedsListCard(report, templates),
          const SizedBox(height: 16),
          if (report.status.isEditable) _buildActions(report),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(DeedReportEntity report) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(report.reportDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(report.status),
              ],
            ),
            if (report.submittedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Submitted: ${DateFormat('MMM dd, yyyy HH:mm').format(report.submittedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(DeedReportEntity report) {
    final completionPercentage = report.completionPercentage;
    final missedDeeds = report.totalDeedsCount - report.totalDeeds;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Completed',
                  report.totalDeeds.toStringAsFixed(1),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Missed',
                  missedDeeds.toStringAsFixed(1),
                  Icons.cancel,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: completionPercentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionPercentage >= 80
                      ? Colors.green
                      : completionPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${completionPercentage.toStringAsFixed(1)}% Completion Rate',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDeedsListCard(
    DeedReportEntity report,
    List<DeedTemplateEntity> templates,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deeds Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...templates.map((template) {
              final entry = report.entries?.firstWhere(
                (e) => e.deedTemplateId == template.id,
                orElse: () => throw Exception('Entry not found'),
              );

              return _buildDeedDetailItem(
                template,
                entry?.deedValue ?? 0.0,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeedDetailItem(DeedTemplateEntity template, double deedValue) {
    final isCompleted = deedValue >= 1.0;
    final isPartial = deedValue > 0.0 && deedValue < 1.0;
    final isMissed = deedValue == 0.0;
    final isFractional = template.valueType == 'fractional';

    // Determine icon and color based on completion status
    IconData icon;
    Color color;
    if (isCompleted) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (isPartial && isFractional) {
      icon = Icons.warning;
      color = Colors.orange;
    } else {
      icon = Icons.cancel;
      color = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.deedName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      template.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: template.category == 'faraid'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isFractional) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${deedValue.toStringAsFixed(1)}/1.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMissed || isPartial)
            Text(
              isMissed ? '5,000' : ((1.0 - deedValue) * 5000).toStringAsFixed(0),
              style: TextStyle(
                fontSize: 14,
                color: isPartial ? Colors.orange : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ReportStatus.draft:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.edit;
        break;
      case ReportStatus.submitted:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(DeedReportEntity report) {
    return Column(
      children: [
        if (report.status.isDraft)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push('/today-deeds');
                // Reload report after returning from edit
                if (mounted) {
                  context.read<DeedBloc>().add(LoadReportByIdRequested(widget.reportId));
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (report.status.isDraft)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _submitReport(report.id),
              icon: const Icon(Icons.send),
              label: const Text('Submit Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteReport(report.id),
            icon: const Icon(Icons.delete),
            label: const Text('Delete Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _submitReport(String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Report'),
        content: const Text(
          'Are you sure you want to submit this report for approval? '
          'You won\'t be able to edit it after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DeedBloc>().add(SubmitDeedReportRequested(reportId));
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _deleteReport(String reportId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
          'Are you sure you want to delete this report? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<DeedBloc>().add(DeleteDeedReportRequested(reportId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
