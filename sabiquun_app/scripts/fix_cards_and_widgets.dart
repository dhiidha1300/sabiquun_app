import 'dart:io';

void main() {
  print('Fixing Cards and Widget colors...\n');
  
  final libDir = Directory('lib');
  int filesFixed = 0;
  
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart') && 
                      !file.path.contains('app_theme.dart') &&
                      !file.path.contains('app_colors.dart'))
      .toList();
  
  for (final file in dartFiles) {
    final original = file.readAsStringSync();
    var updated = original;
    
    // Fix Card widgets with white background
    if (updated.contains('Card(') && updated.contains('color: Colors.white')) {
      updated = updated.replaceAll(
        RegExp(r'Card\(\s*color:\s*Colors\.white,'),
        'Card(color: Theme.of(context).cardColor,',
      );
    }
    
    // Fix Container with white background
    if (updated.contains('Container(') && updated.contains('color: Colors.white')) {
      updated = updated.replaceAll(
        RegExp(r'color:\s*Colors\.white(?!\.)'),
        'color: Theme.of(context).colorScheme.surface',
      );
    }
    
    // Fix grey backgrounds
    if (updated.contains('Colors.grey[')) {
      updated = updated.replaceAll(
        RegExp(r'color:\s*Colors\.grey\[(\d+)\]'),
        'color: Theme.of(context).colorScheme.surfaceVariant',
      );
    }
    
    if (updated != original) {
      file.writeAsStringSync(updated);
      filesFixed++;
      print('✓ Fixed: ${file.path}');
    }
  }
  
  print('\nCards and widgets fix complete!');
  print('Files updated: $filesFixed');
}
