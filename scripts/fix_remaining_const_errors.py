#!/usr/bin/env python3
"""Fix all remaining const errors with Theme.of(context)"""

import os
import re
from pathlib import Path

def fix_const_errors(file_path):
    """Remove const from all expressions containing Theme.of(context)"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    original_lines = lines.copy()
    modified = False

    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if line has 'const ' keyword
        if 'const ' in line:
            # Look ahead to check if Theme.of(context) appears in next 20 lines
            lookahead_end = min(i + 20, len(lines))
            lookahead = ''.join(lines[i:lookahead_end])

            if 'Theme.of(context)' in lookahead or 'colorScheme.onSurface' in lookahead:
                # Remove all instances of 'const ' from this line
                new_line = re.sub(r'\bconst\s+', '', line)
                if new_line != line:
                    lines[i] = new_line
                    modified = True

        i += 1

    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        return True

    return False

def main():
    print("Fixing remaining const errors...\n")

    # Specific files with errors
    error_files = [
        'sabiquun_app/lib/features/admin/presentation/pages/deed_management_page.dart',
        'sabiquun_app/lib/features/auth/presentation/pages/signup_page.dart',
        'sabiquun_app/lib/features/deeds/presentation/pages/my_reports_page.dart',
        'sabiquun_app/lib/features/deeds/presentation/pages/report_detail_page.dart',
        'sabiquun_app/lib/features/home/pages/user_home_content.dart',
        'sabiquun_app/lib/features/home/widgets/enhanced_profile_menu.dart',
        'sabiquun_app/lib/features/home/widgets/report_calendar_widget.dart',
        'sabiquun_app/lib/features/notifications/presentation/pages/notifications_page.dart',
        'sabiquun_app/lib/features/payments/presentation/pages/payment_review_page.dart',
        'sabiquun_app/lib/features/profile/pages/profile_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/pages/leaderboard_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/pages/user_detail_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/pages/user_reports_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/pages/users_at_risk_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/user_report_card.dart',
    ]

    total_fixed = 0

    for file_path in error_files:
        if os.path.exists(file_path):
            if fix_const_errors(file_path):
                print(f"Fixed {file_path}")
                total_fixed += 1
        else:
            print(f"Warning: File not found - {file_path}")

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_fixed}")
    print(f"{'='*60}")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
