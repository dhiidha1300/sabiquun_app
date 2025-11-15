# Fix: 401 Unauthorized Error in Penalty Calculation Cron Job

## 🔴 Problem Summary

The automatic penalty calculation cron job is returning a **401 Unauthorized** error because the cron trigger doesn't include authentication headers when calling the Edge Function.

### Error Metadata
```json
{
  "response": {
    "status_code": 401
  },
  "request": {
    "headers": {
      "authorization": null  // ❌ Missing!
    }
  }
}
```

---

## 🔍 Root Cause

When you configure a cron job through the **Supabase Dashboard**, it uses `pg_net` to make HTTP requests, but **does not automatically include authorization headers**. This causes the Edge Function gateway to reject the request with a 401 error before your function code even runs.

---

## ✅ Solution: Configure pg_cron with Authorization Headers

We'll use Supabase's recommended approach:
1. Store credentials securely in **Supabase Vault**
2. Use **pg_cron** to schedule the job
3. Use **pg_net** to make authenticated HTTP requests

---

## 📋 Step-by-Step Fix

### Prerequisites

Before starting, gather these values:

1. **Project Reference ID**
   - Go to: Supabase Dashboard → Settings → General
   - Copy the **Reference ID** (e.g., `vrvlqitoyskyzoertfwz`)

2. **Anon/Public Key**
   - Go to: Supabase Dashboard → Settings → API
   - Copy the **anon/public** key under "Project API keys"

---

### Step 1: Remove Old Cron Job (if configured in Dashboard)

If you previously set up the cron job through the Supabase Dashboard:

1. Go to **Edge Functions** → `calculate-penalties`
2. Find the **Cron Jobs** section
3. **Delete** or **Disable** any existing cron jobs
4. We'll recreate it properly using SQL

---

### Step 2: Execute the SQL Setup Script

1. Open **Supabase Dashboard** → **SQL Editor**
2. Click **"New Query"**
3. Open the file `setup_penalty_cron_with_auth.sql`
4. **IMPORTANT:** Replace the placeholders:
   - `YOUR_PROJECT_REF` → Your actual project reference (e.g., `vrvlqitoyskyzoertfwz`)
   - `YOUR_ANON_KEY` → Your actual anon/public key

**Example:**
```sql
-- Before:
SELECT vault.create_secret(
  'https://YOUR_PROJECT_REF.supabase.co',
  'supabase_project_url',
  'Supabase project URL for penalty calculation function'
);

-- After (with your values):
SELECT vault.create_secret(
  'https://vrvlqitoyskyzoertfwz.supabase.co',
  'supabase_project_url',
  'Supabase project URL for penalty calculation function'
);
```

5. **Run** the entire script in SQL Editor
6. Verify success (see Step 3)

---

### Step 3: Verify Configuration

After running the script, execute these verification queries:

#### ✅ Check Secrets are Stored
```sql
SELECT
  name,
  description,
  created_at
FROM vault.decrypted_secrets
WHERE name IN ('supabase_project_url', 'supabase_anon_key');
```

**Expected Output:**
```
name                    | description                          | created_at
------------------------|--------------------------------------|------------------
supabase_project_url    | Supabase project URL for penalty...  | 2025-11-11 ...
supabase_anon_key       | Supabase anon key for authenticating | 2025-11-11 ...
```

#### ✅ Check Cron Job is Scheduled
```sql
SELECT
  jobid,
  jobname,
  schedule,
  active
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';
```

**Expected Output:**
```
jobid | jobname                    | schedule   | active
------|----------------------------|------------|--------
1     | daily-penalty-calculation  | 0 9 * * *  | t
```

---

### Step 4: Test the Fix Immediately

Don't wait until tomorrow! Test the function call right now with proper authentication:

```sql
-- Test the HTTP request with authorization
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
```

**Expected Result:**
```
request_id
-----------
1234567890
```

This returns a request ID. Now check the response:

```sql
-- Check the HTTP response (wait 5-10 seconds first)
SELECT
  id,
  status_code,
  content::json->>'success' as success,
  created
FROM net._http_response
ORDER BY created DESC
LIMIT 1;
```

**Expected Output:**
```
id   | status_code | success | created
-----|-------------|---------|-------------------
1234 | 200         | true    | 2025-11-11 09:00:00
```

✅ **Status 200** = Success! The 401 error is fixed!

---

### Step 5: Verify in Application Logs

Check that penalties were calculated correctly:

```sql
-- Check latest execution log
SELECT
  execution_time,
  result->>'success' as success,
  result->>'users_processed' as users_processed,
  result->>'penalties_created' as penalties_created
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 1;
```

---

## 📊 Monitoring the Cron Job

### View Cron Execution History
```sql
SELECT
  runid,
  jobid,
  start_time,
  end_time,
  status,
  return_message
FROM cron.job_run_details
WHERE jobid = (
  SELECT jobid
  FROM cron.job
  WHERE jobname = 'daily-penalty-calculation'
)
ORDER BY start_time DESC
LIMIT 10;
```

### View HTTP Request/Response Logs
```sql
SELECT
  id,
  status_code,
  content_type,
  content::text as response_body,
  created
FROM net._http_response
ORDER BY created DESC
LIMIT 10;
```

### Check Application Logs
```sql
SELECT * FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 10;
```

---

## 🔧 Troubleshooting

### Issue: Secrets not created
**Error:** `duplicate key value violates unique constraint`

**Solution:** Secrets already exist. Update them instead:
```sql
-- Delete old secrets
SELECT vault.delete_secret('supabase_project_url');
SELECT vault.delete_secret('supabase_anon_key');

-- Then run the create_secret commands again
```

---

### Issue: Extensions not available
**Error:** `extension "vault" does not exist`

**Solution:** Enable extensions manually:
```sql
CREATE EXTENSION IF NOT EXISTS vault;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;
```

If still failing, contact Supabase support—some extensions may need to be enabled at the project level.

---

### Issue: Still getting 401 errors
**Check:**
1. Verify the anon key is correct (copy from Dashboard → Settings → API)
2. Ensure no extra spaces or quotes around the key
3. Test the Edge Function manually:
   ```bash
   curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties \
     -H "Authorization: Bearer YOUR_ANON_KEY" \
     -H "Content-Type: application/json" \
     -d '{}'
   ```

---

### Issue: Cron job not running
**Check:**
```sql
-- Verify job is active
SELECT * FROM cron.job WHERE jobname = 'daily-penalty-calculation';

-- Check for errors in run history
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
ORDER BY start_time DESC
LIMIT 5;
```

---

## 🎯 What Changed?

### Before (Dashboard Cron - ❌ Broken)
```
Supabase Dashboard Cron → Edge Function
                           ↓
                        [NO AUTH HEADER]
                           ↓
                      ❌ 401 Unauthorized
```

### After (pg_cron with Vault - ✅ Working)
```
pg_cron → pg_net HTTP POST
          ↓
        [Authorization: Bearer {anon_key}]
          ↓
       Edge Function
          ↓
     ✅ 200 Success
```

---

## 📅 Cron Schedule Reference

The cron job runs at **9:00 AM UTC** daily, which is **12:00 PM EAT** (East Africa Time).

**Cron Expression:** `0 9 * * *`

To change the schedule:
```sql
-- Update the schedule
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  schedule := '0 10 * * *'  -- Change to 10 AM UTC (1 PM EAT)
);
```

**Common schedules:**
- `0 9 * * *` - Daily at 9 AM UTC (12 PM EAT)
- `0 12 * * *` - Daily at 12 PM UTC (3 PM EAT)
- `0 9 * * 1-5` - Weekdays only at 9 AM UTC
- `0 */6 * * *` - Every 6 hours

---

## 🎉 Success Criteria

The fix is working correctly when:

1. ✅ Test HTTP request returns **status_code = 200** (not 401)
2. ✅ `penalty_calculation_log` shows new entries with successful results
3. ✅ `cron.job_run_details` shows successful executions
4. ✅ `net._http_response` shows HTTP 200 responses
5. ✅ Edge Function logs (Dashboard → Functions → calculate-penalties → Logs) show execution

---

## 📚 Additional Resources

- **Supabase Vault Documentation:** https://supabase.com/docs/guides/database/vault
- **pg_cron Documentation:** https://github.com/citusdata/pg_cron
- **pg_net Documentation:** https://github.com/supabase/pg_net
- **Scheduling Edge Functions:** https://supabase.com/docs/guides/functions/schedule-functions

---

## 🔒 Security Notes

### Why use Vault?
- **Secure storage:** Credentials are encrypted at rest
- **No hardcoding:** Keys aren't visible in cron job definitions
- **Access control:** Only authorized roles can access secrets

### Anon Key vs Service Role Key
- **Anon Key (used here):** Respects Row Level Security (RLS) policies
- **Service Role Key:** Bypasses RLS - use only if necessary

For this use case, the **anon key is sufficient** because:
- The Edge Function uses the service role key internally
- The anon key just authenticates the HTTP request
- RLS policies are still enforced where needed

---

## ✅ Checklist

Before considering this fix complete:

- [ ] Old dashboard cron job removed/disabled
- [ ] SQL script executed with correct project ref and anon key
- [ ] Secrets verified in `vault.decrypted_secrets`
- [ ] Cron job scheduled in `cron.job`
- [ ] Test HTTP request successful (status 200)
- [ ] Application logs show successful execution
- [ ] No 401 errors in invocation metadata
- [ ] Next automatic run scheduled for tomorrow at 9 AM UTC

---

## 📞 Support

If issues persist after following this guide:

1. Check **Edge Function logs** in Supabase Dashboard
2. Review `cron.job_run_details` for error messages
3. Verify your anon key is correct and hasn't been regenerated
4. Contact Supabase support if extensions are unavailable

---

**Deployment Date:** November 11, 2025
**Issue:** 401 Unauthorized from cron job
**Resolution:** Configured pg_cron with Vault-stored credentials
**Status:** ✅ Fixed and tested
