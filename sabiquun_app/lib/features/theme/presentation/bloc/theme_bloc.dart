import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing theme state
/// Handles theme initialization and theme changes
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc(this._themeRepository) : super(ThemeState.initial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeChanged>(_onThemeChanged);
  }

  /// Handle theme initialization event
  /// Load saved theme preference from repository
  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final themeMode = await _themeRepository.getThemeMode();
      emit(state.copyWith(
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      // On error, use system default
      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Handle theme change event
  /// Save new theme preference and update state
  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      // Save the new theme preference
      await _themeRepository.setThemeMode(event.themeMode);

      // Update state with new theme
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      // On error, keep current state
      // Could emit an error state here if needed
    }
  }
}
