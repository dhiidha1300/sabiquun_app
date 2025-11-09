import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_management_entity.dart';

class UserCard extends StatelessWidget {
  final UserManagementEntity user;
  final VoidCallback? onTap;
  final List<UserAction>? actions;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with name and badge
              Row(
                children: [
                  // Profile icon or image
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getStatusColor(context).withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.membershipStatusDisplay,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _getMembershipColor(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // User info
              _buildInfoRow(
                context,
                Icons.email_outlined,
                'Email',
                user.email,
              ),
              if (user.phone != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  Icons.phone_outlined,
                  'Phone',
                  user.phone!,
                ),
              ],
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.admin_panel_settings,
                'Role',
                user.role.displayName,
              ),

              // Statistics (only if not pending)
              if (!user.isPending) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      context,
                      'Balance',
                      '${user.currentBalance.toStringAsFixed(0)} Sh',
                      _getBalanceColor(context, user.currentBalance),
                    ),
                    _buildStat(
                      context,
                      'Reports',
                      user.totalReports.toString(),
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildStat(
                      context,
                      'Compliance',
                      '${(user.complianceRate * 100).toStringAsFixed(0)}%',
                      _getComplianceColor(context, user.complianceRate),
                    ),
                  ],
                ),
              ],

              // Last report date
              if (user.lastReportDate != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last report: ${_formatDate(user.lastReportDate!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],

              // Registration date for pending users
              if (user.isPending) ...[
                const SizedBox(height: 8),
                Text(
                  'Registered: ${_formatDate(user.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],

              // Actions
              if (actions != null && actions!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: actions!
                      .map((action) => OutlinedButton.icon(
                            onPressed: action.onPressed,
                            icon: Icon(action.icon, size: 18),
                            label: Text(action.label),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: action.color,
                              side: BorderSide(color: action.color ?? Colors.grey),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.accountStatus.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(context),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (user.isPending) return Colors.orange;
    if (user.isSuspended) return Colors.red;
    if (user.isActive) return Colors.green;
    return Colors.grey;
  }

  Color _getMembershipColor(BuildContext context) {
    if (user.isInTrainingPeriod) return Colors.green;
    if (user.membershipStatus == 'exclusive') return Colors.purple;
    if (user.membershipStatus == 'legacy') return Colors.blue;
    return Colors.grey;
  }

  Color _getBalanceColor(BuildContext context, double balance) {
    if (balance >= 400000) return Colors.red;
    if (balance >= 100000) return Colors.orange;
    return Colors.green;
  }

  Color _getComplianceColor(BuildContext context, double rate) {
    if (rate >= 0.8) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat.jm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
}

class UserAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const UserAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color,
  });
}
