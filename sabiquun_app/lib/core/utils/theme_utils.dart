import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';

/// Utility class for theme-aware colors
/// Use this instead of direct AppColors when you need theme-aware colors
class ThemeUtils {
  /// Get theme-aware background color
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  /// Get theme-aware surface color (for cards, containers)
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get theme-aware primary color
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get theme-aware text color
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.color ??
           (Theme.of(context).brightness == Brightness.dark
               ? AppColorsDark.textPrimary
               : AppColors.textPrimary);
  }

  /// Get theme-aware secondary text color
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) ??
           (Theme.of(context).brightness == Brightness.dark
               ? AppColorsDark.textSecondary
               : AppColors.textSecondary);
  }

  /// Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Get theme-aware border color
  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).dividerColor;
  }

  /// Get theme-aware shadow color
  static Color getShadowColor(BuildContext context, {double opacity = 0.1}) {
    final isDark = isDarkMode(context);
    return Colors.black.withValues(alpha: isDark ? opacity * 2 : opacity);
  }

  /// Get theme-aware white/black (inverts in dark mode)
  static Color getInverseColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }

  /// Get role color (always the same regardless of theme, but adjusted for visibility)
  static Color getRoleColor(BuildContext context, String role) {
    final isDark = isDarkMode(context);
    switch (role.toLowerCase()) {
      case 'admin':
        return isDark ? AppColorsDark.adminColor : AppColors.adminColor;
      case 'supervisor':
        return isDark ? AppColorsDark.supervisorColor : AppColors.supervisorColor;
      case 'cashier':
        return isDark ? AppColorsDark.cashierColor : AppColors.cashierColor;
      default:
        return isDark ? AppColorsDark.userColor : AppColors.userColor;
    }
  }

  /// Get status color
  static Color getStatusColor(BuildContext context, String status) {
    final isDark = isDarkMode(context);
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
      case 'completed':
        return isDark ? AppColorsDark.success : AppColors.success;
      case 'error':
      case 'failed':
      case 'rejected':
        return isDark ? AppColorsDark.error : AppColors.error;
      case 'warning':
      case 'pending':
        return isDark ? AppColorsDark.warning : AppColors.warning;
      case 'info':
        return isDark ? AppColorsDark.info : AppColors.info;
      default:
        return getTextSecondaryColor(context);
    }
  }

  /// Get a semi-transparent overlay color
  static Color getOverlayColor(BuildContext context, {double opacity = 0.1}) {
    return getPrimaryColor(context).withValues(alpha: opacity);
  }

  /// Get card decoration with theme-aware colors
  static BoxDecoration getCardDecoration(BuildContext context, {
    double borderRadius = 12,
    bool withShadow = true,
    Color? customColor,
  }) {
    return BoxDecoration(
      color: customColor ?? getSurfaceColor(context),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: getShadowColor(context, opacity: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
}
