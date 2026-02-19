import 'package:equatable/equatable.dart';

import '../../../../core/constants/date_constants.dart';

/// Base class for all calendar events
abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize calendar preference (load saved preference)
/// Dispatched when app starts
class CalendarPreferenceInitialized extends CalendarEvent {
  const CalendarPreferenceInitialized();
}

/// Event to change calendar preference
/// Dispatched when user selects a new calendar preference
class CalendarPreferenceChanged extends CalendarEvent {
  final CalendarPreference preference;

  const CalendarPreferenceChanged(this.preference);

  @override
  List<Object?> get props => [preference];
}
