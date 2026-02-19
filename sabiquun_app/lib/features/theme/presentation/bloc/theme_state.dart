import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme state containing the current theme mode
class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    required this.themeMode,
    this.isLoading = false,
  });

  /// Initial state with system default theme
  factory ThemeState.initial() {
    return const ThemeState(
      themeMode: ThemeMode.system,
      isLoading: true,
    );
  }

  /// Copy with method for creating modified states
  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [themeMode, isLoading];
}
