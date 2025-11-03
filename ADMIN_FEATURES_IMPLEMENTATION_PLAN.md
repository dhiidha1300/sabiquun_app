# Admin Features Implementation Plan

This document provides a comprehensive roadmap for completing the remaining admin features in the Sabiquun App. Use this plan to guide implementation in future conversations.

---

## Project Status Overview

### ✅ Completed Admin Features (Phases 1-4)

#### Phase 1: User Management (COMPLETE)
- ✅ User approval/rejection workflow
- ✅ User listing with filters (Pending, Active, Suspended, Deactivated)
- ✅ User profile editing (name, email, phone, role, membership, status)
- ✅ Role assignment (User, Supervisor, Cashier, Admin)
- ✅ User search functionality
- ✅ Statistics display (member since, reports, compliance, balance)

**Files:**
- `lib/features/admin/presentation/pages/user_management_page.dart`
- `lib/features/admin/presentation/pages/user_edit_page.dart`

#### Phase 2: Analytics Dashboard (COMPLETE)
- ✅ User metrics (pending, active, at risk, new registrations)
- ✅ Deed metrics (total deeds, compliance rate, average per user)
- ✅ Financial metrics (outstanding balance, pending payments, penalties)
- ✅ Real-time data loading with BLoC pattern
- ✅ Integration with admin home page

**Files:**
- `lib/features/admin/presentation/pages/analytics_dashboard_page.dart`
- `lib/features/home/pages/admin_home_content.dart` (analytics integration)

#### Phase 3: Deed Management (COMPLETE)
- ✅ View all deed templates (Fara'id and Sunnah)
- ✅ Add new deed templates
- ✅ Edit existing deed templates
- ✅ Activate/deactivate deeds
- ✅ Delete custom deeds (system defaults locked)
- ✅ Reorder deeds with drag handles
- ✅ Daily target auto-calculation
- ✅ Impact warnings for deed changes

**Files:**
- `lib/features/admin/presentation/pages/deed_management_page.dart`
- `lib/features/admin/data/models/deed_template_model.dart`

#### Phase 4: Audit Log Viewer (COMPLETE)
- ✅ Comprehensive audit log viewing
- ✅ Filtering by action type, entity type, performer, date range
- ✅ Detail view for each log entry (old/new values)
- ✅ CSV export to clipboard
- ✅ 7-day default view with date range customization
- ✅ Integration with admin home quick actions

**Files:**
- `lib/features/admin/presentation/pages/audit_log_page.dart`
- `lib/features/admin/data/models/audit_log_model.dart`

#### Phase 5: System Settings (COMPLETE)
- ✅ Basic settings page structure
- ✅ General Settings Tab (fully editable)
- ✅ Payment Settings Tab (organization name, receipt footer with live preview)
- ✅ Notification Settings Tab (Mailgun email, FCM push with secure inputs)
- ✅ App Settings Tab (version control, force update, platform-specific versions)
- ✅ Reason field for audit trail
- ✅ Change detection and validation
- ✅ BLoC integration for saving

**Files:**
- `lib/features/admin/presentation/pages/system_settings_page.dart`
- `lib/features/admin/presentation/widgets/general_settings_tab.dart`
- `lib/features/admin/presentation/widgets/payment_settings_tab.dart`
- `lib/features/admin/presentation/widgets/notification_settings_tab.dart`
- `lib/features/admin/presentation/widgets/app_settings_tab.dart`
- `lib/features/admin/domain/entities/system_settings_entity.dart`

#### Phase 6: Notification Management System (COMPLETE)
- ✅ Complete backend infrastructure (entities, models, events, states, bloc handlers)
- ✅ Notification Templates Management
  - ✅ Template listing grouped by notification type
  - ✅ Create/edit/delete templates with validation
  - ✅ Email support (subject + body fields)
  - ✅ Toggle template enabled/disabled status
  - ✅ System default templates protection (cannot delete)
  - ✅ Filter by type and active status
- ✅ Notification Schedules Management
  - ✅ Schedule listing with template details
  - ✅ Create/edit/delete schedules
  - ✅ Time picker integration
  - ✅ Frequency selector (daily/weekly/monthly/once)
  - ✅ Day-of-week selector for weekly schedules
  - ✅ Toggle schedule active/inactive
- ✅ Manual Notification Sender
  - ✅ Custom notification composer
  - ✅ User selection with multi-select
  - ✅ Search and filter users by status and role
  - ✅ Send immediate notifications to selected users
  - ✅ Visual user cards with status badges
- ✅ Repository and datasource implementation (13 methods)
- ✅ BLoC event handlers (13 handlers)
- ✅ Auto-reload after actions
- ✅ Navigation integration

**Files:**
- `lib/features/admin/domain/entities/notification_template_entity.dart`
- `lib/features/admin/domain/entities/notification_schedule_entity.dart`
- `lib/features/admin/data/models/notification_template_model.dart`
- `lib/features/admin/data/models/notification_schedule_model.dart`
- `lib/features/admin/presentation/pages/notification_templates_page.dart` (650+ lines)
- `lib/features/admin/presentation/pages/notification_schedules_page.dart`
- `lib/features/admin/presentation/pages/manual_notification_page.dart`
- `lib/features/admin/presentation/bloc/admin_bloc.dart` (13 new handlers)
- `lib/features/admin/presentation/bloc/admin_event.dart` (11 new events)
- `lib/features/admin/presentation/bloc/admin_state.dart` (13 new states)
- `lib/features/admin/data/datasources/admin_remote_datasource.dart` (13 new methods)
- `lib/features/admin/data/repositories/admin_repository_impl.dart` (13 new implementations)
- `lib/features/admin/domain/repositories/admin_repository.dart` (13 new method signatures)
- `lib/core/navigation/app_router.dart` (3 new routes)
- `lib/features/home/pages/admin_home_content.dart` (added Notifications quick action)

**Database Migration Required:**
- `database_migrations/fix_notification_system.sql` - **MUST BE RUN IN SUPABASE**
  - Adds `email_subject` and `email_body` columns to `notification_templates`
  - Creates RLS policies for `notification_templates` table
  - Creates RLS policies for `notification_schedules` table
  - Creates RLS policies for `notifications_log` table
  - Seeds 6 default notification templates

**Documentation:**
- `NOTIFICATION_SYSTEM_FIXES.md` - Complete bug fix documentation
- `NOTIFICATION_ERRORS_COMPLETE_FIX.md` - Comprehensive troubleshooting guide

#### Phase 7: Excuse Management System (COMPLETE)
- ✅ Complete backend infrastructure (entity, model, events, states, bloc handlers)
- ✅ Datasource methods (getExcuses, getExcuseById, approve, reject, bulk operations)
- ✅ Repository implementation
- ✅ Excuse management UI with filtering (All/Pending/Approved/Rejected)
- ✅ Excuse cards with user info, type, date, affected deeds
- ✅ Detail dialog with full information
- ✅ Approve/reject functionality with reason inputs
- ✅ Bulk operations (select multiple, bulk approve/reject)
- ✅ Auto-reload after actions
- ✅ Comprehensive audit logging
- ✅ Navigation integration

**Files:**
- `lib/features/admin/domain/entities/excuse_entity.dart`
- `lib/features/admin/data/models/excuse_model.dart`
- `lib/features/admin/presentation/pages/excuse_management_page.dart`
- `lib/features/admin/presentation/bloc/admin_bloc.dart` (6 new handlers)
- `lib/features/admin/presentation/bloc/admin_event.dart` (6 new events)
- `lib/features/admin/presentation/bloc/admin_state.dart` (6 new states)
- `lib/features/admin/data/datasources/admin_remote_datasource.dart` (6 new methods)
- `lib/features/admin/data/repositories/admin_repository_impl.dart` (6 new implementations)
- `lib/features/admin/domain/repositories/admin_repository.dart` (6 new method signatures)
- `lib/core/navigation/app_router.dart` (added route)
- `lib/features/home/pages/admin_home_content.dart` (updated navigation)

#### Phase 9: Report Management (COMPLETE)
- ✅ Complete backend infrastructure (3 datasource methods, repository, BLoC)
- ✅ Reused existing entities from deeds feature (DeedReportEntity, DeedEntryEntity)
- ✅ Report Management Page
  - ✅ Advanced search panel with filters (user ID, date range, status)
  - ✅ Report cards with visual stats (total deeds, Fara'id, Sunnah, completion %)
  - ✅ Status badges (Draft/Submitted)
  - ✅ Pull-to-refresh support
  - ✅ Empty states and loading indicators
  - ✅ Tap to navigate to edit page
- ✅ Report Edit Page
  - ✅ Warning banner for admin override
  - ✅ Report information display (date, user ID, status, submission time)
  - ✅ Deed template loading from database (name and value type)
  - ✅ Smart input controls:
    - ✅ Checkboxes for binary deeds (9 deeds: Fajr, Duha, Dhuhr, Juz, Asr, Maghrib, Isha, Athkar, Witr)
    - ✅ Sliders for fractional deeds (Sunnah Prayers with 0.1 increments)
  - ✅ Real-time summary calculation (original/new totals, difference)
  - ✅ Impact checklist display
  - ✅ Required reason field with validation
  - ✅ Confirmation dialog before saving
  - ✅ Automatic penalty recalculation on backend
  - ✅ Audit logging with proper column names
- ✅ Repository and datasource implementation (3 methods)
- ✅ BLoC event handlers (3 handlers)
- ✅ Navigation integration with GoRouter

**Files:**
- `lib/features/admin/presentation/pages/report_management_page.dart` (450+ lines)
- `lib/features/admin/presentation/pages/report_edit_page.dart` (520+ lines)
- `lib/features/admin/presentation/bloc/admin_bloc.dart` (3 new handlers)
- `lib/features/admin/presentation/bloc/admin_event.dart` (3 new events)
- `lib/features/admin/presentation/bloc/admin_state.dart` (4 new states)
- `lib/features/admin/data/datasources/admin_remote_datasource.dart` (3 new methods)
- `lib/features/admin/data/repositories/admin_repository_impl.dart` (3 new implementations)
- `lib/features/admin/domain/repositories/admin_repository.dart` (3 new method signatures)
- `lib/core/navigation/app_router.dart` (2 new routes)
- `lib/features/home/pages/admin_home_content.dart` (added Reports quick action)
- `lib/features/deeds/data/models/deed_report_model.dart` (fixed toEntity to convert entries)

**Database Migrations Required:**
- `database_migrations/fix_deed_entries_rls.sql` - **MUST BE RUN IN SUPABASE**
  - Enables RLS on deed_entries table
  - Creates 5 comprehensive policies for admins and users
  - Allows admins to manage all deed entries
  - Allows users to manage their own deed entries
- `database_migrations/add_admin_penalty_policy.sql` - **MUST BE RUN IN SUPABASE**
  - Adds admin permission to penalties table
  - Allows admins to delete and recreate penalties during report edits
  - Does not affect existing user policies

**Bug Fixes Applied:**
- Fixed navigation to use GoRouter's `context.push()` instead of `Navigator.pushNamed()`
- Fixed audit log column names: `action` → `action_type`, `old_values` → `old_value`, `new_values` → `new_value`
- Fixed deed entries loading by fetching separately and combining with report
- Fixed DeedReportModel.toEntity() to properly convert DeedEntryModel to DeedEntryEntity
- Added onChanged to reason TextField to trigger save button state updates
- Fixed RLS policies for deed_entries and penalties tables

---

## 🚧 Remaining Admin Features to Implement

---

### Phase 8: Penalty Management (MEDIUM PRIORITY)

**Objective:** Manual penalty operations for corrections and adjustments

**Sub-tasks:**

1. **Penalty Management Page** (NEW)
   - [ ] User search interface
   - [ ] User penalty overview
     - [ ] User info card (name, membership, balance)
     - [ ] Penalty history tabs (All, Unpaid, Paid, Waived)
     - [ ] Penalty cards with details
   - [ ] Manual penalty actions
     - [ ] Add penalty (manual)
     - [ ] Edit penalty amount
     - [ ] Waive penalty
     - [ ] Remove penalty (delete)
   - [ ] Bulk operations
     - [ ] Select multiple penalties
     - [ ] Bulk waive
     - [ ] Bulk remove

2. **Penalty Action Dialogs** (NEW)
   - [ ] Add penalty form
     - [ ] Date picker
     - [ ] Amount input
     - [ ] Reason (required)
     - [ ] Impact preview (new balance)
   - [ ] Edit amount form
     - [ ] New amount input
     - [ ] Reason for change (required)
     - [ ] Difference calculation
   - [ ] Waive penalty confirmation
     - [ ] Waiver reason (required)
     - [ ] Actions checklist
     - [ ] Balance preview
   - [ ] Remove penalty confirmation
     - [ ] Removal reason (required)
     - [ ] Permanence warning
     - [ ] Balance preview

**Technical Requirements:**
- Supabase table: `penalties` (exists)
- Balance recalculation on every operation
- Audit log creation for all actions
- User notification on penalty adjustment
- Prevent deletion of penalties linked to payments

**Files to Create:**
- `lib/features/admin/presentation/pages/penalty_management_page.dart`
- `lib/features/admin/data/models/penalty_model.dart`
- Update: `lib/features/admin/data/datasources/admin_remote_datasource.dart` (penalty CRUD)
- Update: `lib/features/admin/presentation/bloc/admin_bloc.dart` (penalty events/states)

**Estimated Complexity:** MEDIUM (3-4 hours)

---

### Phase 10: Rest Days Management (MEDIUM PRIORITY)
     - [ ] Status filter (submitted, draft)
     - [ ] Search button
   - [ ] Results list
     - [ ] Report cards (date, user, score, penalty)
     - [ ] Click to edit

2. **Report Edit Screen** (NEW)
   - [ ] Warning banner (admin override notice)
   - [ ] Deed inputs
     - [ ] Checkboxes for binary deeds
     - [ ] Sliders for fractional deeds
     - [ ] Real-time score calculation
   - [ ] Summary comparison
     - [ ] Original values
     - [ ] Current values
     - [ ] Penalty difference
   - [ ] Reason field (required)
   - [ ] Actions checklist (what will happen)
   - [ ] Save with confirmation

**Technical Requirements:**
- Supabase table: `daily_reports` (exists)
- Real-time penalty recalculation
- Balance adjustment on save
- Audit log creation
- User notification on report edit
- Validation (cannot edit future reports)

**Files to Create:**
- `lib/features/admin/presentation/pages/report_management_page.dart`
- `lib/features/admin/presentation/pages/report_edit_page.dart`
- Update: `lib/features/admin/data/datasources/admin_remote_datasource.dart` (report CRUD)
- Update: `lib/features/admin/presentation/bloc/admin_bloc.dart` (report events/states)

**Estimated Complexity:** MEDIUM (3-4 hours)

---

### Phase 10: Rest Days Management (MEDIUM PRIORITY)

**Objective:** Configure dates when penalties are not applied

**Sub-tasks:**

1. **Rest Days Page** (NEW)
   - [ ] Calendar view
     - [ ] Month navigation
     - [ ] Visual calendar grid
     - [ ] Rest days highlighted
     - [ ] Click date to add/remove
     - [ ] Legend (color coding)
   - [ ] List view
     - [ ] Year filter
     - [ ] Rest day cards (date, description, recurring)
     - [ ] Edit/delete buttons
     - [ ] Export to CSV

2. **Add Rest Day Form** (NEW)
   - [ ] Date selection (single or range)
   - [ ] Date picker interface
   - [ ] Description input
   - [ ] Recurring annually toggle
   - [ ] Impact notice
   - [ ] Save button

3. **Bulk Import** (NEW)
   - [ ] CSV/Excel upload
   - [ ] Template download
   - [ ] Format validation
   - [ ] Import preview
   - [ ] Confirm import

**Technical Requirements:**
- Supabase table: `rest_days` (date, description, recurring)
- Integration with penalty calculation (skip rest days)
- Annual recurrence logic
- CSV import/export
- Calendar widget (use `table_calendar` package)

**Files to Create:**
- `lib/features/admin/presentation/pages/rest_days_page.dart`
- `lib/features/admin/data/models/rest_day_model.dart`
- Update: `lib/features/admin/data/datasources/admin_remote_datasource.dart` (rest days CRUD)
- Update: `lib/features/admin/presentation/bloc/admin_bloc.dart` (rest days events/states)

**Estimated Complexity:** MEDIUM (3-4 hours)

---

### Phase 11: Content Management (LOW PRIORITY)

**Objective:** Manage app content and announcements

**Sub-tasks:**

1. **Rules & Policies Editor** (NEW)
   - [ ] Section list (drag to reorder)
   - [ ] Rich text editor
     - [ ] Formatting toolbar (bold, italic, lists, links)
     - [ ] Section title input
     - [ ] Content text area
   - [ ] Preview mode
   - [ ] Version history
   - [ ] Publish button

2. **App Announcements** (NEW)
   - [ ] Announcement tabs (Active, Scheduled, Past)
   - [ ] Announcement cards
     - [ ] Title, message, date range
     - [ ] Priority level
     - [ ] Dismissible vs. persistent
   - [ ] Create announcement form
     - [ ] Title and message inputs
     - [ ] Date range picker
     - [ ] Priority selector (low, medium, high)
     - [ ] Dismissible toggle
     - [ ] Target audience (all users, specific tiers)
   - [ ] Edit/delete announcements
   - [ ] End announcement early button

**Technical Requirements:**
- Supabase tables:
  - `app_content` (section, title, content, version, published_at)
  - `announcements` (title, message, start_date, end_date, priority, dismissible, target_users)
- Rich text editor package (e.g., `flutter_quill`)
- Version control for content changes
- Announcement display logic (user-side)

**Files to Create:**
- `lib/features/admin/presentation/pages/content_editor_page.dart`
- `lib/features/admin/presentation/pages/announcements_page.dart`
- `lib/features/admin/data/models/app_content_model.dart`
- `lib/features/admin/data/models/announcement_model.dart`
- Update: `lib/features/admin/data/datasources/admin_remote_datasource.dart`

**Estimated Complexity:** MEDIUM (3-4 hours)

---

## Implementation Priority Summary

### 🔴 HIGH PRIORITY (Must Have for MVP)
1. ✅ **Phase 5: System Settings Completion** - COMPLETE
2. ✅ **Phase 6: Notification Management** - COMPLETE
3. ✅ **Phase 7: Excuse Management** - COMPLETE

### 🟡 MEDIUM PRIORITY (Important for Full Release)
4. **Phase 8: Penalty Management** - Admin oversight and corrections
5. **Phase 9: Report Management** - Data integrity and corrections
6. **Phase 10: Rest Days Management** - Holiday scheduling

### 🟢 LOW PRIORITY (Nice to Have)
7. **Phase 11: Content Management** - Can be manual initially

---

## Technical Architecture Patterns to Follow

All implementations should follow the established clean architecture pattern:

```
lib/features/admin/
├── data/
│   ├── datasources/
│   │   └── admin_remote_datasource.dart (Supabase API calls)
│   ├── models/
│   │   └── [feature]_model.dart (Freezed models with JSON serialization)
│   └── repositories/
│       └── admin_repository_impl.dart (implements domain repository)
├── domain/
│   ├── entities/
│   │   └── [feature]_entity.dart (domain models)
│   └── repositories/
│       └── admin_repository.dart (abstract repository)
└── presentation/
    ├── bloc/
    │   ├── admin_bloc.dart
    │   ├── admin_event.dart
    │   └── admin_state.dart
    ├── pages/
    │   └── [feature]_page.dart
    └── widgets/
        └── [feature]_widget.dart (reusable components)
```

### Standard Implementation Checklist

For each new feature:
- [ ] Create Freezed model in `data/models/`
- [ ] Add methods to `admin_remote_datasource.dart`
- [ ] Update `admin_repository_impl.dart`
- [ ] Add events to `admin_event.dart`
- [ ] Add states to `admin_state.dart`
- [ ] Add event handlers to `admin_bloc.dart`
- [ ] Create page UI in `presentation/pages/`
- [ ] Add route to `app_router.dart`
- [ ] Add quick action to `admin_home_content.dart` (if applicable)
- [ ] Run `build_runner` to generate Freezed files
- [ ] Test end-to-end functionality
- [ ] Update audit log integration

---

## Database Schema Requirements

### Tables to Create (if not exists)

```sql
-- System settings (single row)
CREATE TABLE system_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  penalty_per_deed INTEGER NOT NULL DEFAULT 5000,
  grace_period_hours INTEGER NOT NULL DEFAULT 12,
  training_period_days INTEGER NOT NULL DEFAULT 30,
  auto_deactivation_threshold INTEGER NOT NULL DEFAULT 500000,
  warning_thresholds JSONB NOT NULL DEFAULT '[400000, 450000]',
  email_api_key TEXT,
  email_domain TEXT,
  email_sender_email TEXT,
  email_sender_name TEXT,
  fcm_server_key TEXT,
  app_version TEXT,
  min_version TEXT,
  force_update BOOLEAN DEFAULT FALSE,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification templates
CREATE TABLE notification_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL UNIQUE,
  title_template TEXT NOT NULL,
  body_template TEXT NOT NULL,
  email_subject TEXT,
  email_body TEXT,
  is_enabled BOOLEAN DEFAULT TRUE,
  is_system_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notification schedules
CREATE TABLE notification_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  notification_type TEXT NOT NULL,
  schedule_type TEXT NOT NULL, -- 'time_based', 'condition_based'
  time TIME,
  frequency TEXT, -- 'daily', 'weekly', 'monthly'
  condition JSONB,
  is_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rest days
CREATE TABLE rest_days (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE NOT NULL,
  description TEXT NOT NULL,
  recurring BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(date)
);

-- App content (rules, policies)
CREATE TABLE app_content (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  section TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Announcements
CREATE TABLE announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high'
  dismissible BOOLEAN DEFAULT TRUE,
  target_users TEXT DEFAULT 'all', -- 'all', 'new', 'exclusive', 'legacy'
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Next Conversation Quick Start Guide

When starting the next conversation:

1. **Review this plan** - Read the phase you want to implement
2. **Check database** - Ensure required tables exist
3. **Follow architecture** - Use the established clean architecture pattern
4. **Use TodoWrite** - Track progress with todo items
5. **Test thoroughly** - Run build_runner, flutter analyze, and manual testing
6. **Update routes** - Add to app_router.dart and admin_home_content.dart
7. **Document** - Update this plan when phases are complete

### Recommended Implementation Order

✅ All high-priority phases are now complete! (Phases 5, 6, 7, and 9)

Next, proceed with **remaining medium-priority phases**:
- **Phase 8: Penalty Management** - Admin oversight and manual corrections
- **Phase 10: Rest Days Management** - Configure holiday scheduling

**Phase 11: Content Management** can be implemented last as it's the lowest priority.

---

## Package Dependencies to Add

As you implement features, you may need these packages:

```yaml
dependencies:
  # Rich text editor (Phase 11)
  flutter_quill: ^9.0.0

  # Calendar widget (Phase 10)
  table_calendar: ^3.0.9

  # File picking for CSV import (Phase 10)
  file_picker: ^6.0.0

  # CSV parsing (Phase 10)
  csv: ^5.1.1

  # HTTP client for Mailgun (Phase 6)
  http: ^1.1.0

  # Firebase Cloud Messaging (Phase 6)
  firebase_messaging: ^14.7.0
  firebase_core: ^2.24.0

  # Secure storage for API keys (Phase 5)
  flutter_secure_storage: ^9.0.0
```

---

## Current Project Statistics

- **Admin Phases Completed:** 8 out of 11 (Phases 1-7, 9)
- **Admin Pages Implemented:** 13 (user_management, user_edit, analytics, deed_management, audit_log, system_settings with 4 tabs, excuse_management, notification_templates, notification_schedules, manual_notification, report_management, report_edit)
- **Admin Pages Remaining:** ~4 (spread across Phases 8, 10-11)
- **Overall Admin Completion:** ~73% (8 phases complete, 3 remaining)
- **High Priority Remaining:** 0 phases (ALL HIGH PRIORITY COMPLETE!)
- **Medium Priority Remaining:** 2 phases (Phases 8, 10)
- **Low Priority Remaining:** 1 phase (Phase 11)
- **Estimated Total Remaining Time:** 9-13 hours

### Recent Completions (Latest Session - Session 4)
- ✅ Phase 9: Report Management - Complete backend infrastructure (3 methods), 2 UI pages with advanced editing
  - Reused existing DeedReportEntity and DeedEntryEntity from deeds feature
  - Implemented separate query for deed entries to avoid RLS issues
  - Created smart input controls (checkboxes for binary, sliders for fractional)
  - Added deed template loading for proper names display
  - Implemented real-time penalty recalculation on save
  - Fixed multiple bugs: navigation (GoRouter), audit log columns, entity conversion, RLS policies
  - Created 2 database migration scripts for deed_entries and penalties RLS policies
  - Added proper validation and confirmation dialogs

### Previous Session Completions
- ✅ Phase 6: Notification Management - Complete backend infrastructure (13 methods), 3 UI pages with full CRUD operations
- ✅ Phase 5: System Settings - All 4 tabs now fully editable with validation and audit logging
- ✅ Phase 7: Excuse Management - Complete backend infrastructure and UI with bulk operations

### Important Notes
- **Database Migrations Required:**
  - `database_migrations/fix_notification_system.sql` - For Phase 6 features
  - `database_migrations/fix_deed_entries_rls.sql` - For Phase 9 report editing (CRITICAL)
  - `database_migrations/add_admin_penalty_policy.sql` - For Phase 9 penalty recalculation (CRITICAL)
- **All High Priority Phases Complete:** The admin panel now has all critical user-facing features for MVP release
- **Clean Architecture Maintained:** All implementations follow Entity (domain) → Model (data) → BLoC (presentation) pattern
- **Phase 9 Fully Functional:** Report management is production-ready with comprehensive error handling and validation

---

*Last Updated: November 3, 2025 (Session 4)*
*Project: Sabiquun App - Admin Panel Implementation*
