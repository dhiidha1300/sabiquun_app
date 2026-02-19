#!/usr/bin/env dart

/// Script to automatically fix hardcoded AppColors to theme-aware colors
/// Run this script to batch-update all Dart files in the project
///
/// Usage: dart scripts/fix_theme_colors.dart

import 'dart:io';

void main() {
  print('Starting theme color fix...\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Error: lib directory not found. Run this script from the project root.');
    exit(1);
  }

  int filesFixed = 0;
  int replacementsMade = 0;

  // Find all .dart files
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  print('Found ${dartFiles.length} Dart files.\n');

  for (final file in dartFiles) {
    final original = file.readAsStringSync();
    var updated = original;
    int fileReplacements = 0;

    // Skip theme files themselves
    if (file.path.contains('app_theme.dart') ||
        file.path.contains('app_colors.dart') ||
        file.path.contains('theme_utils.dart')) {
      continue;
    }

    // Background colors
    if (updated.contains('AppColors.background')) {
      updated = updated.replaceAll(
        'color: AppColors.background',
        'color: Theme.of(context).scaffoldBackgroundColor',
      );
      updated = updated.replaceAll(
        'backgroundColor: AppColors.background',
        'backgroundColor: Theme.of(context).scaffoldBackgroundColor',
      );
      fileReplacements++;
    }

    // Surface colors (cards, containers)
    if (updated.contains('AppColors.surface')) {
      updated = updated.replaceAll(
        'color: AppColors.surface',
        'color: Theme.of(context).colorScheme.surface',
      );
      updated = updated.replaceAll(
        'backgroundColor: AppColors.surface',
        'backgroundColor: Theme.of(context).colorScheme.surface',
      );
      fileReplacements++;
    }

    // White color - needs context check for dark mode
    if (updated.contains('Colors.white') && !file.path.contains('test/')) {
      // Only replace in non-test files and where it's used for backgrounds
      updated = updated.replaceAll(
        RegExp(r'color:\s*Colors\.white,'),
        'color: Theme.of(context).colorScheme.surface,',
      );
      updated = updated.replaceAll(
        RegExp(r'backgroundColor:\s*Colors\.white'),
        'backgroundColor: Theme.of(context).colorScheme.surface',
      );
      fileReplacements++;
    }

    // Text colors
    if (updated.contains('AppColors.textPrimary') || updated.contains('AppColors.textSecondary')) {
      updated = updated.replaceAll(
        'color: AppColors.textPrimary',
        'color: Theme.of(context).textTheme.bodyLarge?.color',
      );
      updated = updated.replaceAll(
        'color: AppColors.textSecondary',
        'color: Theme.of(context).textTheme.bodySmall?.color',
      );
      fileReplacements++;
    }

    // Remove const from BoxDecoration if it has AppColors
    if (updated.contains('const BoxDecoration') && updated.contains('AppColors.')) {
      updated = updated.replaceAll('const BoxDecoration(', 'BoxDecoration(');
      fileReplacements++;
    }

    // Primary color
    if (updated.contains('AppColors.primary') && !updated.contains('AppColors.primaryGradient')) {
      updated = updated.replaceAll(
        'color: AppColors.primary',
        'color: Theme.of(context).colorScheme.primary',
      );
      updated = updated.replaceAll(
        'backgroundColor: AppColors.primary',
        'backgroundColor: Theme.of(context).colorScheme.primary',
      );
      fileReplacements++;
    }

    if (updated != original) {
      file.writeAsStringSync(updated);
      filesFixed++;
      replacementsMade += fileReplacements;
      print('✓ Fixed: ${file.path} ($fileReplacements replacements)');
    }
  }

  print('\n=================================');
  print('Theme fix complete!');
  print('Files updated: $filesFixed');
  print('Total replacements: $replacementsMade');
  print('=================================\n');
  print('Next steps:');
  print('1. Run: flutter analyze');
  print('2. Fix any remaining issues manually');
  print('3. Test the app in both light and dark modes');
}
