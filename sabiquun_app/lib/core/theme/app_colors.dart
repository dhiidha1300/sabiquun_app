import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Primary Colors - Modern Green Theme
  static const Color primary = Color(0xFF1DB954); // Vibrant Green
  static const Color primaryDark = Color(0xFF169B45); // Darker Green
  static const Color primaryLight = Color(0xFF1ED760); // Bright Green (Secondary)

  // Secondary Colors
  static const Color secondary = Color(0xFF1ED760); // Bright Green
  static const Color secondaryDark = Color(0xFF19B54D);
  static const Color secondaryLight = Color(0xFF4EE17E);

  // Accent Colors - Gold
  static const Color accent = Color(0xFFFFD700); // Gold
  static const Color accentDark = Color(0xFFD4AF37); // Darker Gold
  static const Color accentLight = Color(0xFFFFE55C); // Light Gold

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light Grey
  static const Color surface = Color(0xFFF1F8F4); // Mint Cream
  static const Color surfaceVariant = Color(0xFFFFFFFF); // White

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);

  // Role Colors
  static const Color adminColor = Color(0xFF9C27B0); // Purple
  static const Color supervisorColor = Color(0xFF2196F3); // Blue
  static const Color cashierColor = Color(0xFFFF9800); // Orange
  static const Color userColor = Color(0xFF4CAF50); // Green

  // Account Status Colors
  static const Color pendingColor = Color(0xFFFFA726); // Orange
  static const Color activeColor = Color(0xFF4CAF50); // Green
  static const Color suspendedColor = Color(0xFFE53935); // Red
  static const Color deactivatedColor = Color(0xFF9E9E9E); // Grey

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocused = Color(0xFF2E7D32);
  static const Color borderError = Color(0xFFE53935);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentDark, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Surface Gradients for Cards
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Password Strength Colors
  static const Color passwordWeak = Color(0xFFE53935);
  static const Color passwordMedium = Color(0xFFFFA726);
  static const Color passwordStrong = Color(0xFF4CAF50);
  static const Color passwordVeryStrong = Color(0xFF2E7D32);
}
