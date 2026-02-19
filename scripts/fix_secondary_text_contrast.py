#!/usr/bin/env python3
"""Fix secondary text color contrast by using onSurface with alpha instead of onSurfaceVariant"""

import os
import re
from pathlib import Path

def fix_secondary_text_contrast(file_path):
    """Replace onSurfaceVariant with onSurface.withValues(alpha: 0.7) for better contrast"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Fix: Theme.of(context).colorScheme.onSurfaceVariant -> Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
    # But we need to be careful not to replace it when it's already part of a withValues expression

    # Pattern 1: Simple onSurfaceVariant without any following withValues
    pattern1 = r'Theme\.of\(context\)\.colorScheme\.onSurfaceVariant(?!\s*\.withValues)'
    replacement1 = r'Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)'
    content, count1 = re.subn(pattern1, replacement1, content)
    changes += count1

    # Pattern 2: onSurfaceVariant with .withValues(alpha: X) -> change to onSurface.withValues(alpha: 0.7 * X)
    # For simplicity, we'll just make these onSurface with the existing alpha
    pattern2 = r'Theme\.of\(context\)\.colorScheme\.onSurfaceVariant\.withValues\(alpha:\s*([\d.]+)\)'

    def replace_with_adjusted_alpha(match):
        alpha = float(match.group(1))
        # Adjust alpha to be darker - multiply by 1.3 but cap at 0.9
        new_alpha = min(alpha * 1.3, 0.9)
        return f'Theme.of(context).colorScheme.onSurface.withValues(alpha: {new_alpha:.1f})'

    content, count2 = re.subn(pattern2, replace_with_adjusted_alpha, content)
    changes += count2

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, 0

def main():
    print("Fixing secondary text color contrast in light mode...\n")

    lib_dir = Path('sabiquun_app/lib')
    total_files_fixed = 0
    total_changes = 0

    # Find all .dart files
    for dart_file in lib_dir.rglob('*.dart'):
        # Skip generated files
        if '.g.dart' in str(dart_file) or '.freezed.dart' in str(dart_file):
            continue

        fixed, changes = fix_secondary_text_contrast(dart_file)
        if fixed:
            print(f"Fixed {dart_file} ({changes} replacements)")
            total_files_fixed += 1
            total_changes += changes

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_files_fixed}")
    print(f"Total changes: {total_changes}")
    print(f"{'='*60}")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
