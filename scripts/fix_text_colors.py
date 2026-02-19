#!/usr/bin/env python3
"""Fix text colors to be theme-aware (white in dark mode, black in light mode)"""

import os
import re
from pathlib import Path

def fix_text_colors(file_path):
    """Replace hardcoded text colors with theme-aware colors"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    changes = 0

    # Pattern 1: Colors.black or Colors.black87/black54/black45/black38/black26/black12
    patterns_to_fix = [
        # Direct Colors.black usage in TextStyle
        (r'color:\s*Colors\.black\b(?!\.)', 'color: Theme.of(context).colorScheme.onSurface'),
        (r'color:\s*Colors\.black87\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.87)'),
        (r'color:\s*Colors\.black54\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54)'),
        (r'color:\s*Colors\.black45\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)'),
        (r'color:\s*Colors\.black38\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)'),
        (r'color:\s*Colors\.black26\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.26)'),
        (r'color:\s*Colors\.black12\b', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)'),

        # Colors.white in text (should use onSurface for containers or surface for gradients)
        # We need to be careful here - white might be intentional on colored backgrounds
        # Only fix if it's clearly in a TextStyle context
    ]

    for pattern, replacement in patterns_to_fix:
        matches = re.findall(pattern, content)
        if matches:
            content = re.sub(pattern, replacement, content)
            changes += len(matches)

    # Pattern 2: Hardcoded Color values in TextStyle (hex colors)
    # Only fix common black/white colors
    hex_patterns = [
        (r'color:\s*Color\(0xFF000000\)', 'color: Theme.of(context).colorScheme.onSurface'),
        (r'color:\s*Color\(0xFF212121\)', 'color: Theme.of(context).colorScheme.onSurface'),
        (r'color:\s*Color\(0xFF424242\)', 'color: Theme.of(context).colorScheme.onSurfaceVariant'),
        (r'color:\s*Color\(0xFF757575\)', 'color: Theme.of(context).textTheme.bodySmall?.color'),
        (r'color:\s*Color\(0xFF9E9E9E\)', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)'),
        (r'color:\s*Color\(0xFFBDBDBD\)', 'color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)'),
    ]

    for pattern, replacement in hex_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        if matches:
            content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
            changes += len(matches)

    # Pattern 3: Text widgets without explicit color that rely on default black
    # Add color to Text widgets that don't have a style or have style without color
    # This is more complex and might need manual review

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True, changes

    return False, 0

def main():
    print("Fixing text colors to be theme-aware...\n")

    lib_dir = Path('sabiquun_app/lib')
    total_files_fixed = 0
    total_changes = 0

    # Find all .dart files
    for dart_file in lib_dir.rglob('*.dart'):
        # Skip generated files
        if '.g.dart' in str(dart_file) or '.freezed.dart' in str(dart_file):
            continue

        fixed, changes = fix_text_colors(dart_file)
        if fixed:
            print(f"Fixed {dart_file} ({changes} changes)")
            total_files_fixed += 1
            total_changes += changes

    print(f"\n{'='*60}")
    print(f"Total files fixed: {total_files_fixed}")
    print(f"Total color changes: {total_changes}")
    print(f"{'='*60}")
    print("\nNote: Some text colors might need manual review, especially:")
    print("- Text on colored backgrounds (should stay white/appropriate color)")
    print("- Brand colors that are intentional")
    print("- Status indicators (red, green, amber)")
    print("\nRun 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
