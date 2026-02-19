import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base class for all theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize theme (load saved preference)
/// Dispatched when app starts
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

/// Event to change theme mode
/// Dispatched when user selects a new theme
class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChanged(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
