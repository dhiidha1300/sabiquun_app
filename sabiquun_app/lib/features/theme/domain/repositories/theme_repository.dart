import 'package:flutter/material.dart';

/// Abstract repository for theme management
/// Follows the repository pattern used throughout the app
abstract class ThemeRepository {
  /// Get the currently saved theme mode
  /// Returns ThemeMode.system if no preference is saved
  Future<ThemeMode> getThemeMode();

  /// Save the user's theme mode preference
  /// [mode] - The theme mode to save (light, dark, or system)
  Future<void> setThemeMode(ThemeMode mode);
}
