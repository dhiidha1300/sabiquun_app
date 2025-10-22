# Documentation Refactoring Guide

This guide explains the documentation restructuring and provides a roadmap for completing the remaining extractions.

## Overview

The original `project_detail.md` (3,874 lines) has been refactored into a modular documentation structure for better maintainability and navigation.

## Completed Refactoring

### ✅ Created Files

1. **README.md** - Main navigation hub with project overview
2. **docs/planning/01-project-overview.md** - Application purpose and goals
3. **docs/planning/02-user-roles.md** - Role-based access control details
4. **docs/planning/03-user-status.md** - Membership tiers and account statuses

### ✅ Created Directory Structure

```
docs/
├── planning/          # Requirements and planning docs
├── features/          # Core feature documentation
├── database/          # Database schema and API docs
├── ui-ux/            # User interface specifications
├── technical/        # Technical implementation guides
└── archive/          # Original unrefactored documents
```

## Remaining Extractions

Below is a mapping of sections from `project_detail.md` to their target files:

### Planning & Requirements

| Target File | Source Lines | Section Title | Status |
|------------|--------------|---------------|---------|
| `04-future-enhancements.md` | 3698-3750 | Future Enhancements (Post-MVP) | ⏳ Pending |
| `05-checklist.md` | 3753-3796 | Final Checklist Before Development | ⏳ Pending |

### Core Features

| Target File | Source Lines | Section Title | Status |
|------------|--------------|---------------|---------|
| `01-deed-system.md` | 133-227 | Deed System (Core Feature) | ⏳ Pending |
| `02-penalty-system.md` | 228-295 | Penalty System | ⏳ Pending |
| `03-excuse-system.md` | 296-362 | Excuse System | ⏳ Pending |
| `04-payment-system.md` | 363-498 | Payment System | ⏳ Pending |
| `05-notification-system.md` | 499-683 | Notification System | ⏳ Pending |

### UI/UX Screens

| Target File | Source Lines | Section Title | Status |
|------------|--------------|---------------|---------|
| `01-authentication.md` | 685-730 | Authentication Screens | ⏳ Pending |
| `02-user-screens.md` | 731-1025 | Normal User Screens | ⏳ Pending |
| `03-supervisor-screens.md` | 1043-1199 | Supervisor Screens | ⏳ Pending |
| `04-cashier-screens.md` | 1200-1288 | Cashier Screens | ⏳ Pending |
| `05-admin-screens.md` | 1289-1776 | Admin Screens | ⏳ Pending |

### Database & Backend

| Target File | Source Lines | Section Title | Status |
|------------|--------------|---------------|---------|
| `01-schema.md` | 1778-2318 | Database Schema (Complete) | ⏳ Pending |
| `02-business-logic.md` | 2321-2640 | Key Business Logic & Calculations | ⏳ Pending |
| `03-api-endpoints.md` | 2641-3100 | Backend API Endpoints | ⏳ Pending |

### Technical Documentation

| Target File | Source Lines | Section Title | Status |
|------------|--------------|---------------|---------|
| `01-architecture.md` | 3101-3200 | State Management, Architecture | ⏳ Pending |
| `02-authentication.md` | 3201-3280 | Authentication & Security | ⏳ Pending |
| `03-state-management.md` | 3101-3150 | State Management | ⏳ Pending |
| `04-offline-support.md` | 3281-3350 | Offline Support | ⏳ Pending |
| `05-testing.md` | 3351-3570 | Testing Strategy | ⏳ Pending |
| `06-deployment.md` | 3571-3644 | Deployment & Hosting | ⏳ Pending |
| `07-maintenance.md` | 3645-3697 | Maintenance & Support | ⏳ Pending |
| `08-edge-cases.md` | Various | Edge Cases & Error Handling | ⏳ Pending |

## Extraction Instructions

### Quick Extraction Script

Use this bash script to extract specific line ranges:

```bash
#!/bin/bash
# extract_section.sh

if [ $# -ne 4 ]; then
    echo "Usage: $0 <start_line> <end_line> <output_file> <section_title>"
    exit 1
fi

START=$1
END=$2
OUTPUT=$3
TITLE=$4

# Extract lines from original file
sed -n "${START},${END}p" ../project_detail.md > /tmp/section_temp.md

# Create file with header
cat > "$OUTPUT" << EOF
# $TITLE

$(cat /tmp/section_temp.md)

---

[← Back to Main README](../../README.md)
EOF

echo "✅ Created: $OUTPUT"
```

**Usage Example:**
```bash
cd docs/features
../extract_section.sh 133 227 "01-deed-system.md" "Deed System"
```

### Manual Extraction Steps

For each remaining file:

1. **Read the source section** from `project_detail.md`
   ```bash
   sed -n '133,227p' project_detail.md
   ```

2. **Create the target file** in appropriate directory

3. **Add markdown header** with section title

4. **Clean up formatting:**
   - Fix any table formatting issues
   - Ensure code blocks have proper language tags
   - Add proper heading levels (adjust if needed)
   - Remove any duplicate section numbers

5. **Add navigation footer:**
   ```markdown
   ---
   [← Back to Main README](../../README.md) | [Related Doc →](../path/to/related.md)
   ```

6. **Verify links** in the main README.md point to the new file

### Content Enhancement Tips

When extracting, consider:

- **Add examples** where helpful
- **Include diagrams** for complex workflows (use Mermaid)
- **Cross-reference** related documents
- **Add warnings** for important caveats
- **Include database field references** where applicable

## Verification Checklist

After creating each document:

- [ ] File created in correct directory
- [ ] Proper markdown formatting
- [ ] Navigation links added
- [ ] Code blocks have language tags
- [ ] Tables formatted correctly
- [ ] Cross-references updated
- [ ] Linked from README.md
- [ ] No duplicate content

## Documentation Standards

### File Naming
- Use lowercase with hyphens: `deed-system.md`
- Number files for logical order: `01-deed-system.md`
- Use descriptive names, not abbreviations

### Headings
- Use `#` for main title (once per document)
- Use `##` for major sections
- Use `###` for subsections
- Use `####` sparingly, only when needed

### Code Blocks
Always specify language:
```markdown
```javascript
// JavaScript code
```

```sql
-- SQL code
```
```

### Tables
Use markdown tables with alignment:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Value    | Value    | Value    |
```

### Links
- Use relative links within docs: `[Link](../features/deed-system.md)`
- Use descriptive link text, not "click here"
- Verify all links after creation

## Original Document Location

The original `project_detail.md` will be moved to `docs/archive/` once refactoring is complete.

**Command:**
```bash
mv project_detail.md docs/archive/project_detail_original.md
```

## Benefits of Refactoring

### Before (Single File)
- ❌ 3,874 lines in one file
- ❌ Difficult to navigate
- ❌ Hard to maintain
- ❌ Slow to load/search
- ❌ Merge conflicts likely

### After (Modular Structure)
- ✅ ~20 focused documents
- ✅ Easy navigation via README
- ✅ Quick to find specific information
- ✅ Easier to update individual sections
- ✅ Better collaboration (fewer conflicts)
- ✅ Clear ownership of sections

## Contributing

When adding new documentation:

1. Determine the appropriate directory
2. Follow the numbering scheme
3. Update the main README.md navigation
4. Add cross-references to related docs
5. Follow the documentation standards above

## Quick Reference: Directory Purpose

- **planning/** - Requirements, roles, business rules, roadmap
- **features/** - Individual feature specifications (deed, penalty, payment, etc.)
- **database/** - Schema, relationships, business logic, API endpoints
- **ui-ux/** - Screen layouts, user flows, UI components
- **technical/** - Architecture, security, testing, deployment
- **archive/** - Historical/deprecated documentation

## Status Dashboard

### Overall Progress

- **Planning Docs**: 3/5 complete (60%)
- **Feature Docs**: 0/5 complete (0%)
- **UI/UX Docs**: 0/5 complete (0%)
- **Database Docs**: 0/3 complete (0%)
- **Technical Docs**: 0/8 complete (0%)

**Total**: 3/26 documents (11.5% complete)

### Next Priority

Focus on completing these first for maximum development value:

1. ✅ `database/01-schema.md` - Developers need this first
2. ✅ `features/01-deed-system.md` - Core functionality
3. ✅ `features/02-penalty-system.md` - Core functionality
4. ✅ `database/02-business-logic.md` - Critical algorithms
5. ✅ `database/03-api-endpoints.md` - API contract

## Automation Opportunity

Consider creating a Python script to automate extraction:

```python
#!/usr/bin/env python3
import sys

# Mapping of sections to extract
sections = {
    'deed-system': (133, 227, 'Deed System'),
    'penalty-system': (228, 295, 'Penalty System'),
    # ... more mappings
}

def extract_section(section_key):
    start, end, title = sections[section_key]
    # Read lines, create file, add formatting
    pass

if __name__ == '__main__':
    extract_section(sys.argv[1])
```

---

**Document Status**: Living Document
**Last Updated**: 2025-10-22
**Maintained By**: Development Team
