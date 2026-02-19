#!/usr/bin/env python3
"""Comprehensive fix for all text colors to be theme-aware"""

import os
import re
from pathlib import Path

def fix_all_text_colors(file_path):
    """Replace all hardcoded text colors with theme-aware colors"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = []

    # Pattern 1: Colors.grey[X] in text contexts
    grey_mappings = {
        r'color:\s*Colors\.grey\[50\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)',
        r'color:\s*Colors\.grey\[100\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)',
        r'color:\s*Colors\.grey\[200\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)',
        r'color:\s*Colors\.grey\[300\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)',
        r'color:\s*Colors\.grey\[400\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)',
        r'color:\s*Colors\.grey\[500\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)',
        r'color:\s*Colors\.grey\[600\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)',
        r'color:\s*Colors\.grey\[700\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)',
        r'color:\s*Colors\.grey\[800\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)',
        r'color:\s*Colors\.grey\[900\]': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9)',
        r'color:\s*Colors\.grey(?!\.|\[)': 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    }

    for pattern, replacement in grey_mappings.items():
        matches = list(re.finditer(pattern, content))
        if matches:
            content = re.sub(pattern, replacement, content)
            changes.append(f"Grey colors: {len(matches)}")

    # Pattern 2: Colors.black variants
    black_mappings = {
        r'color:\s*Colors\.black(?!\.|\d)': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*Colors\.black87': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)',
        r'color:\s*Colors\.black54': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)',
        r'color:\s*Colors\.black45': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)',
        r'color:\s*Colors\.black38': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)',
        r'color:\s*Colors\.black26': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26)',
        r'color:\s*Colors\.black12': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)',
    }

    for pattern, replacement in black_mappings.items():
        matches = list(re.finditer(pattern, content))
        if matches:
            content = re.sub(pattern, replacement, content)
            changes.append(f"Black colors: {len(matches)}")

    # Pattern 3: AppColors.textPrimary, textSecondary, etc.
    app_colors_mappings = {
        r'color:\s*AppColors\.textPrimary': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*AppColors\.textSecondary': 'color: Theme.of(context).textTheme.bodySmall?.color',
        r'color:\s*AppColors\.textHint': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)',
    }

    for pattern, replacement in app_colors_mappings.items():
        matches = list(re.finditer(pattern, content))
        if matches:
            content = re.sub(pattern, replacement, content)
            changes.append(f"AppColors: {len(matches)}")

    # Pattern 4: Common hex color values for text
    hex_mappings = {
        # Black shades
        r'color:\s*Color\(0xFF000000\)': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*Color\(0xff000000\)': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*Color\(0xFF212121\)': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*Color\(0xff212121\)': 'color: Theme.of(context).colorScheme.onSurface',
        r'color:\s*Color\(0xFF424242\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)',
        r'color:\s*Color\(0xff424242\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)',
        r'color:\s*Color\(0xFF616161\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.74)',
        r'color:\s*Color\(0xff616161\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.74)',
        r'color:\s*Color\(0xFF757575\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)',
        r'color:\s*Color\(0xff757575\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)',
        r'color:\s*Color\(0xFF9E9E9E\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)',
        r'color:\s*Color\(0xff9e9e9e\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)',
        r'color:\s*Color\(0xFFBDBDBD\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)',
        r'color:\s*Color\(0xffbdbdbd\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)',
        r'color:\s*Color\(0xFFE0E0E0\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)',
        r'color:\s*Color\(0xffe0e0e0\)': 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)',
    }

    for pattern, replacement in hex_mappings.items():
        matches = list(re.finditer(pattern, content))
        if matches:
            content = re.sub(pattern, replacement, content)
            changes.append(f"Hex colors: {len(matches)}")

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, []

def main():
    print("Comprehensive text color fix...\n")

    lib_dir = Path('sabiquun_app/lib')
    total_files_fixed = 0
    total_changes = 0
    change_types = {}

    # Find all .dart files
    for dart_file in lib_dir.rglob('*.dart'):
        # Skip generated files
        if '.g.dart' in str(dart_file) or '.freezed.dart' in str(dart_file):
            continue

        fixed, changes = fix_all_text_colors(dart_file)
        if fixed:
            change_count = sum(int(c.split(':')[1].strip()) for c in changes if ':' in c)
            print(f"Fixed {dart_file} ({change_count} changes: {', '.join(changes)})")
            total_files_fixed += 1
            total_changes += change_count

            # Track change types
            for change in changes:
                change_type = change.split(':')[0]
                change_types[change_type] = change_types.get(change_type, 0) + 1

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_files_fixed}")
    print(f"Total changes: {total_changes}")
    print(f"\nChanges by type:")
    for change_type, count in sorted(change_types.items()):
        print(f"  - {change_type}: {count} files")
    print(f"{'='*60}")
    print("\nImportant notes:")
    print("✓ Black/grey text colors now adapt to theme")
    print("✓ Text will be dark in light mode, light in dark mode")
    print("! Colors on gradient backgrounds are intentionally preserved")
    print("! Status colors (red, green, amber) remain unchanged")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
