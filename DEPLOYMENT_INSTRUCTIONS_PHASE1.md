# Phase 1: Database Function Deployment

## Step 1: Deploy to Supabase

### 1.1 Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Select your Sabiquun project
3. Navigate to **SQL Editor** in the left sidebar

### 1.2 Execute SQL Script
1. Copy the ENTIRE contents of `supabase_penalty_calculation.sql`
2. Paste into the SQL Editor
3. Click **Run** button
4. Wait for confirmation: "Success. No rows returned"

### 1.3 Verify Installation
Run this query to verify functions were created:

```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%penalty%';
```

**Expected Output:**
```
calculate_daily_penalties              | FUNCTION
calculate_daily_penalties_with_logging | FUNCTION
```

### 1.4 Verify Tables
Check that the log table was created:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'penalty_calculation_log';
```

**Expected:** `penalty_calculation_log`

---

## Step 2: Test Manual Execution

### 2.1 Run the Function
```sql
SELECT calculate_daily_penalties();
```

**Expected Output (JSON):**
```json
{
  "success": true,
  "date_processed": "2025-11-03",
  "users_processed": 0,
  "penalties_created": 0,
  "target_deeds": 10.0,
  "penalty_per_deed": 5000,
  "errors": [],
  "timestamp": "2025-11-04T10:30:00"
}
```

> **Note:** If you have no users with incomplete reports from yesterday, `penalties_created` will be 0. This is normal!

### 2.2 Verify Execution Logged
```sql
SELECT
  execution_date,
  users_processed,
  penalties_created,
  execution_time,
  result->>'success' as success
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 5;
```

You should see at least one row with your test execution.

---

## Step 3: Grant Permissions

Ensure the service role can execute the function:

```sql
-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION calculate_daily_penalties() TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_daily_penalties_with_logging() TO authenticated;

-- Grant execute to service role (for Edge Functions)
GRANT EXECUTE ON FUNCTION calculate_daily_penalties() TO service_role;
GRANT EXECUTE ON FUNCTION calculate_daily_penalties_with_logging() TO service_role;
```

---

## ✅ Phase 1 Complete!

Once you see:
- ✅ Both functions listed in information_schema
- ✅ Manual execution returns JSON with `"success": true`
- ✅ Execution logged in `penalty_calculation_log` table
- ✅ Permissions granted

**You're ready for Phase 2: Edge Function Creation!**

---

## Troubleshooting

### Error: "function uuid_generate_v4() does not exist"
**Solution:** Enable the uuid extension first:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Error: "permission denied for schema public"
**Solution:** You need to be logged in as the database owner or have SUPERUSER privileges.

### No penalties created but you expected some
**Reasons:**
1. No incomplete reports from yesterday
2. Users are in training period (< 30 days)
3. Yesterday was a rest day
4. Users have approved excuses

**Check:**
```sql
-- See users with incomplete reports
SELECT
  u.name,
  u.created_at,
  CURRENT_DATE - u.created_at::DATE as days_old,
  dr.total_deeds,
  dr.status
FROM users u
LEFT JOIN deeds_reports dr ON dr.user_id = u.id
  AND dr.report_date = CURRENT_DATE - INTERVAL '1 day'
WHERE u.account_status = 'active'
  AND u.membership_status IN ('exclusive', 'legacy')
ORDER BY u.name;
```
