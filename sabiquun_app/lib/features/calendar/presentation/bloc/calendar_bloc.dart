import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// BLoC for managing calendar preference state
/// Handles calendar preference initialization and changes
class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository _calendarRepository;

  CalendarBloc(this._calendarRepository) : super(CalendarState.initial()) {
    on<CalendarPreferenceInitialized>(_onCalendarPreferenceInitialized);
    on<CalendarPreferenceChanged>(_onCalendarPreferenceChanged);
  }

  /// Handle calendar preference initialization event
  /// Load saved calendar preference from repository
  Future<void> _onCalendarPreferenceInitialized(
    CalendarPreferenceInitialized event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      final preference = await _calendarRepository.getCalendarPreference();
      emit(state.copyWith(
        preference: preference,
        isLoading: false,
      ));
    } catch (e) {
      // On error, use default (hijriPrimary)
      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Handle calendar preference change event
  /// Save new calendar preference and update state
  Future<void> _onCalendarPreferenceChanged(
    CalendarPreferenceChanged event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      // Save the new calendar preference
      await _calendarRepository.setCalendarPreference(event.preference);

      // Update state with new preference
      emit(state.copyWith(preference: event.preference));
    } catch (e) {
      // On error, keep current state
      // Could emit an error state here if needed
    }
  }
}
