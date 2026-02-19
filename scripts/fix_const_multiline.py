#!/usr/bin/env python3
"""Fix multiline const TextStyle/Padding/EdgeInsets with Theme.of(context)"""

import os
import re
from pathlib import Path

def fix_const_in_file(file_path):
    """Remove const from TextStyle/Padding/EdgeInsets that use Theme.of(context)"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content

    # Pattern 1: const TextStyle( ... Theme.of(context) ... )
    # This handles multiline TextStyle declarations
    pattern1 = re.compile(
        r'const\s+(TextStyle\s*\([^)]*Theme\.of\(context\)[^)]*\))',
        re.DOTALL | re.MULTILINE
    )
    content = pattern1.sub(r'\1', content)

    # Pattern 2: const Padding( ... Theme.of(context) ... )
    pattern2 = re.compile(
        r'const\s+(Padding\s*\([^{]*\{[^}]*Theme\.of\(context\)[^}]*\}[^)]*\))',
        re.DOTALL | re.MULTILINE
    )
    content = pattern2.sub(r'\1', content)

    # Pattern 3: const EdgeInsets... near Theme.of(context)
    # Look for const EdgeInsets within 200 chars before Theme.of(context)
    lines = content.split('\n')
    fixed_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # Check if this line or nearby lines have both const EdgeInsets and Theme.of
        if 'const EdgeInsets' in line or 'const Padding' in line:
            # Look ahead up to 10 lines for Theme.of(context)
            lookahead = '\n'.join(lines[i:min(i+10, len(lines))])
            if 'Theme.of(context)' in lookahead:
                # Remove const from this line
                line = line.replace('const EdgeInsets', 'EdgeInsets')
                line = line.replace('const Padding', 'Padding')

        fixed_lines.append(line)
        i += 1

    content = '\n'.join(fixed_lines)

    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

def main():
    print("Fixing multiline const errors...\n")

    # Start from sabiquun_app/lib
    lib_dir = Path('sabiquun_app/lib')

    total_fixed = 0

    # Find all .dart files
    for dart_file in lib_dir.rglob('*.dart'):
        if fix_const_in_file(dart_file):
            print(f"Fixed {dart_file}")
            total_fixed += 1

    print(f"\n{'='*50}")
    print(f"Total files fixed: {total_fixed}")
    print(f"{'='*50}")
    print("Run 'flutter analyze' to verify")

if __name__ == '__main__':
    main()
