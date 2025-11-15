-- =====================================================================
-- Setup Automatic Penalty Calculation Cron Job with Authorization
-- (SIMPLE VERSION - No Vault Extension Required)
-- =====================================================================
-- This script fixes the 401 unauthorized error when the cron job
-- triggers the Edge Function by properly configuring authentication
-- =====================================================================

-- INSTRUCTIONS:
-- 1. Replace YOUR_PROJECT_REF with your actual Supabase project reference ID
--    Example: vrvlqitoyskyzoertfwz
-- 2. Replace YOUR_ANON_KEY with your actual Supabase anon/public key
--    Find it at: Supabase Dashboard → Settings → API → anon/public key
-- 3. Execute this script in the Supabase SQL Editor
-- 4. After execution, the cron job will run daily at 9:00 AM UTC (12:00 PM EAT)

-- ⚠️ SECURITY NOTE:
-- This approach stores the anon key directly in the cron job command.
-- The anon key is safe to use client-side and respects Row Level Security (RLS).
-- For additional security, you can request Supabase support to enable the Vault extension.

-- =====================================================================
-- STEP 1: Enable Required Extensions
-- =====================================================================

-- Enable pg_cron for scheduled jobs
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Enable pg_net for HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- =====================================================================
-- STEP 2: Remove Old Cron Job (if exists)
-- =====================================================================

-- First, check if there's an existing cron job and remove it
-- This prevents duplicate executions
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'daily-penalty-calculation') THEN
    PERFORM cron.unschedule('daily-penalty-calculation');
  END IF;
END $$;

-- =====================================================================
-- STEP 3: Create New Cron Job with Authorization Header
-- =====================================================================

-- ⚠️ IMPORTANT: Replace the values below before executing!
-- YOUR_PROJECT_REF = Your Supabase project reference (e.g., vrvlqitoyskyzoertfwz)
-- YOUR_ANON_KEY = Your Supabase anon/public key (from Dashboard → Settings → API)

SELECT cron.schedule(
  'daily-penalty-calculation',        -- Job name
  '0 9 * * *',                         -- Cron expression: 9:00 AM UTC daily (12:00 PM EAT)
  $$
    -- Make HTTP POST request to the Edge Function with Authorization header
    SELECT net.http_post(
      url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_ANON_KEY'
      ),
      body := '{}'::jsonb
    ) AS request_id;
  $$
);

-- =====================================================================
-- STEP 4: Verify Configuration
-- =====================================================================

-- Check that the cron job was scheduled successfully
SELECT
  jobid,
  jobname,
  schedule,
  active,
  database,
  username
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';

-- Expected output:
-- jobid | jobname                   | schedule   | active | database | username
-- ------|---------------------------|------------|--------|----------|----------
-- X     | daily-penalty-calculation | 0 9 * * *  | t      | postgres | postgres

-- =====================================================================
-- STEP 5: Test the Cron Job Immediately
-- =====================================================================

-- Test the HTTP request right now (don't wait until tomorrow!)
-- ⚠️ Replace YOUR_PROJECT_REF and YOUR_ANON_KEY below as well!

SELECT net.http_post(
  url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer YOUR_ANON_KEY'
  ),
  body := '{}'::jsonb
) AS request_id;

-- This will return a request_id number. Note it down.

-- Wait 5-10 seconds, then check the response:
SELECT
  id,
  status_code,
  content_type,
  content::text as response_body,
  created
FROM net._http_response
ORDER BY created DESC
LIMIT 1;

-- ✅ Expected: status_code = 200 (Success!)
-- ❌ If you see: status_code = 401 → Double-check your anon key is correct (no extra spaces)
-- ❌ If you see: status_code = 404 → Double-check your project reference is correct

-- =====================================================================
-- MONITORING QUERIES
-- =====================================================================

-- View cron job execution history
SELECT
  runid,
  jobid,
  job_pid,
  database,
  username,
  command,
  status,
  return_message,
  start_time,
  end_time
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
ORDER BY start_time DESC
LIMIT 10;

-- Check HTTP request/response logs from pg_net
SELECT
  id,
  status_code,
  content_type,
  content::json->>'success' as success,
  content::json->>'result' as result,
  created
FROM net._http_response
ORDER BY created DESC
LIMIT 10;

-- Check penalty calculation logs from your application
SELECT
  execution_time,
  result->>'success' as success,
  result->>'users_processed' as users_processed,
  result->>'penalties_created' as penalties_created,
  result->>'date_processed' as date_processed
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 10;

-- =====================================================================
-- TROUBLESHOOTING
-- =====================================================================

-- If you need to update the cron job schedule:
/*
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  schedule := '0 10 * * *'  -- Change to your desired time (this is 10 AM UTC = 1 PM EAT)
);
*/

-- If you need to update the URL or auth key (must unschedule and recreate):
/*
-- Delete the old job
SELECT cron.unschedule('daily-penalty-calculation');

-- Then run the CREATE cron.schedule command again with updated values
*/

-- To temporarily disable the cron job:
/*
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  active := false
);
*/

-- To re-enable:
/*
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  active := true
);
*/

-- To completely remove the cron job:
/*
SELECT cron.unschedule('daily-penalty-calculation');
*/

-- =====================================================================
-- SUCCESS!
-- =====================================================================
-- The cron job is now configured with proper authentication.
-- It will run daily at 9:00 AM UTC (12:00 PM EAT) automatically.
--
-- Next automatic run time:
SELECT
  jobname,
  schedule,
  CASE
    WHEN EXTRACT(HOUR FROM CURRENT_TIME AT TIME ZONE 'UTC') >= 9
    THEN (CURRENT_DATE AT TIME ZONE 'UTC' + INTERVAL '1 day' + TIME '09:00:00')::timestamptz
    ELSE (CURRENT_DATE AT TIME ZONE 'UTC' + TIME '09:00:00')::timestamptz
  END as next_run_utc,
  CASE
    WHEN EXTRACT(HOUR FROM CURRENT_TIME AT TIME ZONE 'UTC') >= 9
    THEN (CURRENT_DATE AT TIME ZONE 'UTC' + INTERVAL '1 day' + TIME '09:00:00')::timestamptz AT TIME ZONE 'Africa/Nairobi'
    ELSE (CURRENT_DATE AT TIME ZONE 'UTC' + TIME '09:00:00')::timestamptz AT TIME ZONE 'Africa/Nairobi'
  END as next_run_eat
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';
-- =====================================================================
