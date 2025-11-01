# Admin System - Quick Reference Guide

**Last Updated:** 2025-11-01
**Status:** 3/6 Phases Complete (50%)

---

## 🚀 Quick Start

### Navigate to Admin Features
As an admin user, you can access:

1. **Admin Home**: `/home` (default landing)
2. **User Management**: `/admin/user-management`
3. **Deed Management**: `/admin/deed-management`
4. **Analytics Dashboard**: `/admin/analytics`
5. **System Settings**: `/admin/system-settings`

### Quick Actions from Home
The admin home screen shows 6 quick action cards:
- 🧑‍🤝‍🧑 User Management (blue)
- ✓ Deed Management (teal)
- ⚙️ System Settings (purple)
- 📊 Analytics (indigo)
- 📅 Excuses (orange)
- 💰 Payments (green)

---

## 📋 Feature Status

### ✅ Phase 1: User Management (100%)
**Route**: `/admin/user-management`

**Features**:
- View users by status (Pending/Active/Suspended/Deactivated)
- Approve/Reject pending users
- Suspend/Activate users
- Edit user details
- Change user roles
- View user statistics

**Key Files**:
- Page: `lib/features/admin/presentation/pages/user_management_page.dart`
- Edit: `lib/features/admin/presentation/pages/user_edit_page.dart`
- Widget: `lib/features/admin/presentation/widgets/user_card.dart`

### ✅ Phase 2: Analytics & Settings (100%)
**Routes**:
- `/admin/analytics` - Analytics Dashboard
- `/admin/system-settings` - System Settings

**Analytics Features**:
- User metrics (pending, active, at risk)
- Deed performance (compliance, averages)
- Financial overview (outstanding, payments)
- Excuse metrics
- Engagement stats

**Settings Features**:
- General settings (editable)
- Payment settings (read-only)
- Notification settings (read-only)
- App settings (read-only)

**Key Files**:
- Analytics Page: `lib/features/admin/presentation/pages/analytics_dashboard_page.dart`
- Settings Page: `lib/features/admin/presentation/pages/system_settings_page.dart`
- Widgets: `lib/features/admin/presentation/widgets/` (5 widget files)

### ✅ Phase 3: Deed Management (100%)
**Route**: `/admin/deed-management`

**Features**:
- View all deed templates
- Add new custom deeds
- Edit existing deeds
- Deactivate/Activate deeds
- Delete custom deeds (soft delete)
- Reorder deeds (drag-and-drop)
- System default protection

**Key Files**:
- Page: `lib/features/admin/presentation/pages/deed_management_page.dart`
- Dialog: `lib/features/admin/presentation/widgets/deed_form_dialog.dart`
- Model: `lib/features/admin/data/models/deed_template_model.dart`

### ❌ Phase 4: Audit Log Viewer (0%)
**Planned Route**: `/admin/audit-logs`

**Planned Features**:
- View all admin actions
- Filter by date, user, action type
- Export to CSV/Excel
- Before/after value comparison

### ❌ Phase 5: Notification Management (0%)
**Planned Route**: `/admin/notifications`

**Planned Features**:
- Manage notification templates
- Email/Push template editor
- Variable placeholders
- Schedule management

### ❌ Phase 6: Rest Days Management (0%)
**Planned Route**: `/admin/rest-days`

**Planned Features**:
- Calendar view
- Add single/range dates
- Recurring dates
- Bulk CSV import

---

## 🔑 Key Concepts

### System Default Deeds
- The 10 original deeds seeded in the database
- Cannot be deleted
- Limited editing (name/category/value type locked)
- Marked with 🔒 lock icon

### Deed Categories
- **Fara'id** (🕌): Required prayers (5 prayers)
- **Sunnah** (📖): Recommended deeds (Duha, Quran, etc.)

### Deed Value Types
- **Binary**: 0 or 1 (done/not done)
- **Fractional**: 0.0 to 1.0 in 0.1 increments

### User Account Statuses
- **Pending**: Awaiting admin approval
- **Active**: Normal active account
- **Suspended**: Manually suspended by admin
- **Auto-Deactivated**: Deactivated due to high balance (>400k)

### User Roles
- **User**: Regular member
- **Supervisor**: Can view reports
- **Cashier**: Can manage payments
- **Admin**: Full access

---

## 🎯 Common Admin Tasks

### Approve a New User
1. Go to User Management
2. Click "Pending" tab
3. Find the user
4. Click context menu (⋮)
5. Click "Approve"
6. Confirm in dialog

### Add a New Deed
1. Go to Deed Management
2. Click the + (FAB) button
3. Enter deed name (key auto-generates)
4. Select category (Fara'id/Sunnah)
5. Select value type (Binary/Fractional)
6. Toggle active if needed
7. Click "Create"

### Reorder Deeds
1. Go to Deed Management
2. Click "Reorder" button in section header
3. Drag deeds up/down
4. Click "Save Order"

### Update System Settings
1. Go to System Settings
2. Click "General" tab
3. Modify values (e.g., daily deed target)
4. Enter reason for change
5. Click "Save Changes"
6. Confirm in dialog

### View Analytics
1. Go to Analytics Dashboard (or Admin Home)
2. Pull down to refresh
3. Use date picker to filter range
4. View metrics by section:
   - User Overview
   - Deed Performance
   - Financial Overview

---

## 🗄️ Database Tables Used

### Core Tables
- `users` - User accounts
- `deed_templates` - Deed definitions
- `settings` - System configuration
- `audit_logs` - Action history

### Related Tables
- `deeds_reports` - Daily deed submissions
- `penalties` - Penalty records
- `payments` - Payment records
- `excuses` - Excuse requests

---

## 🔧 BLoC Events Reference

### User Management Events
```dart
LoadUsersRequested()
ApproveUserRequested(userId, approvedBy)
RejectUserRequested(userId, rejectedBy, reason)
UpdateUserRequested(...)
SuspendUserRequested(userId, suspendedBy, reason)
ActivateUserRequested(userId, activatedBy, reason)
```

### Deed Management Events
```dart
LoadDeedTemplatesRequested()
CreateDeedTemplateRequested(...)
UpdateDeedTemplateRequested(...)
DeactivateDeedTemplateRequested(templateId, deactivatedBy, reason)
ReorderDeedTemplatesRequested(templateIds, updatedBy)
```

### Analytics Events
```dart
LoadAnalyticsRequested(startDate?, endDate?)
```

### Settings Events
```dart
LoadSystemSettingsRequested()
UpdateSystemSettingsRequested(settings, updatedBy)
```

---

## 🎨 UI Components Reference

### Reusable Widgets

**UserCard** (`lib/features/admin/presentation/widgets/user_card.dart`)
- Displays user info in card format
- Shows avatar, name, email, phone, role
- Shows balance, reports, compliance
- Customizable action buttons

**AnalyticsMetricCard** (`lib/features/admin/presentation/widgets/analytics_metric_card.dart`)
- Displays a single metric
- Icon, title, value, subtitle, color

**DeedFormDialog** (`lib/features/admin/presentation/widgets/deed_form_dialog.dart`)
- Add/Edit deed templates
- Dual-purpose dialog
- Auto-generates key from name
- Form validation

**EnhancedFeatureCard** (`lib/features/home/widgets/enhanced_feature_card.dart`)
- Quick action cards on home screen
- Badge counts, urgent items

---

## 🛡️ Security & Permissions

### RLS Policies Required
All admin tables need policies like:
```sql
CREATE POLICY "Admins can read X" ON table_name
FOR SELECT USING (public.is_admin());

CREATE POLICY "Admins can update X" ON table_name
FOR UPDATE USING (public.is_admin());
```

### Auth State Check
Admin BLoC requires authenticated user:
```dart
final authState = context.read<AuthBloc>().state;
if (authState is Authenticated) {
  final userId = authState.user.id;
  // Use userId for audit logging
}
```

---

## 📊 Audit Logging

All admin actions are automatically logged to `audit_logs` table with:
- `action_type` - What was done
- `performed_by` - Admin user ID
- `entity_type` - What was affected
- `entity_id` - Which record
- `reason` - Why (required for sensitive actions)
- `old_values` - Before state (JSON)
- `new_values` - After state (JSON)
- `timestamp` - When

---

## 🧪 Testing Checklist

### Before Each Release
- [ ] Test user approval flow
- [ ] Test user suspension flow
- [ ] Test deed creation
- [ ] Test deed reordering
- [ ] Test settings update
- [ ] Verify analytics load
- [ ] Check audit logs created
- [ ] Test error handling
- [ ] Test loading states
- [ ] Test empty states

---

## 📞 Troubleshooting

### "Failed to load X"
- Check RLS policies allow admin access
- Check database table exists
- Check network connection
- Check auth state is Authenticated

### "Cannot delete system default deed"
- This is expected behavior
- System defaults are protected
- Only deactivation allowed

### "No rows affected"
- RLS policy may be blocking
- Check user has admin role
- Check `is_admin()` function works

### Analytics not loading
- Check RPC functions exist:
  - `get_user_metrics()`
  - `get_deed_metrics()`
  - `get_financial_metrics()`
  - `get_engagement_metrics()`
  - `get_excuse_metrics()`
- Check functions return correct JSON structure

---

## 🔍 Code Locations

### BLoC Files
- Events: `lib/features/admin/presentation/bloc/admin_event.dart`
- States: `lib/features/admin/presentation/bloc/admin_state.dart`
- BLoC: `lib/features/admin/presentation/bloc/admin_bloc.dart`

### Data Layer
- Datasource: `lib/features/admin/data/datasources/admin_remote_datasource.dart`
- Repository: `lib/features/admin/data/repositories/admin_repository_impl.dart`

### Pages
- User Management: `lib/features/admin/presentation/pages/user_management_page.dart`
- Deed Management: `lib/features/admin/presentation/pages/deed_management_page.dart`
- Analytics: `lib/features/admin/presentation/pages/analytics_dashboard_page.dart`
- Settings: `lib/features/admin/presentation/pages/system_settings_page.dart`

### Navigation
- Router: `lib/core/navigation/app_router.dart`
- Admin Home: `lib/features/home/pages/admin_home_content.dart`

---

## 📚 Further Reading

- [ADMIN_ARCHITECTURE.md](ADMIN_ARCHITECTURE.md) - System architecture
- [ADMIN_PHASE1_IMPLEMENTATION.md](ADMIN_PHASE1_IMPLEMENTATION.md) - User Management
- [ADMIN_PHASE2_COMPLETE.md](ADMIN_PHASE2_COMPLETE.md) - Analytics & Settings
- [ADMIN_PHASE3_COMPLETE.md](ADMIN_PHASE3_COMPLETE.md) - Deed Management (initial)
- [PHASE3_FINAL_SUMMARY.md](PHASE3_FINAL_SUMMARY.md) - Deed Management (final)
- [docs/ui-ux/05-admin-screens.md](docs/ui-ux/05-admin-screens.md) - UI specifications

---

**Need Help?** Review the phase documentation for detailed implementation guides.

**Reporting Bugs?** Check the troubleshooting section first, then create an issue.

**Contributing?** Follow the existing Clean Architecture + BLoC patterns.
