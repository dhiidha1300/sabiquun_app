import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sabiquun_app/core/constants/app_constants.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/utils/validators.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:sabiquun_app/shared/widgets/custom_button.dart';
import 'package:sabiquun_app/shared/widgets/custom_text_field.dart';
import 'package:sabiquun_app/shared/widgets/password_strength_indicator.dart';

/// Sign up screen
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;
  String _selectedCountryCode = AppConstants.defaultCountryCode;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final email = Validators.sanitizeEmail(_emailController.text);
      final password = _passwordController.text;
      final fullName = _fullNameController.text.trim();
      final phone = _phoneController.text.isNotEmpty
          ? _selectedCountryCode + Validators.sanitizePhoneNumber(_phoneController.text)
          : null;

      context.read<AuthBloc>().add(
            SignUpRequested(
              email: email,
              password: password,
              fullName: fullName,
              phoneNumber: phone,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AccountPendingApproval) {
            context.go('/pending-approval', extra: state.email);
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
                  // Profile Photo (Optional - for future implementation)
                  // Center(
                  //   child: Stack(
                  //     children: [
                  //       CircleAvatar(
                  //         radius: 50,
                  //         backgroundColor: AppColors.greyLight,
                  //         child: Icon(Icons.person, size: 50),
                  //       ),
                  //       Positioned(
                  //         bottom: 0,
                  //         right: 0,
                  //         child: CircleAvatar(
                  //           radius: 18,
                  //           backgroundColor: AppColors.primary,
                  //           child: Icon(Icons.camera_alt, size: 18),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // Full Name
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateFullName,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountryCode,
                          decoration: const InputDecoration(
                            labelText: 'Code',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '+252',
                              child: Text('+252'),
                            ),
                            DropdownMenuItem(
                              value: '+1',
                              child: Text('+1'),
                            ),
                            DropdownMenuItem(
                              value: '+44',
                              child: Text('+44'),
                            ),
                            // Add more country codes as needed
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value ?? '+252';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          hintText: 'Enter your phone number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: Validators.validatePhoneNumber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  PasswordTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Create a password',
                    textInputAction: TextInputAction.next,
                    validator: Validators.validatePassword,
                    onChanged: (value) {
                      setState(() {}); // Rebuild for strength indicator
                    },
                  ),

                  // Password Strength Indicator
                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  PasswordTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(),
                    validator: (value) => Validators.validateConfirmPassword(
                      _passwordController.text,
                      value,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Terms & Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to terms & conditions
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: AppColors.textPrimary),
                                children: [
                                  TextSpan(text: 'I agree to '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'SIGN UP',
                        onPressed: _handleSignUp,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have account? '),
                      CustomTextButton(
                        text: 'Login',
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
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
