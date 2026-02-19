import '../../../../core/constants/date_constants.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';

/// Implementation of CalendarRepository
/// Manages calendar preference persistence using local data source
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource _localDataSource;

  CalendarRepositoryImpl(this._localDataSource);

  @override
  Future<CalendarPreference> getCalendarPreference() async {
    try {
      final savedPreference = await _localDataSource.getCalendarPreference();

      // If no saved preference, return hijriPrimary as default
      if (savedPreference == null) {
        return CalendarPreference.hijriPrimary;
      }

      // Convert string to CalendarPreference enum
      return CalendarPreference.fromString(savedPreference);
    } catch (e) {
      // On error, return default
      return CalendarPreference.hijriPrimary;
    }
  }

  @override
  Future<void> setCalendarPreference(CalendarPreference preference) async {
    try {
      await _localDataSource.setCalendarPreference(preference.value);
    } catch (e) {
      throw Exception('Failed to save calendar preference: $e');
    }
  }
}
