import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/supervisor_bloc.dart';
import '../bloc/supervisor_event.dart';
import '../bloc/supervisor_state.dart';
import '../widgets/user_report_card.dart';

/// Users at Risk Page - Shows users with high penalty balances
class UsersAtRiskPage extends StatefulWidget {
  const UsersAtRiskPage({super.key});

  @override
  State<UsersAtRiskPage> createState() => _UsersAtRiskPageState();
}

class _UsersAtRiskPageState extends State<UsersAtRiskPage> {
  double _balanceThreshold = 100000;

  @override
  void initState() {
    super.initState();
    _loadUsersAtRisk();
  }

  void _loadUsersAtRisk() {
    context.read<SupervisorBloc>().add(LoadUsersAtRiskRequested(
          balanceThreshold: _balanceThreshold,
        ));
  }

  void _showThresholdDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double tempThreshold = _balanceThreshold;

        return AlertDialog(
          title: const Text('Set Balance Threshold'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${tempThreshold.toStringAsFixed(0)} shillings',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value: tempThreshold,
                    min: 50000,
                    max: 500000,
                    divisions: 9,
                    label: tempThreshold.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        tempThreshold = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _balanceThreshold = tempThreshold;
                });
                Navigator.pop(context);
                _loadUsersAtRisk();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Users at Risk',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${(_balanceThreshold / 1000).toStringAsFixed(0)}k'),
              child: const Icon(Icons.tune),
            ),
            onPressed: _showThresholdDialog,
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined),
            onPressed: () {
              // Navigate to send notification page with pre-selected users
              context.push('/send-notification');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Info Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade100,
                  Colors.red.shade100,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'High Balance Alert',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Users with balance ≥ ${_balanceThreshold.toStringAsFixed(0)} shillings',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadUsersAtRisk();
              },
              child: BlocBuilder<SupervisorBloc, SupervisorState>(
                builder: (context, state) {
                  if (state is SupervisorLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SupervisorError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUsersAtRisk,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is UsersAtRiskLoaded) {
                    if (state.usersAtRisk.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 64, color: Colors.green.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No users at risk!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'All users are within safe balance limits',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.usersAtRisk.length,
                      itemBuilder: (context, index) {
                        final user = state.usersAtRisk[index];
                        return UserReportCard(
                          userReport: user,
                          onTap: () {
                            context.push('/user-detail/${user.userId}');
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
