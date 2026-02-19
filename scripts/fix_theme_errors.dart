import 'dart:io';

/// Automated script to fix theme-related compilation errors
///
/// Fixes:
/// 1. Remove 'const' from widgets using Theme.of(context)
/// 2. Replace undefined 'surface70' with 'surfaceVariant'
/// 3. Clean up any issues from theme migration

void main() {
  print('Starting theme error fixes...\n');

  // Files with const expression errors
  final filesWithConstErrors = [
    'sabiquun_app/lib/features/admin/presentation/pages/manual_notification_page.dart',
    'sabiquun_app/lib/features/admin/presentation/pages/notification_schedules_page.dart',
    'sabiquun_app/lib/features/admin/presentation/pages/notification_templates_page.dart',
    'sabiquun_app/lib/features/analytics/presentation/pages/user_analytics_dashboard_page.dart',
    'sabiquun_app/lib/features/deeds/presentation/pages/my_reports_page.dart',
    'sabiquun_app/lib/features/deeds/presentation/pages/report_detail_page.dart',
    'sabiquun_app/lib/features/deeds/presentation/pages/today_deeds_page.dart',
    'sabiquun_app/lib/features/home/pages/admin_home_content.dart',
    'sabiquun_app/lib/features/home/pages/cashier_home_content.dart',
    'sabiquun_app/lib/features/home/pages/supervisor_home_content.dart',
    'sabiquun_app/lib/features/home/pages/user_home_content.dart',
    'sabiquun_app/lib/features/home/widgets/admin_menu_grid.dart',
    'sabiquun_app/lib/features/home/widgets/report_calendar_widget.dart',
    'sabiquun_app/lib/features/notifications/presentation/widgets/notification_bell.dart',
    'sabiquun_app/lib/features/notifications/presentation/widgets/notification_item.dart',
    'sabiquun_app/lib/features/payments/presentation/pages/payment_analytics_page.dart',
    'sabiquun_app/lib/features/payments/presentation/pages/payment_review_page.dart',
    'sabiquun_app/lib/features/payments/presentation/pages/user_balance_detail_page.dart',
  ];

  int totalFilesFixed = 0;
  int totalReplacements = 0;

  for (final filePath in filesWithConstErrors) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath');
      continue;
    }

    String content = file.readAsStringSync();
    final originalContent = content;
    int fileReplacements = 0;

    // Fix 1: Remove const from SizedBox with Theme.of(context)
    final constSizedBoxPattern = RegExp(
      r'const SizedBox\(([^)]*)\)',
      multiLine: true,
    );

    content = content.replaceAllMapped(constSizedBoxPattern, (match) {
      final innerContent = match.group(1) ?? '';
      // If the SizedBox only has width/height (no Theme), keep const
      if (!innerContent.contains('Theme.of(context)')) {
        return match.group(0)!;
      }
      // Remove const if it uses Theme
      fileReplacements++;
      return 'SizedBox(${innerContent})';
    });

    // Fix 2: Remove const from Padding with Theme.of(context)
    final constPaddingPattern = RegExp(
      r'const Padding\(',
      multiLine: true,
    );

    // We need to check if the Padding contains Theme.of(context) in its tree
    // For simplicity, we'll look ahead a reasonable amount
    content = content.replaceAllMapped(
      RegExp(r'const (Padding|EdgeInsets\.)', multiLine: true),
      (match) {
        final matchPos = match.start;
        final contextCheck = content.substring(
          matchPos,
          (matchPos + 500).clamp(0, content.length),
        );

        // Only remove const if Theme.of(context) appears nearby
        if (contextCheck.contains('Theme.of(context)')) {
          fileReplacements++;
          return match.group(1)!;
        }
        return match.group(0)!;
      },
    );

    // Fix 3: Replace surface70 with surfaceVariant
    final surface70Pattern = RegExp(
      r'\.surface70\b',
      multiLine: true,
    );

    if (content.contains(surface70Pattern)) {
      content = content.replaceAll(surface70Pattern, '.surfaceVariant');
      fileReplacements++;
    }

    // Fix 4: Remove const from Icon with Theme-based color
    content = content.replaceAllMapped(
      RegExp(r'const Icon\([^)]+\)', multiLine: true, dotAll: true),
      (match) {
        final iconContent = match.group(0)!;
        if (iconContent.contains('Theme.of(context)')) {
          fileReplacements++;
          return iconContent.replaceFirst('const ', '');
        }
        return iconContent;
      },
    );

    // Fix 5: Remove const from Text with Theme-based style
    content = content.replaceAllMapped(
      RegExp(r'const Text\([^)]+\)', multiLine: true, dotAll: true),
      (match) {
        final textContent = match.group(0)!;
        if (textContent.contains('Theme.of(context)')) {
          fileReplacements++;
          return textContent.replaceFirst('const ', '');
        }
        return textContent;
      },
    );

    if (content != originalContent) {
      file.writeAsStringSync(content);
      totalFilesFixed++;
      totalReplacements += fileReplacements;
      print('✅ Fixed $filePath');
      print('   Replacements: $fileReplacements');
    }
  }

  print('\n' + '=' * 50);
  print('Theme Error Fix Complete!');
  print('=' * 50);
  print('Files fixed: $totalFilesFixed');
  print('Total replacements: $totalReplacements');
  print('\nNote: Some const errors may require manual review');
  print('Run "flutter analyze" to check for remaining issues');
}
