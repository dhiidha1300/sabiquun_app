#!/usr/bin/env python3
"""Final fix for const widgets containing Theme.of(context) in children"""

import os
import re
from pathlib import Path

def count_brackets(text):
    """Count opening and closing parentheses to find matching pairs"""
    count = 0
    for char in text:
        if char == '(':
            count += 1
        elif char == ')':
            count -= 1
            if count == 0:
                return True
    return False

def fix_file(file_path):
    """Remove const from widgets that have Theme.of(context) in their tree"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    lines = content.split('\n')

    # Find all lines with Theme.of(context)
    theme_lines = []
    for i, line in enumerate(lines):
        if 'Theme.of(context)' in line:
            theme_lines.append(i)

    # For each Theme.of(context) line, look backwards for const widgets
    for theme_line_idx in theme_lines:
        # Look up to 20 lines back for const keywords
        start_search = max(0, theme_line_idx - 20)

        for i in range(theme_line_idx, start_search - 1, -1):
            line = lines[i]

            # Check for const widget declarations
            if re.match(r'\s*const\s+(Expanded|Column|Row|Container|Padding|Center|Align|SizedBox)\s*\(', line):
                # Remove const from this line
                lines[i] = re.sub(r'(\s*)const\s+', r'\1', line, count=1)

    new_content = '\n'.join(lines)

    if new_content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True

    return False

def main():
    print("Running final const fix...\n")

    # Files with remaining errors
    error_files = [
        'sabiquun_app/lib/features/deeds/presentation/pages/my_reports_page.dart',
        'sabiquun_app/lib/features/deeds/presentation/pages/report_detail_page.dart',
        'sabiquun_app/lib/features/home/widgets/admin_menu_grid.dart',
        'sabiquun_app/lib/features/payments/presentation/pages/payment_analytics_page.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/approve_payment_dialog.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/balance_adjustment_dialog.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_card.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_details_modal.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/payment_filter_panel.dart',
        'sabiquun_app/lib/features/payments/presentation/widgets/reject_payment_dialog.dart',
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
