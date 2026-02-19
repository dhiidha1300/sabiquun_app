import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/presentation/bloc/theme_bloc.dart';
import '../../theme/presentation/bloc/theme_event.dart';
import '../../theme/presentation/bloc/theme_state.dart';

/// Full-page theme settings screen
/// Allows users to choose between light, dark, and system default themes
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Header section
              Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Theme',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select the theme that works best for you',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Light theme option
              _buildThemeCard(
                context: context,
                title: 'Light Mode',
                subtitle: 'Use light theme all the time',
                icon: Icons.light_mode,
                themeMode: ThemeMode.light,
                isSelected: state.themeMode == ThemeMode.light,
                primaryColor: const Color(0xFF1DB954),
                backgroundColor: Colors.white,
                textColor: Colors.black87,
              ),

              const SizedBox(height: 16),

              // Dark theme option
              _buildThemeCard(
                context: context,
                title: 'Dark Mode',
                subtitle: 'Use dark theme all the time',
                icon: Icons.dark_mode,
                themeMode: ThemeMode.dark,
                isSelected: state.themeMode == ThemeMode.dark,
                primaryColor: const Color(0xFF1ED760),
                backgroundColor: const Color(0xFF1E1E1E),
                textColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // System theme option
              _buildThemeCard(
                context: context,
                title: 'System Default',
                subtitle: 'Automatically switch based on device settings',
                icon: Icons.brightness_auto,
                themeMode: ThemeMode.system,
                isSelected: state.themeMode == ThemeMode.system,
                primaryColor: Color(0xFF1DB954),
                backgroundColor: Colors.grey.shade300,
                textColor: Colors.black87,
              ),

              SizedBox(height: 24),

              // Info card
              Card(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'System Default follows your device\'s theme settings. Enable dark mode in your device settings to see it in action.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode themeMode,
    required bool isSelected,
    required Color primaryColor,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<ThemeBloc>().add(ThemeChanged(themeMode));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Theme preview
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: textColor,
                  size: 32,
                ),
              ),

              SizedBox(width: 16),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.surface,
                    size: 20,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
