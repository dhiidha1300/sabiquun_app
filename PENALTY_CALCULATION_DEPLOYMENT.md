# Automatic Penalty Calculation - Deployment Guide

## Overview

This guide explains how to deploy and configure the automatic penalty calculation system for the Sabiquun App. The system automatically calculates and applies penalties to users who fail to submit complete deed reports within the grace period (12:00 PM deadline).

---

## What Was Implemented

### 1. Database Function (`supabase_penalty_calculation.sql`)

A PostgreSQL function that:
- Processes all active users with 'exclusive' or 'legacy' membership
- Calculates penalties based on missed deeds (5,000 shillings per deed)
- Skips users in training period (first 30 days)
- Skips rest days
- Skips users with approved excuses
- Creates penalty records in the `penalties` table
- Logs execution results for audit trail
- Returns detailed execution summary

### 2. Dart Service Integration

Updated files:
- `penalty_remote_datasource.dart` - Added RPC call methods
- `penalty_repository.dart` - Added repository interface
- `penalty_repository_impl.dart` - Added repository implementation

---

## Deployment Steps

### Step 1: Deploy Database Function

1. **Open Supabase SQL Editor**
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor

2. **Run the SQL Script**
   - Copy the entire content of `supabase_penalty_calculation.sql`
   - Paste it into the SQL Editor
   - Click "Run" to execute

3. **Verify Installation**
   ```sql
   -- Check if function exists
   SELECT routine_name, routine_type
   FROM information_schema.routines
   WHERE routine_schema = 'public'
     AND routine_name LIKE '%penalty%';

   -- Should see:
   -- calculate_daily_penalties | FUNCTION
   -- calculate_daily_penalties_with_logging | FUNCTION
   ```

### Step 2: Test Manual Execution

Before setting up automation, test the function manually:

```sql
-- Execute penalty calculation
SELECT calculate_daily_penalties();

-- View the result
-- Should return JSON with:
-- {
--   "success": true,
--   "date_processed": "2025-10-27",
--   "users_processed": 5,
--   "penalties_created": 2,
--   "target_deeds": 10.0,
--   "penalty_per_deed": 5000,
--   "errors": [],
--   "timestamp": "2025-10-28T12:00:00"
-- }
```

**Check Created Penalties:**

```sql
SELECT
  p.id,
  u.full_name,
  p.amount,
  p.date_incurred,
  p.status,
  dr.total_deeds,
  p.created_at
FROM penalties p
JOIN users u ON p.user_id = u.id
LEFT JOIN deeds_reports dr ON p.report_id = dr.id
WHERE p.date_incurred = CURRENT_DATE - INTERVAL '1 day'
ORDER BY p.created_at DESC;
```

### Step 3: Setup Automated Execution

You have **three options** for automating the daily execution at 12:00 PM:

#### **Option A: pg_cron (Recommended for Supabase)**

If your Supabase plan supports pg_cron:

```sql
-- Enable pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily execution at 12:00 PM
SELECT cron.schedule(
  'calculate-daily-penalties',  -- Job name
  '0 12 * * *',                  -- Cron expression (12:00 PM daily)
  $$SELECT calculate_daily_penalties_with_logging();$$
);

-- Verify schedule
SELECT * FROM cron.job;

-- View execution history
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'calculate-daily-penalties')
ORDER BY start_time DESC
LIMIT 10;
```

**Note:** pg_cron is available on Supabase Pro plan and above. For Free plan, use Option B or C.

#### **Option B: Supabase Edge Function with Cron**

Create a Supabase Edge Function:

1. **Install Supabase CLI:**
   ```bash
   npm install -g supabase
   ```

2. **Initialize Functions:**
   ```bash
   supabase functions new calculate-penalties
   ```

3. **Create Function Code** (`supabase/functions/calculate-penalties/index.ts`):
   ```typescript
   import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
   import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

   serve(async (req) => {
     try {
       const supabaseUrl = Deno.env.get('SUPABASE_URL')!
       const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

       const supabase = createClient(supabaseUrl, supabaseKey)

       // Call the penalty calculation function
       const { data, error } = await supabase
         .rpc('calculate_daily_penalties_with_logging')

       if (error) throw error

       return new Response(
         JSON.stringify({
           success: true,
           result: data
         }),
         { headers: { 'Content-Type': 'application/json' } }
       )
     } catch (error) {
       return new Response(
         JSON.stringify({
           success: false,
           error: error.message
         }),
         { status: 500, headers: { 'Content-Type': 'application/json' } }
       )
     }
   })
   ```

4. **Deploy Function:**
   ```bash
   supabase functions deploy calculate-penalties
   ```

5. **Setup Cron Job** (in Supabase Dashboard → Edge Functions):
   - Go to your function
   - Add a cron trigger: `0 12 * * *` (12:00 PM daily)

#### **Option C: External Cron Service**

Use a service like **Cron-job.org**, **EasyCron**, or **GitHub Actions**:

1. **Create API Endpoint:**
   - Use your Edge Function URL from Option B
   - Or create a simple webhook endpoint

2. **Setup Cron Job:**
   - Schedule: Daily at 12:00 PM (your timezone)
   - HTTP Method: POST
   - URL: Your function endpoint
   - Authorization: Bearer token (service role key)

**GitHub Actions Example** (`.github/workflows/penalty-calculation.yml`):
```yaml
name: Calculate Daily Penalties

on:
  schedule:
    - cron: '0 12 * * *'  # 12:00 PM UTC daily
  workflow_dispatch:  # Allow manual trigger

jobs:
  calculate:
    runs-on: ubuntu-latest
    steps:
      - name: Call Penalty Calculation
        run: |
          curl -X POST \
            -H "Authorization: Bearer ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}" \
            -H "Content-Type: application/json" \
            https://your-project.supabase.co/functions/v1/calculate-penalties
```

---

## Testing the System

### Test Scenario 1: User with Incomplete Report

1. **Setup:**
   - User has active membership ('exclusive' or 'legacy')
   - User submitted report yesterday with 9.5/10 deeds
   - Grace period (12:00 PM) has passed

2. **Execute:**
   ```sql
   SELECT calculate_daily_penalties();
   ```

3. **Expected Result:**
   - Penalty of 2,500 shillings created (0.5 × 5,000)
   - User's penalty balance increases by 2,500

4. **Verify:**
   ```sql
   SELECT * FROM penalties
   WHERE user_id = 'user-uuid'
     AND date_incurred = CURRENT_DATE - INTERVAL '1 day';
   ```

### Test Scenario 2: User with No Report

1. **Setup:**
   - User has active membership
   - User did NOT submit any report yesterday

2. **Execute:**
   ```sql
   SELECT calculate_daily_penalties();
   ```

3. **Expected Result:**
   - Penalty of 50,000 shillings created (10.0 × 5,000)
   - All deeds marked as missed

### Test Scenario 3: New Member (Training Period)

1. **Setup:**
   - User joined less than 30 days ago
   - User has incomplete report

2. **Execute:**
   ```sql
   SELECT calculate_daily_penalties();
   ```

3. **Expected Result:**
   - NO penalty created (training period exemption)
   - Log shows user was skipped

### Test Scenario 4: Rest Day

1. **Setup:**
   - Yesterday was marked as a rest day in `rest_days` table
   - User has incomplete report

2. **Execute:**
   ```sql
   SELECT calculate_daily_penalties();
   ```

3. **Expected Result:**
   - NO penalty created (rest day exemption)
   - Log shows user was skipped

---

## Monitoring and Troubleshooting

### View Execution Logs

```sql
-- View all penalty calculation executions
SELECT
  execution_date,
  users_processed,
  penalties_created,
  execution_time,
  result->>'success' as success,
  result->>'errors' as errors
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 20;
```

### View Created Penalties

```sql
-- Today's penalties
SELECT
  u.full_name,
  u.membership_status,
  p.amount,
  p.date_incurred,
  dr.total_deeds,
  dr.status as report_status
FROM penalties p
JOIN users u ON p.user_id = u.id
LEFT JOIN deeds_reports dr ON p.report_id = dr.id
WHERE p.date_incurred = CURRENT_DATE - INTERVAL '1 day'
ORDER BY p.created_at DESC;
```

### Common Issues

**Issue 1: Function Returns Empty Result**
```sql
-- Check if users exist
SELECT COUNT(*) FROM users
WHERE account_status = 'active'
  AND membership_status IN ('exclusive', 'legacy');

-- Check if reports exist
SELECT COUNT(*) FROM deeds_reports
WHERE report_date = CURRENT_DATE - INTERVAL '1 day';
```

**Issue 2: Penalties Not Created**
```sql
-- Check for existing penalties (duplicate prevention)
SELECT * FROM penalties
WHERE date_incurred = CURRENT_DATE - INTERVAL '1 day';

-- Check settings
SELECT * FROM settings
WHERE setting_key IN ('penalty_per_deed', 'grace_period_hours', 'training_period_days');
```

**Issue 3: Permission Denied**
```sql
-- Grant execute permission
GRANT EXECUTE ON FUNCTION calculate_daily_penalties() TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_daily_penalties_with_logging() TO authenticated;
```

---

## Manual Trigger (For Testing)

You can manually trigger penalty calculation from the Flutter app. Here's a sample admin button:

```dart
// In your admin panel or settings screen
ElevatedButton(
  onPressed: () async {
    try {
      final result = await context
          .read<PenaltyBloc>()
          .penaltyRepository
          .calculateDailyPenalties();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success: ${result['penalties_created']} penalties created for ${result['users_processed']} users',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: Text('Calculate Penalties Manually'),
)
```

---

## System Settings

Configure penalty calculation behavior via the `settings` table:

```sql
-- View current settings
SELECT * FROM settings
WHERE setting_key IN (
  'penalty_per_deed',
  'grace_period_hours',
  'training_period_days',
  'auto_deactivation_threshold'
);

-- Update penalty amount
UPDATE settings
SET setting_value = '6000'  -- Change from 5000 to 6000
WHERE setting_key = 'penalty_per_deed';

-- Update grace period
UPDATE settings
SET setting_value = '18'  -- Extend grace period to 6 PM
WHERE setting_key = 'grace_period_hours';
```

---

## Rollback Instructions

If you need to rollback:

```sql
-- Remove cron job (if using pg_cron)
SELECT cron.unschedule('calculate-daily-penalties');

-- Drop functions
DROP FUNCTION IF EXISTS calculate_daily_penalties();
DROP FUNCTION IF EXISTS calculate_daily_penalties_with_logging();

-- Drop log table (optional)
DROP TABLE IF EXISTS penalty_calculation_log;
```

---

## Next Steps

After successful deployment:

1. ✅ Monitor the `penalty_calculation_log` table daily
2. ✅ Verify penalties are being created correctly
3. ✅ Check user complaints about incorrect penalties
4. ✅ Implement notification system to alert users when penalties are applied
5. ✅ Add admin dashboard to view penalty calculation history
6. ✅ Setup alerts for failed executions

---

## Support

For issues or questions:
1. Check the execution logs in `penalty_calculation_log` table
2. Review the Supabase function logs in Dashboard → Edge Functions → Logs
3. Test manually using `SELECT calculate_daily_penalties();`
4. Check this guide's troubleshooting section

---

## Summary

The automatic penalty calculation system is now ready for deployment. The system will:

- ✅ Run daily at 12:00 PM (configurable)
- ✅ Calculate penalties for all eligible users
- ✅ Apply business rules (training period, rest days, excuses)
- ✅ Create penalty records automatically
- ✅ Log all executions for audit trail
- ✅ Handle errors gracefully

**Your specific issue:** Users with incomplete reports (like 9.5/10) will now automatically receive penalties (2,500 shillings) after the grace period ends.
