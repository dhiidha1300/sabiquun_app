# 🔧 Notification System - Complete Error Fixes

## **All Issues Identified & Solutions**

### ✅ **Issue 1: Manual Notification Page - Type Error**
**Status**: FIXED IN CODE ✅

**Error**:
```
TypeError: Instance of 'UserManagementEntity': type 'UserManagementEntity' is not a subtype of type 'UserManagementModel'
```

**Fixes Applied**:
1. Changed import from `UserManagementModel` to `UserManagementEntity`
2. Updated type declarations
3. Fixed enum property access (added `.value` to `accountStatus` and `role`)

**File**: `lib/features/admin/presentation/pages/manual_notification_page.dart`

---

### 🔧 **Issue 2: Notification Templates - Missing Database Columns**
**Status**: NEEDS DATABASE MIGRATION

**Error**:
```
PostgrestException: Could not find the 'email_body' column in the schema cache
```

**Required Fix**: Add `email_subject` and `email_body` columns to `notification_templates` table

---

### 🔧 **Issue 3: Notification Schedules - RLS Policy Missing**
**Status**: NEEDS DATABASE MIGRATION

**Error**:
```
PostgrestException: new row violates row-level security policy for table "notification_schedules"
```

**Required Fix**: Add RLS policies to allow admins to manage schedules

---

### 🔧 **Issue 4: Notifications Log - RLS Policy Missing** ⚠️ NEW
**Status**: NEEDS DATABASE MIGRATION

**Error**:
```
PostgrestException: new row violates row-level security policy for table "notifications_log"
```

**Required Fix**: Add RLS policies to allow admins to insert notifications

**This is the current blocking issue preventing manual notifications from being sent!**

---

## 📋 **Complete Database Migration**

### **Option 1: Run Full Migration (Recommended)**

Run this in Supabase SQL Editor:

```sql
-- ============================================================================
-- COMPLETE NOTIFICATION SYSTEM FIX
-- ============================================================================

-- 1. Add missing email columns to notification_templates
ALTER TABLE notification_templates
ADD COLUMN IF NOT EXISTS email_subject VARCHAR(255),
ADD COLUMN IF NOT EXISTS email_body TEXT;

-- 2. Add RLS policies for notification_schedules
ALTER TABLE notification_schedules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage notification schedules" ON notification_schedules;

CREATE POLICY "Admins can manage notification schedules"
ON notification_schedules
FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 3. Add RLS policies for notification_templates
ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can manage notification templates" ON notification_templates;

CREATE POLICY "Admins can manage notification templates"
ON notification_templates
FOR ALL
USING (public.is_admin())
WITH CHECK (
  public.is_admin() AND
  (CASE WHEN TG_OP = 'DELETE' THEN NOT is_system_default ELSE TRUE END)
);

-- 4. Add RLS policies for notifications_log (THIS FIXES THE SEND ERROR!)
ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can read their own notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications_log;

CREATE POLICY "Admins can insert notifications"
ON notifications_log
FOR INSERT
WITH CHECK (public.is_admin());

CREATE POLICY "Users can read their own notifications"
ON notifications_log
FOR SELECT
USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Users can update their own notifications"
ON notifications_log
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- 5. Insert default notification templates
INSERT INTO notification_templates (template_key, title, body, notification_type, is_system_default)
SELECT * FROM (VALUES
  ('deadline_reminder', 'Reminder: Submit Today''s Deeds', 'You have until 12 PM tomorrow to submit today''s report.', 'daily_reminder', TRUE),
  ('penalty_incurred', 'Penalty Applied', 'Penalty of {{amount}} shillings applied. Current balance: {{balance}}.', 'penalty', TRUE),
  ('payment_approved', 'Payment Approved', 'Your payment of {{amount}} shillings has been approved.', 'payment', TRUE),
  ('grace_period_ending', 'Grace Period Ending Soon', 'You have 1 hour left to submit yesterday''s report.', 'grace_warning', TRUE),
  ('weekly_leaderboard', 'Weekly Leaderboard', 'You ranked #{{rank}} this week!', 'weekly_leaderboard', TRUE)
) AS v(template_key, title, body, notification_type, is_system_default)
WHERE NOT EXISTS (
  SELECT 1 FROM notification_templates WHERE template_key = v.template_key
);

-- Verify everything was created
SELECT 'Migration completed successfully!' as status;
```

---

### **Option 2: Quick Fix (Just notifications_log)**

If you only want to fix the current blocking issue:

```sql
-- Quick fix for manual notification sending

ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications_log;

CREATE POLICY "Admins can insert notifications"
ON notifications_log
FOR INSERT
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "Users can read their own notifications" ON notifications_log;

CREATE POLICY "Users can read their own notifications"
ON notifications_log
FOR SELECT
USING (auth.uid() = user_id OR public.is_admin());

DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications_log;

CREATE POLICY "Users can update their own notifications"
ON notifications_log
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

---

## 🎯 **Testing Checklist**

After running the migration, test in this order:

### 1. Test Notification Templates
- [ ] Navigate to Admin > Notifications
- [ ] Click FAB to create template
- [ ] Fill form (including email fields)
- [ ] Click Create
- [ ] **Expected**: Template created successfully ✅

### 2. Test Notification Schedules
- [ ] Click top-right icon to go to schedules
- [ ] Click FAB to create schedule
- [ ] Select template, time, frequency
- [ ] Click Create
- [ ] **Expected**: Schedule created successfully ✅

### 3. Test Manual Notifications ⭐ (Currently Broken)
- [ ] Navigate to Admin > Send Manual Notification
- [ ] Enter title: "Test Notification"
- [ ] Enter message: "This is a test"
- [ ] Select one or more users
- [ ] Click "Send Notification"
- [ ] **Expected**: Notification sent successfully ✅

---

## 📊 **What Each Policy Does**

### `notifications_log` Policies:

1. **"Admins can insert notifications"**
   - Allows admins to send manual notifications
   - Required for the "Send Manual Notification" feature

2. **"Users can read their own notifications"**
   - Users can view their own notifications
   - Admins can view all notifications

3. **"Users can update their own notifications"**
   - Users can mark notifications as read
   - Only affects their own notifications

---

## 🔍 **Verification Queries**

Run these to verify the migration worked:

```sql
-- Check notifications_log columns
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'notifications_log'
ORDER BY ordinal_position;

-- Check notifications_log policies
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'notifications_log'
ORDER BY policyname;

-- Check all notification-related policies
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('notification_templates', 'notification_schedules', 'notifications_log')
ORDER BY tablename, policyname;
```

---

## 📁 **Migration Files**

1. **`database_migrations/fix_notification_system.sql`** - Complete migration with all fixes
2. **`QUICK_FIX_notifications_log.sql`** - Quick fix for just the notifications_log issue

---

## ⚠️ **Important Notes**

1. **Run migration as database admin** - These commands require elevated privileges
2. **Backup first** (optional) - Run `pg_dump` if you want to be extra safe
3. **`public.is_admin()` function must exist** - The migration will fail if this helper function doesn't exist

### If `is_admin()` doesn't exist, create it first:

```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    SELECT role = 'admin'
    FROM public.users
    WHERE id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 🎉 **Expected Results After Migration**

✅ Can create notification templates with email fields
✅ Can create notification schedules
✅ Can send manual notifications to users
✅ No RLS policy errors
✅ All notification features working

---

## 🐛 **Troubleshooting**

### Still Getting RLS Errors?

1. **Verify you're logged in as admin**:
   ```sql
   SELECT public.is_admin();
   -- Should return TRUE
   ```

2. **Check if policies exist**:
   ```sql
   SELECT * FROM pg_policies WHERE tablename = 'notifications_log';
   -- Should show 3 policies
   ```

3. **Verify RLS is enabled**:
   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE tablename = 'notifications_log';
   -- rowsecurity should be TRUE
   ```

---

## 📞 **Summary**

**Current Status**:
- ✅ Code fixes applied
- 🔧 Database migration needed
- ⭐ Priority: Fix `notifications_log` RLS policies to enable manual notifications

**Action Required**:
Run the complete migration SQL in Supabase to fix all 4 issues at once!
