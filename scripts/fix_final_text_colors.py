#!/usr/bin/env python3
"""Fix all remaining hardcoded text colors to be theme-aware"""

import os
import re
from pathlib import Path

def fix_text_colors(file_path):
    """Replace hardcoded text colors with theme-aware equivalents"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Fix 1: AppColors.textPrimary -> Theme.of(context).colorScheme.onSurface
    pattern1 = r'AppColors\.textPrimary'
    replacement1 = r'Theme.of(context).colorScheme.onSurface'
    content, count1 = re.subn(pattern1, replacement1, content)
    changes += count1

    # Fix 2: AppColors.textSecondary -> Theme.of(context).colorScheme.onSurfaceVariant
    pattern2 = r'AppColors\.textSecondary'
    replacement2 = r'Theme.of(context).colorScheme.onSurfaceVariant'
    content, count2 = re.subn(pattern2, replacement2, content)
    changes += count2

    # Fix 3: AppColors.textHint -> Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
    pattern3 = r'AppColors\.textHint'
    replacement3 = r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)'
    content, count3 = re.subn(pattern3, replacement3, content)
    changes += count3

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, 0

def main():
    print("Fixing all remaining hardcoded text colors...\n")

    # Files that still have hardcoded text colors
    files_to_fix = [
        'sabiquun_app/lib/features/supervisor/presentation/pages/leaderboard_page.dart',
        'sabiquun_app/lib/features/payments/presentation/pages/payment_review_page.dart',
        'sabiquun_app/lib/features/notifications/presentation/pages/notifications_page.dart',
        'sabiquun_app/lib/features/deeds/presentation/pages/report_detail_page.dart',
        'sabiquun_app/lib/features/deeds/presentation/pages/my_reports_page.dart',
        'sabiquun_app/lib/features/user/presentation/pages/user_leaderboard_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/users_table_view.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/date_range_picker_widget.dart',
        'sabiquun_app/lib/features/admin/presentation/widgets/penalty_calculation_status_card.dart',
        'sabiquun_app/lib/features/admin/presentation/pages/user_management_page.dart',
        'sabiquun_app/lib/features/home/widgets/onboarding_card.dart',
        'sabiquun_app/lib/features/notifications/presentation/widgets/notification_item.dart',
        'sabiquun_app/lib/features/payments/presentation/pages/user_balance_detail_page.dart',
        'sabiquun_app/lib/features/payments/presentation/pages/payment_analytics_page.dart',
        'sabiquun_app/lib/shared/widgets/password_strength_indicator.dart',
    ]

    total_files_fixed = 0
    total_changes = 0

    for file_path in files_to_fix:
        if os.path.exists(file_path):
            fixed, changes = fix_text_colors(file_path)
            if fixed:
                print(f"Fixed {file_path} ({changes} replacements)")
                total_files_fixed += 1
                total_changes += changes
        else:
            print(f"Warning: File not found - {file_path}")

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_files_fixed}")
    print(f"Total changes: {total_changes}")
    print(f"{'='*60}")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
