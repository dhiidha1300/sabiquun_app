import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Widget to display the status of the automated penalty calculation system
/// Shows last execution time, results, and allows manual trigger
class PenaltyCalculationStatusCard extends StatefulWidget {
  const PenaltyCalculationStatusCard({super.key});

  @override
  State<PenaltyCalculationStatusCard> createState() =>
      _PenaltyCalculationStatusCardState();
}

class _PenaltyCalculationStatusCardState
    extends State<PenaltyCalculationStatusCard> {
  Map<String, dynamic>? _lastExecution;
  bool _isLoading = false;
  bool _isManuallyTriggering = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLastExecution();
  }

  Future<void> _loadLastExecution() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Get the most recent execution log
      final response = await supabase
          .from('penalty_calculation_log')
          .select()
          .order('execution_time', ascending: false)
          .limit(1)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _lastExecution = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _manualTrigger() async {
    setState(() {
      _isManuallyTriggering = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Call the penalty calculation function
      final result = await supabase.rpc('calculate_daily_penalties_with_logging');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Penalty calculation completed: '
              '${result['users_processed']} users processed, '
              '${result['penalties_created']} penalties created',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );

        // Reload the execution log
        await _loadLastExecution();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Manual trigger failed: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isManuallyTriggering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        color: AppColors.surface,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final bool hasExecuted = _lastExecution != null;
    final DateTime? lastRunTime = hasExecuted
        ? DateTime.parse(_lastExecution!['execution_time'])
        : null;
    final int hoursSinceLastRun = lastRunTime != null
        ? DateTime.now().difference(lastRunTime).inHours
        : 999;

    // Determine status
    final bool isHealthy = hoursSinceLastRun < 25; // Should run daily
    final bool isWarning = hoursSinceLastRun >= 25 && hoursSinceLastRun < 48;
    final bool isCritical = hoursSinceLastRun >= 48;

    final Color statusColor = isCritical
        ? AppColors.error
        : isWarning
            ? AppColors.warning
            : isHealthy
                ? AppColors.success
                : AppColors.textSecondary;

    final IconData statusIcon = isCritical
        ? Icons.error
        : isWarning
            ? Icons.warning
            : isHealthy
                ? Icons.check_circle
                : Icons.help_outline;

    return Card(
      color: AppColors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automated Penalty Calculation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(hoursSinceLastRun),
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Manual trigger button
                IconButton(
                  icon: _isManuallyTriggering
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                  onPressed: _isManuallyTriggering ? null : _manualTrigger,
                  tooltip: 'Manually trigger penalty calculation',
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (hasExecuted) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Execution details
              _buildDetailRow(
                'Last Run',
                lastRunTime != null ? timeago.format(lastRunTime) : 'Never',
                Icons.schedule,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Users Processed',
                _lastExecution!['users_processed']?.toString() ?? '0',
                Icons.people,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'Penalties Created',
                _lastExecution!['penalties_created']?.toString() ?? '0',
                Icons.receipt_long,
              ),

              // Show errors if any
              if (_lastExecution!['errors'] != null &&
                  (_lastExecution!['errors'] as List).isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Errors',
                  '${(_lastExecution!['errors'] as List).length} errors',
                  Icons.warning,
                  valueColor: AppColors.warning,
                ),
              ],
            ] else ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'No execution history found.\nClick refresh to trigger manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Next scheduled run info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scheduled: Daily at 12:00 PM EAT (9:00 AM UTC)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getStatusText(int hoursSince) {
    if (hoursSince >= 48) {
      return 'Critical: Not running for $hoursSince hours';
    } else if (hoursSince >= 25) {
      return 'Warning: Last run $hoursSince hours ago';
    } else if (hoursSince < 24) {
      return 'Healthy: Running as scheduled';
    } else {
      return 'No execution history';
    }
  }
}
