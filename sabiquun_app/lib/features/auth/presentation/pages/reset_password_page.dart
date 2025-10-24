import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/utils/validators.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/shared/widgets/custom_button.dart';
import 'package:sabiquun_app/shared/widgets/custom_text_field.dart';
import 'package:sabiquun_app/shared/widgets/password_strength_indicator.dart';

/// Reset Password screen
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      final newPassword = _newPasswordController.text;
      context.read<AuthBloc>().add(PasswordUpdateRequested(newPassword));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Password reset successful, show success and navigate to login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successful! Please login with your new password.'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Lock Icon
                  Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Create New Password',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Instructions
                  Text(
                    'Enter a strong password for your account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // New Password
                  PasswordTextField(
                    controller: _newPasswordController,
                    labelText: 'New Password',
                    hintText: 'Enter new password',
                    textInputAction: TextInputAction.next,
                    validator: Validators.validatePassword,
                    onChanged: (value) {
                      setState(() {}); // Rebuild for strength indicator
                    },
                  ),

                  // Password Strength Indicator
                  PasswordStrengthIndicator(
                    password: _newPasswordController.text,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm New Password',
                    hintText: 'Re-enter new password',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleResetPassword(),
                    validator: (value) => Validators.validateConfirmPassword(
                      _newPasswordController.text,
                      value,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password Requirements
                  PasswordRequirements(
                    password: _newPasswordController.text,
                  ),
                  const SizedBox(height: 32),

                  // Reset Password Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Reset Password',
                        onPressed: _handleResetPassword,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
