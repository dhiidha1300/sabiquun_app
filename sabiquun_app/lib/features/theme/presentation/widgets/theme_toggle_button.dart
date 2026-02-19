import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

/// Icon button for quick theme toggle
/// Shows sun/moon icon based on current theme
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            _getThemeIcon(state.themeMode),
            color: Theme.of(context).iconTheme.color,
          ),
          tooltip: 'Change theme',
          onPressed: () => _showThemeDialog(context, state.themeMode),
        );
      },
    );
  }

  /// Get icon based on current theme mode
  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// Show dialog to select theme
  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context: context,
              dialogContext: dialogContext,
              title: 'Light',
              subtitle: 'Always use light theme',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
              isSelected: currentMode == ThemeMode.light,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context: context,
              dialogContext: dialogContext,
              title: 'Dark',
              subtitle: 'Always use dark theme',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
              isSelected: currentMode == ThemeMode.dark,
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context: context,
              dialogContext: dialogContext,
              title: 'System Default',
              subtitle: 'Follow device settings',
              icon: Icons.brightness_auto,
              mode: ThemeMode.system,
              isSelected: currentMode == ThemeMode.system,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build a single theme option
  Widget _buildThemeOption({
    required BuildContext context,
    required BuildContext dialogContext,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<ThemeBloc>().add(ThemeChanged(mode));
        Navigator.of(dialogContext).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).iconTheme.color,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
