# Cron Job 401 Error - Fix Instructions

## ⚠️ UPDATE: Vault Extension Not Available

The Vault extension is **not enabled** in your Supabase project. Use the **simple version** instead.

---

## 📁 Files Available

### ✅ Use This One: `setup_penalty_cron_simple.sql`
- **Works without Vault extension**
- Stores the anon key directly in the cron command
- **Safe to use** - the anon key is designed for client-side use
- Respects Row Level Security (RLS)

### ❌ Don't Use: `setup_penalty_cron_with_auth.sql`
- Requires Vault extension (not available in your project)
- Will error with: `extension "vault" is not available`
- Only use if Supabase support enables Vault for your project

---

## 🚀 Quick Start (5 Minutes)

### 1. Get Your Credentials

**Project Reference ID:**
- Supabase Dashboard → Settings → General
- Copy the **Reference ID**
- Example: `vrvlqitoyskyzoertfwz`

**Anon/Public Key:**
- Supabase Dashboard → Settings → API
- Copy the **anon/public** key under "Project API keys"
- It's a long string starting with `eyJ...`

### 2. Edit the SQL Script

Open `setup_penalty_cron_simple.sql` and replace:

**Line 41:** Replace `YOUR_PROJECT_REF` with your project reference
```sql
url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties',
```
↓
```sql
url := 'https://vrvlqitoyskyzoertfwz.supabase.co/functions/v1/calculate-penalties',
```

**Line 44:** Replace `YOUR_ANON_KEY` with your anon key
```sql
'Authorization', 'Bearer YOUR_ANON_KEY'
```
↓
```sql
'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

**Line 68:** Replace in the test section as well (same 2 replacements)

### 3. Execute the Script

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Click **New Query**
3. Copy and paste your modified `setup_penalty_cron_simple.sql`
4. Click **Run**

### 4. Verify Success

The script will automatically:
- Enable `pg_cron` and `pg_net` extensions
- Remove any old cron job with the same name
- Create a new cron job with proper authentication
- Run a test HTTP request

**Check the results:**

```sql
-- Should show the cron job is active
SELECT jobid, jobname, schedule, active
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';
```

Expected: `active = t`, `schedule = 0 9 * * *`

```sql
-- Should show HTTP 200 response
SELECT id, status_code, created
FROM net._http_response
ORDER BY created DESC
LIMIT 1;
```

Expected: `status_code = 200` ✅

---

## 🎯 What This Fixes

### Before (Broken)
```
Supabase Dashboard Cron Job
  ↓
HTTP POST (no Authorization header)
  ↓
❌ 401 Unauthorized
```

### After (Fixed)
```
pg_cron Schedule
  ↓
pg_net HTTP POST with Authorization: Bearer {anon_key}
  ↓
Edge Function Gateway (authenticated)
  ↓
✅ 200 Success - Penalties calculated
```

---

## 📊 Monitoring

### Check Cron Execution History
```sql
SELECT
  runid,
  status,
  return_message,
  start_time,
  end_time
FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
ORDER BY start_time DESC
LIMIT 10;
```

### Check HTTP Responses
```sql
SELECT
  id,
  status_code,
  content::json->>'success' as success,
  content::json->>'result'->>'penalties_created' as penalties_created,
  created
FROM net._http_response
ORDER BY created DESC
LIMIT 10;
```

### Check Penalty Calculation Logs
```sql
SELECT
  execution_time,
  result->>'success' as success,
  result->>'users_processed' as users_processed,
  result->>'penalties_created' as penalties_created,
  result->>'date_processed' as date_processed
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 10;
```

---

## ⏰ Schedule Details

- **Cron Expression:** `0 9 * * *`
- **UTC Time:** 9:00 AM
- **EAT Time:** 12:00 PM (UTC+3)
- **Frequency:** Daily

### Change the Schedule

```sql
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  schedule := '0 10 * * *'  -- Change to 10 AM UTC (1 PM EAT)
);
```

---

## 🔧 Troubleshooting

### Still Getting 401 Errors?

**Check your anon key:**
- No extra spaces before or after
- Complete key copied (they're long!)
- From the correct project

**Test manually:**
```bash
curl -X POST https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{}'
```

Should return: `{"success":true,...}`

### Getting 404 Errors?

**Check your project reference:**
- Correct project reference ID
- No typos in the URL
- Format: `https://PROJECT_REF.supabase.co` (no trailing slash)

### Extensions Not Available?

**Error:** `extension "pg_cron" does not exist`

**Solution:** Contact Supabase support to enable `pg_cron` and `pg_net` extensions for your project.

---

## 🔒 Security FAQ

### Is it safe to store the anon key in the cron command?

**Yes!** The anon key is designed for client-side use:
- ✅ Safe to expose in frontend apps
- ✅ Respects Row Level Security (RLS) policies
- ✅ Cannot bypass database permissions
- ✅ Your Edge Function uses service role key internally

### What's the difference between anon key and service role key?

| Key Type | Use Case | RLS Enforcement |
|----------|----------|-----------------|
| **Anon Key** | Client-side, public | ✅ Yes - respects RLS |
| **Service Role** | Backend only, private | ❌ No - bypasses RLS |

For the cron job, we use the **anon key** because:
1. It's safe to use in the database command
2. The Edge Function internally uses service role for database operations
3. RLS policies still protect your data

---

## ✅ Success Checklist

- [ ] Vault extension error encountered (expected)
- [ ] Used `setup_penalty_cron_simple.sql` instead
- [ ] Replaced `YOUR_PROJECT_REF` in 2 places
- [ ] Replaced `YOUR_ANON_KEY` in 2 places
- [ ] Executed script in SQL Editor
- [ ] Verified cron job is active (`active = t`)
- [ ] Test HTTP response shows `status_code = 200`
- [ ] Removed/disabled any old Dashboard cron jobs
- [ ] Checked `penalty_calculation_log` shows successful execution

---

## 📞 Need Help?

1. **Quick reference:** [QUICK_FIX_401_ERROR.md](QUICK_FIX_401_ERROR.md)
2. **Detailed guide:** [FIX_401_CRON_AUTHENTICATION.md](FIX_401_CRON_AUTHENTICATION.md)
3. **Deployment docs:** [DEPLOYMENT_INSTRUCTIONS_PHASE2.md](DEPLOYMENT_INSTRUCTIONS_PHASE2.md)

---

**Status:** Ready to deploy
**Version:** Simple (no Vault)
**Last Updated:** November 13, 2025
