import 'package:flutter/material.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

/// Implementation of ThemeRepository
/// Manages theme persistence using local data source
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<ThemeMode> getThemeMode() async {
    try {
      final savedMode = await _localDataSource.getThemeMode();

      // If no saved preference, return system default
      if (savedMode == null) {
        return ThemeMode.system;
      }

      // Convert string to ThemeMode enum
      switch (savedMode) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return ThemeMode.system;
      }
    } catch (e) {
      // On error, return system default
      return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      // Convert ThemeMode enum to string
      String modeString;
      switch (mode) {
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }

      await _localDataSource.setThemeMode(modeString);
    } catch (e) {
      throw Exception('Failed to save theme mode: $e');
    }
  }
}
