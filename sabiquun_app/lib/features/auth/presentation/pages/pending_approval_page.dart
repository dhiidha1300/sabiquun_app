import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/constants/app_constants.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/shared/widgets/custom_button.dart';

/// Pending Approval screen shown after signup
class PendingApprovalPage extends StatelessWidget {
  final String? email;

  const PendingApprovalPage({
    super.key,
    this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Icon(
                Icons.pending_outlined,
                size: 100,
                color: AppColors.pendingColor,
              ),
              const SizedBox(height: 32),

              // Thank You Message
              Text(
                'Thank You for Registering!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              const SizedBox(height: 24),

              // Pending Status Message
              Text(
                'Your account is pending admin approval review',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),

              // Notification Promise
              Text(
                'You will receive a notification once your account has been approved by an admin',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 48),

              // View Rules & Policies Button
              CustomOutlinedButton(
                text: 'View Rules & Policies',
                icon: Icons.menu_book_outlined,
                onPressed: () {
                  // Navigate to rules & policies
                  // This should be accessible even when pending approval
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rules & Policies feature coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Logout Button
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutRequested());
                  context.go('/login');
                },
                backgroundColor: AppColors.greyDark,
              ),
              const SizedBox(height: 48),

              // Support Contact
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Need help?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact support at',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      AppConstants.supportEmail,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
