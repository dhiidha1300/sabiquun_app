# Documentation Navigation

## Quick Start

👉 **Start here:** [README.md](README.md) - Main project overview and navigation hub

## Documentation Structure

The project documentation has been refactored from a single 3,874-line file into a modular structure:

### 📋 Planning & Requirements (`docs/planning/`)
- [01-project-overview.md](docs/planning/01-project-overview.md) - Application purpose, goals, tech stack
- [02-user-roles.md](docs/planning/02-user-roles.md) - Detailed role-based access control (User, Supervisor, Cashier, Admin)
- [03-user-status.md](docs/planning/03-user-status.md) - Membership tiers and account statuses
- `04-future-enhancements.md` - Post-MVP roadmap (⏳ To be extracted)
- `05-checklist.md` - Pre-development checklist (⏳ To be extracted)

### 🎯 Core Features (`docs/features/`)
- `01-deed-system.md` - Daily deed tracking system (⏳ To be extracted)
- `02-penalty-system.md` - Financial penalty calculations (⏳ To be extracted)
- `03-excuse-system.md` - Excuse submission and approval (⏳ To be extracted)
- `04-payment-system.md` - Payment submission and FIFO application (⏳ To be extracted)
- `05-notification-system.md` - Multi-channel notification system (⏳ To be extracted)

### 🎨 User Interface (`docs/ui-ux/`)
- `01-authentication.md` - Login, signup, password flows (⏳ To be extracted)
- `02-user-screens.md` - User role screen specifications (⏳ To be extracted)
- `03-supervisor-screens.md` - Supervisor dashboard and tools (⏳ To be extracted)
- `04-cashier-screens.md` - Payment review interfaces (⏳ To be extracted)
- `05-admin-screens.md` - Admin management screens (⏳ To be extracted)

### 🗄️ Database & Backend (`docs/database/`)
- `01-schema.md` - Complete database schema (24 tables) (⏳ To be extracted)
- `02-business-logic.md` - Core calculations and algorithms (⏳ To be extracted)
- `03-api-endpoints.md` - REST API specifications (⏳ To be extracted)

### 🛠️ Technical (`docs/technical/`)
- `01-architecture.md` - System architecture (⏳ To be extracted)
- `02-authentication.md` - Security implementation (⏳ To be extracted)
- `03-state-management.md` - Flutter state management (⏳ To be extracted)
- `04-offline-support.md` - Offline-first capabilities (⏳ To be extracted)
- `05-testing.md` - Testing strategy (⏳ To be extracted)
- `06-deployment.md` - Infrastructure and CI/CD (⏳ To be extracted)
- `07-maintenance.md` - Maintenance procedures (⏳ To be extracted)
- `08-edge-cases.md` - Edge case handling (⏳ To be extracted)

## For Developers

### Getting Started
1. Read [README.md](README.md) for project overview
2. Review [User Roles](docs/planning/02-user-roles.md) to understand permissions
3. Study [User Status](docs/planning/03-user-status.md) for membership tiers
4. Check Database Schema (when extracted) for data structure
5. Review API Endpoints (when extracted) for backend contract

### For Specific Tasks

**Working on authentication?**
→ `docs/technical/02-authentication.md`, `docs/ui-ux/01-authentication.md`

**Implementing deed tracking?**
→ `docs/features/01-deed-system.md`, `docs/database/01-schema.md`

**Building payment system?**
→ `docs/features/04-payment-system.md`, `docs/database/02-business-logic.md`

**Designing admin screens?**
→ `docs/ui-ux/05-admin-screens.md`, `docs/planning/02-user-roles.md`

## Refactoring Status

**Progress:** 3/26 documents extracted (11.5%)

### ✅ Completed
- Main README navigation hub
- Project overview
- User roles and permissions
- User status and membership
- Directory structure
- Refactoring guide

### ⏳ In Progress
See [docs/REFACTORING_GUIDE.md](docs/REFACTORING_GUIDE.md) for:
- Extraction instructions
- Line number mappings
- Automation scripts
- Content standards

## Original Documentation

The original monolithic specification is archived at:
- **Location:** `docs/archive/project_detail_original.md`
- **Size:** 3,874 lines
- **Status:** Reference only, not actively maintained

## Contributing to Documentation

1. Check if a document exists for your topic
2. If creating new doc, follow naming conventions in [REFACTORING_GUIDE.md](docs/REFACTORING_GUIDE.md)
3. Update README.md navigation links
4. Add cross-references to related documents
5. Follow markdown formatting standards

## Quick Command Reference

### Extract a section from original
```bash
sed -n '133,227p' docs/archive/project_detail_original.md > docs/features/01-deed-system.md
```

### Search across all docs
```bash
grep -r "keyword" docs/
```

### Find TODO markers
```bash
grep -r "⏳\|TODO\|FIXME" docs/
```

## Documentation Principles

1. **DRY (Don't Repeat Yourself)** - Link to content, don't duplicate
2. **Single Source of Truth** - Each concept lives in one place
3. **Progressive Disclosure** - Overview in README, details in dedicated docs
4. **Navigation First** - Always provide way back to README
5. **Examples Included** - Show, don't just tell

## Need Help?

- **Can't find something?** Check [README.md](README.md) navigation
- **Want to add content?** See [REFACTORING_GUIDE.md](docs/REFACTORING_GUIDE.md)
- **Found broken link?** Create an issue or fix and commit
- **Unclear documentation?** Open an issue with questions

---

**Last Updated:** 2025-10-22
**Documentation Version:** 0.1 (Refactoring in progress)
