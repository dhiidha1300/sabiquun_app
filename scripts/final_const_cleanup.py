#!/usr/bin/env python3
"""Final cleanup of all const errors with Theme.of(context)"""

import os
import re

def fix_file(file_path):
    """Remove const from all widgets/expressions containing Theme.of(context)"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    modified = False
    i = 0
    while i < len(lines):
        line = lines[i]

        # If line contains 'const' and we find Theme.of(context) in next 15 lines
        if 'const ' in line and i < len(lines) - 1:
            # Look ahead to see if Theme.of(context) appears soon
            lookahead = ''.join(lines[i:min(i+15, len(lines))])
            if 'Theme.of(context)' in lookahead:
                # Remove const from this line
                new_line = re.sub(r'\bconst\s+', '', line, count=1)
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
    print("Final const cleanup...\n")

    error_files = [
        'sabiquun_app/lib/features/payments/presentation/widgets/balance_adjustment_dialog.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_card.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_details_modal.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_filter_panel.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/reject_payment_dialog.dart',
        'sabiquun_app/lib/features/settings/pages/edit_profile_page.dart',
        'sabiquun_app/lib/features/settings/pages/theme_settings_page.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/date_range_picker_widget.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/filter_bottom_sheet.dart',
        'sabiquun_app/lib/features/supervisor/presentation/widgets/users_table_view.dart',
        'sabiquun_app/lib/features/user/presentation/pages/user_leaderboard_page.dart',
    ]

    total_fixed = 0

    for file_path in error_files:
        if os.path.exists(file_path):
            if fix_file(file_path):
                print(f"Fixed {file_path}")
                total_fixed += 1
        else:
            print(f"Warning: File not found - {file_path}")

    print(f"\n{'='*50}")
    print(f"Total files fixed: {total_fixed}")
    print(f"{'='*50}")
    print("Run 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
