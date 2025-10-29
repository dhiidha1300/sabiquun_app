import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Onboarding Card for first-time users with getting started checklist
class OnboardingCard extends StatefulWidget {
  final String userName;
  final bool isNewMember;
  final int daysRemaining;

  const OnboardingCard({
    super.key,
    required this.userName,
    required this.isNewMember,
    this.daysRemaining = 30,
  });

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard> {
  bool _isDismissed = false;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _checkDismissedStatus();
  }

  Future<void> _checkDismissedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('onboarding_dismissed') ?? false;
    if (mounted) {
      setState(() {
        _isDismissed = dismissed;
      });
    }
  }

  Future<void> _dismissOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_dismissed', true);
    setState(() {
      _isDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Card(
      color: AppColors.info.withOpacity(0.05),
      elevation: 3,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      color: AppColors.info,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Sabiquun, ${widget.userName}! 👋',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (widget.isNewMember)
                          Text(
                            '🆕 Training Period - ${widget.daysRemaining} days remaining (No penalties)',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _dismissOnboarding,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Checklist
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Getting Started Checklist',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem(
                    context,
                    Icons.check_circle,
                    'Complete your profile',
                    isCompleted: true,
                  ),
                  _buildChecklistItem(
                    context,
                    Icons.library_books,
                    'Submit your first deed report',
                    isCompleted: false,
                  ),
                  _buildChecklistItem(
                    context,
                    Icons.info_outline,
                    'Learn about the penalty system',
                    isCompleted: false,
                  ),
                  _buildChecklistItem(
                    context,
                    Icons.medical_services,
                    'Explore the excuse system',
                    isCompleted: false,
                  ),
                  _buildChecklistItem(
                    context,
                    Icons.notifications,
                    'Set up notifications',
                    isCompleted: false,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context,
    IconData icon,
    String text, {
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isCompleted ? AppColors.success : AppColors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
