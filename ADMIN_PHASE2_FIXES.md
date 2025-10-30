# Admin Phase 2 - Bug Fixes Applied

**Date:** 2025-10-30
**Issues Fixed:** Settings column names + Missing RPC functions

---

## 🐛 Issues Encountered

### Issue 1: Settings Table Column Mismatch
**Error:** `column settings.key does not exist`

**Root Cause:**
- Code was using `key` and `value`
- Database schema uses `setting_key` and `setting_value`

**Files Fixed:**
- [admin_remote_datasource.dart](sabiquun_app/lib/features/admin/data/datasources/admin_remote_datasource.dart)
  - Line 643: Changed `select('key, value')` → `select('setting_key, setting_value')`
  - Line 648: Changed `setting['key']` → `setting['setting_key']`
  - Line 648: Changed `setting['value']` → `setting['setting_value']`
  - Line 668-669: Updated upsert to use `setting_key` and `setting_value`
  - Line 694-695: Updated select and eq to use `setting_key` and `setting_value`
  - Line 711-713: Updated upsert to use `setting_key` and `setting_value`

### Issue 2: Missing Analytics RPC Functions
**Error:** `Could not find the function public.get_excuse_metrics`

**Root Cause:**
- Analytics RPC functions were never created in the database
- Required: 5 functions (user_metrics, deed_metrics, financial_metrics, engagement_metrics, excuse_metrics)

**Solution:**
- Created comprehensive SQL setup file: [ADMIN_PHASE2_DATABASE_SETUP.sql](ADMIN_PHASE2_DATABASE_SETUP.sql)

---

## ✅ Fixes Applied

### 1. Code Fixes (Completed)
All column name references updated to match database schema:
- ✅ `getSystemSettings()` - Fixed
- ✅ `updateSystemSettings()` - Fixed
- ✅ `getSettingValue()` - Fixed
- ✅ `updateSetting()` - Fixed

### 2. Database Setup Required

**YOU MUST RUN THIS SQL FILE IN SUPABASE:**

📄 **[ADMIN_PHASE2_DATABASE_SETUP.sql](ADMIN_PHASE2_DATABASE_SETUP.sql)**

This file contains:
- ✅ Settings table creation (if not exists)
- ✅ Default settings values (11 settings)
- ✅ 5 Analytics RPC functions:
  1. `get_user_metrics()` - User statistics
  2. `get_deed_metrics(start_date, end_date)` - Deed compliance
  3. `get_financial_metrics(start_date, end_date)` - Financial overview
  4. `get_engagement_metrics()` - User engagement
  5. `get_excuse_metrics()` - Excuse request stats
- ✅ RLS policies for settings table
- ✅ Verification queries

---

## 🚀 How to Apply the Fix

### Step 1: Code is Already Fixed ✅
The Dart code has been updated. No action needed.

### Step 2: Run Database Setup Script

1. **Open Supabase SQL Editor**
   - Go to your Supabase project
   - Navigate to SQL Editor

2. **Copy & Paste the SQL File**
   - Open [ADMIN_PHASE2_DATABASE_SETUP.sql](ADMIN_PHASE2_DATABASE_SETUP.sql)
   - Copy all contents
   - Paste into Supabase SQL Editor

3. **Execute the Script**
   - Click "Run" or press Ctrl+Enter
   - Wait for completion (~5-10 seconds)
   - Check for success messages

4. **Verify Setup**
   The script includes verification queries at the end:
   ```sql
   SELECT COUNT(*) as settings_count FROM settings;
   SELECT get_user_metrics();
   SELECT get_deed_metrics(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);
   -- etc.
   ```

   You should see:
   - `settings_count` = 11 (or more if you added custom settings)
   - JSON objects returned from each function

### Step 3: Test in App

1. **Restart your app** (to ensure fresh connection)

2. **Test System Settings**
   - Navigate to `/admin/system-settings`
   - Should load without errors
   - Should see General tab with editable fields
   - Should see current values (10, 5000, 2, 30, etc.)

3. **Test Analytics Dashboard**
   - Navigate to `/admin/analytics`
   - Should load without errors
   - Should see metric cards with real data
   - Use date picker to filter (optional)

---

## 📊 What the SQL Script Does

### Settings Table
Creates and populates with 11 default settings:
- `daily_deed_target` = 10
- `penalty_per_deed` = 5000
- `grace_period_hours` = 2
- `training_period_days` = 30
- `auto_deactivation_threshold` = 400000
- `warning_thresholds` = [200000, 350000]
- `organization_name` = Sabiquun
- `receipt_footer_text` = Thank you for your payment
- `app_version` = 1.0.0
- `minimum_required_version` = 1.0.0
- `force_update` = false

### Analytics Functions

Each function returns a JSON object with specific metrics:

**1. get_user_metrics():**
```json
{
  "pending_users": 5,
  "active_users": 142,
  "suspended_users": 2,
  "deactivated_users": 1,
  "new_members": 23,
  "exclusive_members": 98,
  "legacy_members": 21,
  "users_at_risk": 8,
  "new_registrations_this_week": 4
}
```

**2. get_deed_metrics():**
- Total deeds (today, week, month, all-time)
- Average deeds per user
- Compliance rates (% meeting 10 deed target)
- Faraid/Sunnah compliance rates
- Top 5 performers
- Bottom 5 users needing attention
- Deed compliance by type

**3. get_financial_metrics():**
- Penalties incurred (this month, all-time)
- Payments received (this month, all-time)
- Outstanding balance
- Pending payments (count + amount)

**4. get_engagement_metrics():**
- Daily active users
- Total active users
- Report submission rate
- Average submission time
- Notification metrics (placeholders)

**5. get_excuse_metrics():**
- Pending excuse requests
- Approval rate
- Top 5 excuse reasons with counts

---

## 🧪 Testing Checklist

After running the SQL script:

### System Settings Page
- [ ] Page loads without error
- [ ] General tab shows all fields with correct values
- [ ] Can change "Daily Deed Target" from 10 to 12
- [ ] "Save Changes" button appears after edit
- [ ] Reason field is required
- [ ] Confirmation dialog appears on save
- [ ] Success message shows after save
- [ ] Values persist after page refresh
- [ ] Payment/Notification/App tabs are read-only

### Analytics Dashboard Page
- [ ] Page loads without error
- [ ] User Metrics section shows 8 cards
- [ ] Deed Metrics section shows compliance data
- [ ] Financial Metrics shows balances
- [ ] Engagement Metrics shows percentages
- [ ] Excuse Metrics shows pending count
- [ ] Date picker works
- [ ] Date filter updates metrics
- [ ] Clear filter button works
- [ ] Refresh button works
- [ ] Pull-to-refresh works

---

## 🎯 Expected Behavior

### First Time Setup
If this is a new/empty database:
- User metrics will show mostly zeros
- Deed metrics will show 0 compliance
- Financial metrics will show 0 balances
- Engagement will show 0% rates
- **This is normal for empty database**

### With Real Data
- Metrics will reflect actual database content
- Top performers list shows real users
- Compliance rates calculate correctly
- Financial totals sum up properly

---

## ⚠️ Troubleshooting

### "Function already exists" error
This is safe to ignore. The script uses `CREATE OR REPLACE` which updates existing functions.

### "Settings already exist" error
This is safe to ignore. The script uses `ON CONFLICT DO NOTHING` for default settings.

### Empty/Zero metrics
If you see all zeros:
1. Check if you have data in these tables:
   - `users`
   - `deeds_reports`
   - `penalties`
   - `payments`
   - `excuses`
2. Run verification queries manually
3. Check if user_statistics table has data

### Permission denied error
Make sure the `public.is_admin()` function exists (from Phase 1).
If not, run:
```sql
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'supervisor', 'cashier')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 📝 Summary

**Code Changes:** ✅ Complete (4 methods fixed)
**Database Setup:** ⏳ Requires running SQL script
**Testing:** ⏳ After SQL script execution

**Files Modified:**
1. [admin_remote_datasource.dart](sabiquun_app/lib/features/admin/data/datasources/admin_remote_datasource.dart) - Fixed column names

**Files Created:**
1. [ADMIN_PHASE2_DATABASE_SETUP.sql](ADMIN_PHASE2_DATABASE_SETUP.sql) - Complete database setup
2. [ADMIN_PHASE2_FIXES.md](ADMIN_PHASE2_FIXES.md) - This document

---

**Next Step:** Run the SQL script in Supabase, then test both pages! 🚀
