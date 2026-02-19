import 'dart:io';

/// Fix remaining const TextStyle and other const errors with Theme.of(context)

void main() {
  print('Fixing remaining const errors...\n');

  final errorFiles = {
    'sabiquun_app/lib/features/admin/presentation/pages/notification_schedules_page.dart': [287],
    'sabiquun_app/lib/features/admin/presentation/pages/notification_templates_page.dart': [340],
    'sabiquun_app/lib/features/analytics/presentation/pages/user_analytics_dashboard_page.dart': [449],
    'sabiquun_app/lib/features/deeds/presentation/pages/my_reports_page.dart': [310, 446],
    'sabiquun_app/lib/features/deeds/presentation/pages/report_detail_page.dart': [268],
    'sabiquun_app/lib/features/home/pages/admin_home_content.dart': [380],
    'sabiquun_app/lib/features/home/pages/cashier_home_content.dart': [535, 982],
    'sabiquun_app/lib/features/home/pages/supervisor_home_content.dart': [169, 693],
    'sabiquun_app/lib/features/home/pages/user_home_content.dart': [731, 995],
    'sabiquun_app/lib/features/home/widgets/admin_menu_grid.dart': [199],
    'sabiquun_app/lib/features/home/widgets/report_calendar_widget.dart': [352],
    'sabiquun_app/lib/features/notifications/presentation/widgets/notification_bell.dart': [104],
    'sabiquun_app/lib/features/payments/presentation/pages/payment_analytics_page.dart': [756, 890, 1048],
    'sabiquun_app/lib/features/payments/presentation/pages/payment_review_page.dart': [339, 442],
  };

  int totalFixed = 0;

  for (final entry in errorFiles.entries) {
    final filePath = entry.key;
    final file = File(filePath);

    if (!file.existsSync()) {
      print('⚠️  File not found: $filePath');
      continue;
    }

    String content = file.readAsStringSync();
    final lines = content.split('\n');

    bool fileModified = false;
    for (final lineNum in entry.value) {
      if (lineNum > 0 && lineNum <= lines.length) {
        final lineIndex = lineNum - 1;
        final line = lines[lineIndex];

        // Fix const TextStyle( with Theme.of(context)
        if (line.contains('const TextStyle(') && content.substring(0, content.indexOf(line)).length < content.length) {
          // Find the start of this const TextStyle block
          int startIndex = content.indexOf(line);
          if (startIndex != -1) {
            // Look ahead up to 200 chars to see if Theme.of(context) appears
            String lookAhead = content.substring(startIndex, (startIndex + 200).clamp(0, content.length));
            if (lookAhead.contains('Theme.of(context)')) {
              content = content.replaceFirst(
                RegExp(r'const TextStyle\(', multiLine: false),
                'TextStyle(',
                startIndex,
              );
              fileModified = true;
              totalFixed++;
            }
          }
        }

        // Fix const Padding/EdgeInsets with Theme.of(context)
        if (line.contains('const ') && (line.contains('Padding') || line.contains('EdgeInsets'))) {
          int startIndex = content.indexOf(line);
          if (startIndex != -1) {
            String lookAhead = content.substring(startIndex, (startIndex + 300).clamp(0, content.length));
            if (lookAhead.contains('Theme.of(context)')) {
              // Remove const from this line
              lines[lineIndex] = line.replaceFirst('const ', '');
              content = lines.join('\n');
              fileModified = true;
              totalFixed++;
            }
          }
        }
      }
    }

    if (fileModified) {
      file.writeAsStringSync(content);
      print('✅ Fixed $filePath');
    }
  }

  print('\n' + '=' * 50);
  print('Total fixes applied: $totalFixed');
  print('=' * 50);
  print('Run "flutter analyze" to verify');
}
