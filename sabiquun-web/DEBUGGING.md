# Debugging Guide - No Data Showing Issue

## Current Situation
All pages are loading but no data is showing. This is most likely caused by one of these issues:

1. **Row Level Security (RLS) Policies** blocking access
2. **Empty Database** (no data exists)
3. **Authentication/Session Issues**

## Step-by-Step Debugging Process

### Step 1: Open Browser Developer Tools
1. Press `F12` to open Developer Tools
2. Go to the **Console** tab
3. Refresh the page

### Step 2: Check Console Logs
Look for log messages that start with these emojis:
- 🔍 = Information about what's happening
- ✅ = Success
- ⚠️ = Warning
- ❌ = Error

**What to look for:**
```
🔍 Dashboard - Fetching stats...
🔍 Dashboard - Query Results: { ... }
```

**Key indicators:**

#### If you see error messages:
```json
{
  "error": {
    "message": "...",
    "code": "...",
    "hint": "..."
  }
}
```
This tells you the exact problem.

#### If you see counts of 0 but no errors:
```json
{
  "count": 0,
  "error": null
}
```
This means either:
- Database is empty (no users, no data)
- RLS is blocking the query

### Step 3: Run Diagnostic Tests
1. Navigate to: `http://localhost:3000/dashboard/test-db`
2. Click "Run Tests" button
3. Check the results:

**Test Results Meaning:**
- ✅ **Green (Success)** = Query worked and found data
- ⚠️ **Yellow (Warning)** = Query worked but found no data
- ❌ **Red (Error)** = Query failed (check error message)

### Step 4: Common Issues and Solutions

#### Issue 1: RLS Policies Blocking Access
**Symptoms:**
- Queries succeed (no errors)
- All counts are 0
- Test page shows "RLS might be blocking"

**Solution:**
You need to disable or configure RLS policies in Supabase:

1. Go to Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **SQL Editor**
4. Run this SQL to temporarily disable RLS for testing:

```sql
-- Disable RLS on all tables
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE deeds_reports DISABLE ROW LEVEL SECURITY;
ALTER TABLE penalties DISABLE ROW LEVEL SECURITY;
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;
ALTER TABLE excuses DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_statistics DISABLE ROW LEVEL SECURITY;
```

5. Refresh your web admin and check if data shows

**If data shows after disabling RLS:**
You need to create proper RLS policies. Here's an example for admin users:

```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy for admins to see all users
CREATE POLICY "Admins can view all users" ON users
  FOR SELECT
  USING (
    auth.jwt() ->> 'role' = 'admin'
    OR
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'admin'
    )
  );
```

#### Issue 2: Empty Database
**Symptoms:**
- All tests pass (green)
- Counts are genuinely 0
- "No users in database" message

**Solution:**
Your database is empty. You need to:
1. Create users in Supabase Auth
2. Insert initial data
3. Or migrate data from your Flutter app's database

#### Issue 3: Authentication Issues
**Symptoms:**
- "Authentication Check" test fails
- Session info shows "Not authenticated"

**Solution:**
1. Log out: Go to settings or use the sign out button
2. Log back in
3. Make sure your user account exists in the `users` table with correct role

### Step 5: Check Network Tab
1. In Developer Tools, go to **Network** tab
2. Filter by **Fetch/XHR**
3. Refresh the page
4. Look for requests to Supabase (supabase.co)
5. Click on each request and check:
   - **Status Code**: Should be 200
   - **Response**: Shows the data returned

### Step 6: Verify Database Schema
Check that your Supabase database has these tables:
- ✅ users
- ✅ deeds_reports (NOT deed_reports)
- ✅ penalties
- ✅ payments
- ✅ excuses
- ✅ user_statistics
- ✅ deed_templates

## Quick Fix Checklist

- [ ] Opened browser console (F12)
- [ ] Checked for error messages in console
- [ ] Ran diagnostic tests at `/dashboard/test-db`
- [ ] Verified RLS policies in Supabase
- [ ] Checked if database has data
- [ ] Verified authentication is working
- [ ] Checked Network tab for failed requests

## Getting Help

When reporting this issue, please provide:
1. Screenshot of browser console
2. Screenshot of diagnostic test results
3. Whether RLS is enabled/disabled
4. Whether the database has data (check Supabase Table Editor)
5. Your user's role (admin, cashier, supervisor)

## Most Likely Cause

Based on your description (no errors, no data), the issue is **99% likely to be RLS policies blocking access**.

**Quick Test:**
1. Go to Supabase Dashboard
2. Table Editor → `users` table
3. Can you see users? If YES → RLS is blocking web admin
4. If NO → Database is empty
