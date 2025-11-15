-- =====================================================================
-- Setup Automatic Penalty Calculation Cron Job with Authorization
-- =====================================================================
-- This script fixes the 401 unauthorized error when the cron job
-- triggers the Edge Function by properly configuring authentication
-- =====================================================================

-- INSTRUCTIONS:
-- 1. Replace YOUR_PROJECT_REF with your actual Supabase project reference ID
-- 2. Replace YOUR_ANON_KEY with your actual Supabase anon/public key
-- 3. Execute this script in the Supabase SQL Editor
-- 4. After execution, the cron job will run daily at 9:00 AM UTC (12:00 PM EAT)

-- =====================================================================
-- STEP 1: Enable Required Extensions
-- =====================================================================

-- Enable Vault extension for secure secret storage
CREATE EXTENSION IF NOT EXISTS vault;

-- Enable pg_cron for scheduled jobs
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Enable pg_net for HTTP requests
CREATE EXTENSION IF NOT EXISTS pg_net;

-- =====================================================================
-- STEP 2: Store Credentials Securely in Vault
-- =====================================================================

-- Store your Supabase project URL
-- IMPORTANT: Replace YOUR_PROJECT_REF with your actual project reference
SELECT vault.create_secret(
  'https://YOUR_PROJECT_REF.supabase.co',
  'supabase_project_url',
  'Supabase project URL for penalty calculation function'
);

-- Store your Supabase anon/public key
-- IMPORTANT: Replace YOUR_ANON_KEY with your actual anon key
-- Find it at: Dashboard → Settings → API → Project API keys → anon/public
SELECT vault.create_secret(
  'YOUR_ANON_KEY',
  'supabase_anon_key',
  'Supabase anon key for authenticating cron job requests'
);

-- =====================================================================
-- STEP 3: Remove Old Cron Job (if exists)
-- =====================================================================

-- First, check if there's an existing cron job and remove it
-- This prevents duplicate executions
SELECT cron.unschedule('daily-penalty-calculation')
WHERE EXISTS (
  SELECT 1 FROM cron.job WHERE jobname = 'daily-penalty-calculation'
);

-- =====================================================================
-- STEP 4: Create New Cron Job with Authorization Header
-- =====================================================================

-- Schedule the penalty calculation to run daily at 9:00 AM UTC (12:00 PM EAT)
-- This includes proper Authorization header to fix the 401 error
SELECT cron.schedule(
  'daily-penalty-calculation',        -- Job name
  '0 9 * * *',                         -- Cron expression: 9:00 AM UTC daily
  $$
    -- Make HTTP POST request to the Edge Function
    SELECT net.http_post(
      -- Construct the full URL from vault secret
      url := (
        SELECT decrypted_secret
        FROM vault.decrypted_secrets
        WHERE name = 'supabase_project_url'
      ) || '/functions/v1/calculate-penalties',

      -- Include required headers with Authorization
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer ' || (
          SELECT decrypted_secret
          FROM vault.decrypted_secrets
          WHERE name = 'supabase_anon_key'
        )
      ),

      -- Send empty JSON body (function doesn't need parameters)
      body := '{}'::jsonb
    ) AS request_id;
  $$
);

-- =====================================================================
-- STEP 5: Verify Configuration
-- =====================================================================

-- Check that secrets were created successfully
SELECT
  name,
  description,
  created_at
FROM vault.decrypted_secrets
WHERE name IN ('supabase_project_url', 'supabase_anon_key');

-- Check that the cron job was scheduled successfully
SELECT
  jobid,
  schedule,
  command,
  nodename,
  nodeport,
  database,
  username,
  active,
  jobname
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';

-- =====================================================================
-- STEP 6: Test the Cron Job Immediately (Optional)
-- =====================================================================

-- Uncomment the following to test the function call immediately:
/*
SELECT net.http_post(
  url := (
    SELECT decrypted_secret
    FROM vault.decrypted_secrets
    WHERE name = 'supabase_project_url'
  ) || '/functions/v1/calculate-penalties',
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'Authorization', 'Bearer ' || (
      SELECT decrypted_secret
      FROM vault.decrypted_secrets
      WHERE name = 'supabase_anon_key'
    )
  ),
  body := '{}'::jsonb
) AS request_id;
*/

-- =====================================================================
-- MONITORING QUERIES
-- =====================================================================

-- View cron job execution history
-- SELECT * FROM cron.job_run_details
-- WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
-- ORDER BY start_time DESC
-- LIMIT 10;

-- Check HTTP request/response logs from pg_net
-- SELECT * FROM net._http_response
-- ORDER BY created DESC
-- LIMIT 10;

-- Check penalty calculation logs from your application
-- SELECT * FROM penalty_calculation_log
-- ORDER BY execution_time DESC
-- LIMIT 10;

-- =====================================================================
-- SUCCESS!
-- =====================================================================
-- The cron job is now configured with proper authentication.
-- It will run daily at 9:00 AM UTC (12:00 PM EAT) automatically.
--
-- Next run time can be checked with:
-- SELECT jobname, schedule,
--        (now() AT TIME ZONE 'UTC')::date + interval '1 day' + time '09:00:00' as next_run
-- FROM cron.job
-- WHERE jobname = 'daily-penalty-calculation';
-- =====================================================================
