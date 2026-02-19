import 'package:equatable/equatable.dart';

import '../../../../core/constants/date_constants.dart';

/// Calendar state containing the current calendar preference
class CalendarState extends Equatable {
  final CalendarPreference preference;
  final bool isLoading;

  const CalendarState({
    required this.preference,
    this.isLoading = false,
  });

  /// Initial state with Hijri Primary as default (user's choice)
  factory CalendarState.initial() {
    return const CalendarState(
      preference: CalendarPreference.hijriPrimary,
      isLoading: true,
    );
  }

  /// Copy with method for creating modified states
  CalendarState copyWith({
    CalendarPreference? preference,
    bool? isLoading,
  }) {
    return CalendarState(
      preference: preference ?? this.preference,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [preference, isLoading];
}
