# Theme System

## Overview

The Sabiquun app implements a comprehensive theme system that allows users to choose between light mode, dark mode, or follow their device's system settings. The theme system is built using Clean Architecture principles with BLoC state management for a maintainable and scalable solution.

---

## Features

### 1. **Three Theme Modes**
- **Light Mode**: Always uses the light theme regardless of device settings
- **Dark Mode**: Always uses the dark theme regardless of device settings
- **System Default**: Automatically switches between light and dark based on device settings

### 2. **Theme Persistence**
- User's theme preference is saved locally using `SharedPreferences`
- Theme preference persists across app restarts
- Theme is loaded automatically on app startup

### 3. **User Interface**
- **Quick Toggle**: Icon button in profile menu for quick access
- **Theme Settings Page**: Full-page settings with visual theme previews
- **Real-time Updates**: Theme changes apply immediately without restart

---

## Architecture

The theme system follows the app's Clean Architecture pattern:

```
lib/features/theme/
├── domain/
│   └── repositories/
│       └── theme_repository.dart          # Abstract repository interface
├── data/
│   ├── datasources/
│   │   └── theme_local_datasource.dart    # SharedPreferences implementation
│   └── repositories/
│       └── theme_repository_impl.dart     # Repository implementation
└── presentation/
    ├── bloc/
    │   ├── theme_bloc.dart                # BLoC for theme state management
    │   ├── theme_event.dart               # Theme events
    │   └── theme_state.dart               # Theme states
    └── widgets/
        └── theme_toggle_button.dart       # Quick toggle widget
```

---

## Color Palettes

### Light Theme Colors
```dart
// Primary
primary: #1DB954 (Vibrant Green)
primaryDark: #169B45
primaryLight: #1ED760

// Background
background: #F5F5F5 (Light Grey)
surface: #F1F8F4 (Mint Cream)
surfaceVariant: #FFFFFF (White)

// Text
textPrimary: #212121 (Dark Grey)
textSecondary: #757575
textHint: #BDBDBD
```

### Dark Theme Colors
```dart
// Primary
primary: #1ED760 (Bright Green - adjusted for dark backgrounds)
primaryDark: #169B45
primaryLight: #4EE17E

// Background
background: #121212 (Pure Dark)
surface: #1E1E1E (Elevated Surface)
surfaceVariant: #2C2C2C

// Text
textPrimary: #E0E0E0 (Light Grey)
textSecondary: #B0B0B0
textHint: #757575
```

---

## Usage

### Accessing Current Theme

```dart
// Get current theme from context
final isDark = Theme.of(context).brightness == Brightness.dark;

// Access theme colors
final primaryColor = Theme.of(context).colorScheme.primary;
final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
```

### Changing Theme

```dart
// Using ThemeBloc
context.read<ThemeBloc>().add(ThemeChanged(ThemeMode.dark));

// Available ThemeModes:
// - ThemeMode.light
// - ThemeMode.dark
// - ThemeMode.system
```

### Creating Theme-Aware Widgets

```dart
// Example: Theme-aware container
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.bodyLarge,
  ),
)

// Using BlocBuilder to react to theme changes
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return Icon(
      state.themeMode == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode
    );
  },
)
```

---

## Implementation Details

### 1. Theme Initialization

Theme is initialized in `main.dart`:

```dart
// Initialize theme on app startup
Injection.themeBloc.add(const ThemeInitialized());
```

### 2. Theme Integration in MaterialApp

```dart
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, themeState) {
    return MaterialApp.router(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,  // Dynamic theme mode
      routerConfig: router,
    );
  },
)
```

### 3. Theme Persistence

```dart
// Saved to SharedPreferences with key: 'user_theme_mode'
// Possible values: 'light', 'dark', 'system'
```

---

## User Interface Components

### Theme Settings Page

Full-page settings accessible via:
- Navigation: `context.push('/theme-settings')`
- Profile Menu: "Theme" option

Features:
- Visual preview cards for each theme option
- Current selection indicator
- Descriptive text for each option
- Info card explaining system default behavior

### Theme Toggle Button

Quick access button that:
- Shows current theme icon (sun/moon/auto)
- Opens dialog with three theme options
- Applies theme change immediately

---

## Best Practices

### 1. Use Theme Colors

**Good:**
```dart
color: Theme.of(context).colorScheme.primary,
```

**Bad:**
```dart
color: Color(0xFF1DB954),  // Hardcoded color
```

### 2. Use Theme Text Styles

**Good:**
```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.titleLarge,
)
```

**Bad:**
```dart
Text(
  'Hello',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
)
```

### 3. Conditional Theme Logic

For cases where you need different values for light/dark:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final icon = isDark ? Icons.dark_mode : Icons.light_mode;
```

### 4. Theme-Adaptive Assets

If you have images that need theme variants:

```dart
Image.asset(
  isDark ? 'assets/logo_dark.png' : 'assets/logo_light.png',
)
```

---

## Accessibility

The theme system follows WCAG AA contrast guidelines:

- **Light Theme**: Dark text (#212121) on light backgrounds
- **Dark Theme**: Light text (#E0E0E0) on dark backgrounds
- **Status Colors**: Adjusted brightness for each theme to maintain readability

---

## Testing

### Manual Testing Checklist

- [ ] Light mode displays correctly on all screens
- [ ] Dark mode displays correctly on all screens
- [ ] System mode follows device settings
- [ ] Theme persists after app restart
- [ ] Theme toggle button works from profile menu
- [ ] Theme settings page displays correctly
- [ ] Theme changes apply immediately
- [ ] No hardcoded colors causing contrast issues

### Screens to Test

- Authentication (Login, Signup)
- Home Dashboard
- Deed Reporting
- Payment Pages
- Analytics
- Admin Pages
- Settings Pages

---

## Troubleshooting

### Theme doesn't persist

**Solution**: Check that `SharedPreferences` is initialized in `Injection.init()`:
```dart
_sharedPreferences = await SharedPreferences.getInstance();
```

### Hardcoded colors visible in dark mode

**Solution**: Replace hardcoded colors with theme colors:
```dart
// Before
color: Colors.white,

// After
color: Theme.of(context).colorScheme.surface,
```

### Theme doesn't change immediately

**Solution**: Ensure widget is wrapped with `BlocBuilder` or uses `Theme.of(context)`:
```dart
BlocBuilder<ThemeBloc, ThemeState>(
  builder: (context, state) {
    return YourWidget();
  },
)
```

---

## Future Enhancements

Potential improvements for future versions:

1. **Custom Theme Colors**: Allow users to customize accent colors
2. **AMOLED Dark Mode**: Pure black (#000000) background for OLED screens
3. **Theme Animations**: Smooth transitions when switching themes
4. **Theme Presets**: Multiple curated theme options
5. **Scheduled Themes**: Auto-switch at specific times (e.g., dark mode at night)

---

## Related Files

- **Color Definitions**: [lib/core/theme/app_colors.dart](../../sabiquun_app/lib/core/theme/app_colors.dart)
- **Theme Configuration**: [lib/core/theme/app_theme.dart](../../sabiquun_app/lib/core/theme/app_theme.dart)
- **Theme BLoC**: [lib/features/theme/presentation/bloc/theme_bloc.dart](../../sabiquun_app/lib/features/theme/presentation/bloc/theme_bloc.dart)
- **Theme Settings Page**: [lib/features/settings/pages/theme_settings_page.dart](../../sabiquun_app/lib/features/settings/pages/theme_settings_page.dart)
- **Dependency Injection**: [lib/core/di/injection.dart](../../sabiquun_app/lib/core/di/injection.dart)
- **App Entry Point**: [lib/main.dart](../../sabiquun_app/lib/main.dart)

---

[← Back to Features](../README.md) | [Main Documentation →](../../README.md)
