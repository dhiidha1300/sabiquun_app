import 'dart:io';

/// Remove hardcoded text colors from app_theme.dart TextTheme
/// Let Material 3 ColorScheme provide the colors automatically

void main() {
  print('Fixing app_theme.dart text colors...\n');

  final file = File('sabiquun_app/lib/core/theme/app_theme.dart');
  if (!file.existsSync()) {
    print('❌ app_theme.dart not found');
    return;
  }

  String content = file.readAsStringSync();
  final original = content;

  // Remove color specifications from TextStyle definitions in TextTheme
  // This allows the ColorScheme to provide the appropriate colors

  // Pattern: Remove "color: AppColors.textPrimary," lines
  content = content.replaceAll(
    RegExp(r'\s*color:\s*AppColors\.textPrimary,?\s*\n'),
    '\n',
  );

  // Pattern: Remove "color: AppColors.textSecondary," lines
  content = content.replaceAll(
    RegExp(r'\s*color:\s*AppColors\.textSecondary,?\s*\n'),
    '\n',
  );

  // Pattern: Remove "color: AppColors.textHint," lines
  content = content.replaceAll(
    RegExp(r'\s*color:\s*AppColors\.textHint,?\s*\n'),
    '\n',
  );

  if (content != original) {
    file.writeAsStringSync(content);
    print('✅ Fixed app_theme.dart');
    print('   Removed hardcoded text colors from TextTheme');
    print('   Material 3 ColorScheme will now provide adaptive colors\n');
  } else {
    print('⚠️  No changes needed');
  }

  print('Run "flutter analyze" to verify');
}
