import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';

/// Local data source for calendar preferences
/// Uses SharedPreferences for persistent storage
class CalendarLocalDataSource {
  final SharedPreferences _prefs;

  CalendarLocalDataSource(this._prefs);

  /// Get the saved calendar preference as string
  /// Returns null if no preference is saved
  /// Possible values: 'hijri_primary', 'gregorian_primary', 'hijri_only', 'gregorian_only'
  Future<String?> getCalendarPreference() async {
    try {
      return _prefs.getString(AppConstants.calendarPreferenceKey);
    } catch (e) {
      throw Exception('Failed to load calendar preference: $e');
    }
  }

  /// Save the calendar preference
  /// [preference] - The calendar preference string
  Future<void> setCalendarPreference(String preference) async {
    try {
      await _prefs.setString(AppConstants.calendarPreferenceKey, preference);
    } catch (e) {
      throw Exception('Failed to save calendar preference: $e');
    }
  }
}
