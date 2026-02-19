#!/usr/bin/env python3
"""Fix errors introduced by text color changes"""

import os
import re
from pathlib import Path

def fix_text_color_errors(file_path):
    """Fix const and nullable errors from text color changes"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = []

    # Fix 1: textTheme.bodySmall?.color with withValues (nullable issue)
    # Change: Theme.of(context).textTheme.bodySmall?.color
    # To: Theme.of(context).colorScheme.onSurfaceVariant
    pattern1 = r'Theme\.of\(context\)\.textTheme\.bodySmall\?\.color'
    if re.search(pattern1, content):
        content = re.sub(pattern1, 'Theme.of(context).colorScheme.onSurfaceVariant', content)
        changes.append('Fixed nullable textTheme.bodySmall')

    # Fix 2: Remove const from TextStyle with our new theme-aware colors
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # If line has const TextStyle and we see Theme.of(context) in next 10 lines
        if 'const TextStyle' in line and i < len(lines) - 1:
            lookahead = '\n'.join(lines[i:min(i+10, len(lines))])
            if ('Theme.of(context).colorScheme.onSurface' in lookahead or
                'Theme.of(context).colorScheme.onSurfaceVariant' in lookahead):
                line = line.replace('const TextStyle', 'TextStyle')
                if 'const TextStyle' not in line:  # Verify it was replaced
                    changes.append('Removed const from TextStyle')

        # If line has const Icon and we see Theme.of(context) in next 5 lines
        if 'const Icon' in line and i < len(lines) - 1:
            lookahead = '\n'.join(lines[i:min(i+5, len(lines))])
            if 'Theme.of(context).colorScheme' in lookahead:
                line = line.replace('const Icon', 'Icon')
                if 'const Icon' not in line:
                    changes.append('Removed const from Icon')

        # If line has const padding/SizedBox with theme colors nearby
        if ('const Padding' in line or 'const SizedBox' in line or 'const EdgeInsets' in line):
            lookahead = '\n'.join(lines[i:min(i+15, len(lines))])
            if 'Theme.of(context)' in lookahead:
                line = line.replace('const Padding', 'Padding')
                line = line.replace('const SizedBox', 'SizedBox')
                line = line.replace('const EdgeInsets', 'EdgeInsets')

        fixed_lines.append(line)
        i += 1

    content = '\n'.join(fixed_lines)

    # Fix 3: Undefined context in static/const contexts
    # Look for patterns where we're using Theme.of(context) but context isn't available
    # These usually need to be changed back or handled differently

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, []

def main():
    print("Fixing text color related errors...\n")

    lib_dir = Path('sabiquun_app/lib')
    total_files_fixed = 0
    total_changes = {}

    # Find all .dart files
    for dart_file in lib_dir.rglob('*.dart'):
        # Skip generated files
        if '.g.dart' in str(dart_file) or '.freezed.dart' in str(dart_file):
            continue

        fixed, changes = fix_text_color_errors(dart_file)
        if fixed:
            print(f"Fixed {dart_file}")
            total_files_fixed += 1
            for change in changes:
                total_changes[change] = total_changes.get(change, 0) + 1

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_files_fixed}")
    if total_changes:
        print(f"\nChanges by type:")
        for change_type, count in sorted(total_changes.items()):
            print(f"  - {change_type}: {count}")
    print(f"{'='*60}")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
