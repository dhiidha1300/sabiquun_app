import '../../../../core/constants/date_constants.dart';

/// Abstract repository for calendar preference management
/// Follows the repository pattern used throughout the app
abstract class CalendarRepository {
  /// Get the currently saved calendar preference
  /// Returns CalendarPreference.hijriPrimary if no preference is saved (default)
  Future<CalendarPreference> getCalendarPreference();

  /// Save the user's calendar preference
  /// [preference] - The calendar preference to save
  Future<void> setCalendarPreference(CalendarPreference preference);
}
