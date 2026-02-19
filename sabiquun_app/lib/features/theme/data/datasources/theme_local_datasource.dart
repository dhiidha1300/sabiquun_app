import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for theme preferences
/// Uses SharedPreferences for persistent storage
class ThemeLocalDataSource {
  static const String _themeKey = 'user_theme_mode';

  final SharedPreferences _prefs;

  ThemeLocalDataSource(this._prefs);

  /// Get the saved theme mode as string
  /// Returns null if no preference is saved
  /// Possible values: 'light', 'dark', 'system'
  Future<String?> getThemeMode() async {
    try {
      return _prefs.getString(_themeKey);
    } catch (e) {
      throw Exception('Failed to load theme preference: $e');
    }
  }

  /// Save the theme mode preference
  /// [mode] - The theme mode string ('light', 'dark', or 'system')
  Future<void> setThemeMode(String mode) async {
    try {
      await _prefs.setString(_themeKey, mode);
    } catch (e) {
      throw Exception('Failed to save theme preference: $e');
    }
  }
}
