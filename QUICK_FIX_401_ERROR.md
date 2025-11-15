# Quick Fix: 401 Error in Penalty Cron Job

## Problem
Your cron job is returning **401 Unauthorized** because it's not sending authentication headers.

## Solution (5 Minutes)

### Step 1: Get Your Credentials
1. Go to Supabase Dashboard → **Settings** → **General** → Copy **Reference ID**
   - Example: `vrvlqitoyskyzoertfwz`
2. Go to **Settings** → **API** → Copy **anon/public** key
   - It's a long string starting with `eyJ...`

### Step 2: Run This SQL
1. Open `setup_penalty_cron_simple.sql` (**use the simple version!** - the Vault extension isn't available)
2. Replace `YOUR_PROJECT_REF` with your reference ID (in 2 places)
3. Replace `YOUR_ANON_KEY` with your anon key (in 2 places)
4. Go to Supabase Dashboard → **SQL Editor** → **New Query**
5. Paste the modified script and **Run**

### Step 3: Verify It Worked
The script already includes a test at the end. Check the results:

```sql
-- Check the cron job was created
SELECT jobid, jobname, schedule, active
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';
```

Should show: `active = t` and `schedule = 0 9 * * *`

**Then check the test HTTP response:**
```sql
SELECT id, status_code, created
FROM net._http_response
ORDER BY created DESC
LIMIT 1;
```

✅ **Success:** `status_code = 200`
❌ **Failed:** `status_code = 401` → Check your anon key is correct (no extra spaces!)
❌ **Failed:** `status_code = 404` → Check your project reference is correct

### Step 4: Remove Old Dashboard Cron (If Exists)
If you previously set up a cron job through the Supabase Dashboard:
1. Go to **Edge Functions** → `calculate-penalties`
2. Delete/disable any cron jobs listed there
3. Only the SQL-based cron (from Step 2) should be active

## What Changed?
- **Before:** Dashboard cron → No auth header → 401 error ❌
- **After:** pg_cron with Authorization header → 200 success ✅

## Monitoring
```sql
-- Check cron job runs
SELECT runid, status, return_message, start_time, end_time
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
ORDER BY start_time DESC LIMIT 5;

-- Check HTTP responses
SELECT id, status_code, content::json->>'success' as success, created
FROM net._http_response
ORDER BY created DESC LIMIT 10;

-- Check penalty calculations
SELECT execution_time, result->>'success' as success,
       result->>'penalties_created' as penalties_created
FROM penalty_calculation_log
ORDER BY execution_time DESC LIMIT 5;
```

## Security Note
The simple version stores the anon key directly in the cron command. This is safe because:
- The anon key is designed to be used client-side
- It respects Row Level Security (RLS) policies
- Your Edge Function uses the service role key internally for elevated permissions

## Need More Details?
- Full guide: [FIX_401_CRON_AUTHENTICATION.md](FIX_401_CRON_AUTHENTICATION.md)
- Updated deployment: [DEPLOYMENT_INSTRUCTIONS_PHASE2.md](DEPLOYMENT_INSTRUCTIONS_PHASE2.md)
