import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:sabiquun_app/core/utils/validators.dart';

/// Visual indicator for password strength
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = Validators.getPasswordStrength(password);
    final label = Validators.getPasswordStrengthLabel(strength);

    Color getColor() {
      if (strength < 0.3) return AppColors.passwordWeak;
      if (strength < 0.6) return AppColors.passwordMedium;
      if (strength < 0.8) return AppColors.passwordStrong;
      return AppColors.passwordVeryStrong;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength,
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(getColor()),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: getColor(),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Password requirements checklist
class PasswordRequirements extends StatelessWidget {
  final String password;

  const PasswordRequirements({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = Validators.checkPasswordRequirements(password);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          _RequirementItem(
            text: 'At least 8 characters',
            isMet: requirements['minLength'] ?? false,
          ),
          _RequirementItem(
            text: 'One uppercase letter',
            isMet: requirements['hasUppercase'] ?? false,
          ),
          _RequirementItem(
            text: 'One lowercase letter',
            isMet: requirements['hasLowercase'] ?? false,
          ),
          _RequirementItem(
            text: 'One number',
            isMet: requirements['hasNumber'] ?? false,
          ),
        ],
      ),
    );
  }
}

class _RequirementItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const _RequirementItem({
    required this.text,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
