import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_event.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_state.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/features/penalties/domain/entities/penalty_entity.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_event.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_state.dart';
import 'package:sabiquun_app/features/payments/presentation/widgets/balance_adjustment_dialog.dart';

/// User Balance Detail Page
/// Shows detailed user balance information and allows manual adjustments
class UserBalanceDetailPage extends StatefulWidget {
  final String userId;

  const UserBalanceDetailPage({
    super.key,
    required this.userId,
  });

  @override
  State<UserBalanceDetailPage> createState() => _UserBalanceDetailPageState();
}

class _UserBalanceDetailPageState extends State<UserBalanceDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load user details
    context.read<AdminBloc>().add(LoadUserByIdRequested(widget.userId));

    // Load user's penalty balance
    context.read<PenaltyBloc>().add(LoadPenaltyBalanceRequested(widget.userId));

    // Load unpaid penalties (FIFO)
    context.read<PenaltyBloc>().add(LoadUnpaidPenaltiesRequested(widget.userId));
  }

  Future<void> _onRefresh() async {
    _loadData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showAdjustmentDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    showDialog(
      context: context,
      builder: (context) => BalanceAdjustmentDialog(
        userId: widget.userId,
        currentUserId: authState.user.id,
        onAdjustmentComplete: () {
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('User Balance Detail'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, adminState) {
            if (adminState is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (adminState is AdminError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    SizedBox(height: 16),
                    Text(
                      'Error loading user',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      adminState.message,
                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (adminState is UserDetailLoaded) {
              final user = adminState.user;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    _buildUserInfoCard(user),
                    const SizedBox(height: 20),

                    // Current Balance Card
                    _buildBalanceCard(),
                    const SizedBox(height: 20),

                    // Unpaid Penalties Section
                    _buildUnpaidPenaltiesSection(),
                    const SizedBox(height: 20),

                    // Manual Adjustment Button
                    _buildAdjustmentButton(),
                    const SizedBox(height: 100), // Space for any bottom elements
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.initials,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Name
          Text(
            user.fullName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.surface,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Membership Badge
          if (user.membershipStatus != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMembershipLabel(user.membershipStatus),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          SizedBox(height: 16),

          // Contact Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.email, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (user.phoneNumber != null) ...[
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7), size: 18),
                      SizedBox(width: 8),
                      Text(
                        user.phoneNumber!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Member since ${DateFormat('MMM dd, yyyy').format(user.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        String balanceText = 'Loading...';
        String lastUpdatedText = '';
        Color balanceColor = Theme.of(context).colorScheme.onSurface;

        // Extract balance from either PenaltyBalanceLoaded or UnpaidPenaltiesLoaded
        double? balanceAmount;

        if (state is PenaltyBalanceLoaded) {
          balanceAmount = state.balance.balance;
        } else if (state is UnpaidPenaltiesLoaded) {
          balanceAmount = state.balance.balance;
        }

        if (balanceAmount != null) {
          balanceText = NumberFormat('#,###').format(balanceAmount);
          lastUpdatedText = 'Updated just now';

          // Color code by severity
          if (balanceAmount > 300000) {
            balanceColor = AppColors.error;
          } else if (balanceAmount > 150000) {
            balanceColor = Colors.orange;
          } else if (balanceAmount > 0) {
            balanceColor = Colors.amber.shade700;
          } else {
            balanceColor = Colors.green;
          }
        } else if (state is PenaltyError) {
          balanceText = 'Error';
          balanceColor = AppColors.error;
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                balanceColor.withValues(alpha: 0.1),
                balanceColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: balanceColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: balanceColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: balanceColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '$balanceText Shillings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: balanceColor,
                  letterSpacing: 0.5,
                ),
              ),
              if (lastUpdatedText.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  lastUpdatedText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUnpaidPenaltiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.format_list_numbered_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Unpaid Penalties (FIFO)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Oldest penalties are paid first',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<PenaltyBloc, PenaltyState>(
          builder: (context, state) {
            if (state is PenaltyLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle both PenaltiesLoaded and UnpaidPenaltiesLoaded states
            List<PenaltyEntity>? penalties;

            if (state is PenaltiesLoaded) {
              penalties = state.penalties;
            } else if (state is UnpaidPenaltiesLoaded) {
              penalties = state.penalties;
            }

            if (penalties != null) {

              if (penalties.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No unpaid penalties',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This user has a clean balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: penalties.map((penalty) {
                  final isPaidFull = penalty.paidAmount >= penalty.amount;
                  final remainingAmount = penalty.amount - penalty.paidAmount;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPaidFull
                            ? Colors.green.withValues(alpha: 0.3)
                            : AppColors.error.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isPaidFull
                                  ? Icons.check_circle
                                  : Icons.warning_amber_rounded,
                              color: isPaidFull ? Colors.green : AppColors.error,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(penalty.dateIncurred),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPaidFull
                                    ? Colors.green.shade100
                                    : AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPaidFull ? 'Paid' : 'Unpaid',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isPaidFull ? Colors.green.shade700 : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${NumberFormat('#,###').format(penalty.amount)} Sh',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            if (!isPaidFull)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat('#,###').format(remainingAmount)} Sh',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (penalty.waivedReason != null && penalty.waivedReason!.isNotEmpty) ...[
                          SizedBox(height: 8),
                          Text(
                            'Waived: ${penalty.waivedReason!}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              );
            }

            if (state is PenaltyError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Error loading penalties: ${state.message}',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }

  Widget _buildAdjustmentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAdjustmentDialog,
        icon: const Icon(Icons.edit),
        label: const Text('Manual Balance Adjustment'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  String _getMembershipLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'exclusive':
        return '💎 Exclusive Member';
      case 'new_member':
        return '🌱 New Member';
      case 'training':
        return '📚 Training Period';
      default:
        return 'Member';
    }
  }
}
