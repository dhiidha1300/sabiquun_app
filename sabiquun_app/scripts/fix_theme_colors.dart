import 'dart:io';

void main() {
  print('Starting theme color fix...\n');
  
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('Error: lib directory not found.');
    exit(1);
  }
  
  int filesFixed = 0;
  int replacementsMade = 0;
  
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
  
  print('Found ${dartFiles.length} Dart files.\n');
  
  for (final file in dartFiles) {
    if (file.path.contains('app_theme.dart') ||
        file.path.contains('app_colors.dart') ||
        file.path.contains('theme_utils.dart')) {
      continue;
    }
    
    final original = file.readAsStringSync();
    var updated = original;
    int fileReplacements = 0;
    
    // Background colors
    updated = updated.replaceAll(
      'color: AppColors.background',
      'color: Theme.of(context).scaffoldBackgroundColor',
    );
    updated = updated.replaceAll(
      'backgroundColor: AppColors.background',
      'backgroundColor: Theme.of(context).scaffoldBackgroundColor',
    );
    
    // Surface colors
    updated = updated.replaceAll(
      'color: AppColors.surface',
      'color: Theme.of(context).colorScheme.surface',
    );
    updated = updated.replaceAll(
      'backgroundColor: AppColors.surface',
      'backgroundColor: Theme.of(context).colorScheme.surface',
    );
    
    if (updated != original) {
      fileReplacements = original.split('AppColors.').length - updated.split('AppColors.').length;
      file.writeAsStringSync(updated);
      filesFixed++;
      replacementsMade += fileReplacements.abs();
      print('✓ Fixed: ${file.path}');
    }
  }
  
  print('\nTheme fix complete!');
  print('Files updated: $filesFixed');
  print('Replacements: $replacementsMade');
}
