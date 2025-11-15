# Phase 2: Edge Function Deployment

## Prerequisites

Before deploying the Edge Function, ensure:
- ✅ Phase 1 completed (database functions deployed)
- ✅ Supabase CLI installed
- ✅ Access to your Supabase project

---

## Step 1: Install Supabase CLI

### Windows (PowerShell)
```powershell
# Install using Scoop
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### Or using npm
```bash
npm install -g supabase
```

### Verify Installation
```bash
supabase --version
```

---

## Step 2: Login and Link Project

### 2.1 Login to Supabase
```bash
supabase login
```

This will open your browser for authentication. Follow the prompts.

### 2.2 Link to Your Project
```bash
cd d:\sabiquun_app
supabase link --project-ref YOUR_PROJECT_REF
```

**To find your PROJECT_REF:**
1. Go to https://supabase.com/dashboard
2. Select your Sabiquun project
3. Go to **Settings** → **General**
4. Copy the **Reference ID** (looks like: `abcdefghijklmnop`)

**Example:**
```bash
supabase link --project-ref abcdefghijklmnop
```

---

## Step 3: Deploy the Edge Function

### 3.1 Deploy
```bash
supabase functions deploy calculate-penalties
```

**Expected output:**
```
Deploying function calculate-penalties...
Function URL: https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties
Deployment complete!
```

### 3.2 Verify Deployment
Go to Supabase Dashboard → **Edge Functions**

You should see `calculate-penalties` listed with status: **Active**

---

## Step 4: Test Manual Invocation

### 4.1 Test via CLI
```bash
supabase functions invoke calculate-penalties
```

**Expected output:**
```json
{
  "success": true,
  "result": {
    "success": true,
    "date_processed": "2025-11-03",
    "users_processed": 0,
    "penalties_created": 0,
    "target_deeds": 10.0,
    "penalty_per_deed": 5000,
    "errors": [],
    "timestamp": "2025-11-04T10:30:00"
  },
  "timestamp": "2025-11-04T10:30:00.123Z",
  "timezone": "EAT (UTC+3)"
}
```

### 4.2 Test via HTTP
```bash
curl -X POST \
  https://YOUR_PROJECT_REF.supabase.co/functions/v1/calculate-penalties \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

**To find your ANON_KEY:**
1. Supabase Dashboard → **Settings** → **API**
2. Copy **anon/public** key

---

## Step 5: Setup Automatic Cron Trigger with Authentication

**IMPORTANT:** The Supabase Dashboard cron feature does NOT include authentication headers, which will cause 401 errors. We'll use `pg_cron` with `pg_net` instead for proper authentication.

### 5.1 Prepare Required Information

Before starting, gather these values:

1. **Project Reference ID**
   - Go to: Supabase Dashboard → Settings → General
   - Copy the **Reference ID** (e.g., `vrvlqitoyskyzoertfwz`)

2. **Anon/Public Key**
   - Go to: Supabase Dashboard → Settings → API
   - Copy the **anon/public** key under "Project API keys"

### 5.2 Execute Cron Setup SQL Script

1. Open the file `setup_penalty_cron_with_auth.sql` in your project root
2. Replace these placeholders with your actual values:
   - `YOUR_PROJECT_REF` → Your project reference ID
   - `YOUR_ANON_KEY` → Your anon/public key
3. Open **Supabase Dashboard** → **SQL Editor** → **New Query**
4. Copy and paste the entire modified script
5. Click **Run** to execute

**What this script does:**
- Enables required extensions: `vault`, `pg_cron`, `pg_net`
- Stores your credentials securely in Supabase Vault
- Creates a cron job that runs daily at 9:00 AM UTC (12:00 PM EAT)
- Includes proper `Authorization` header to prevent 401 errors

### 5.3 Verify Configuration

After running the script, verify everything is set up correctly:

**Check secrets are stored:**
```sql
SELECT name, description, created_at
FROM vault.decrypted_secrets
WHERE name IN ('supabase_project_url', 'supabase_anon_key');
```

**Check cron job is scheduled:**
```sql
SELECT jobid, jobname, schedule, active
FROM cron.job
WHERE jobname = 'daily-penalty-calculation';
```

**Expected output:** Job with schedule `0 9 * * *` and `active = t`

### 5.4 Test Immediately (Don't Wait for Tomorrow!)

Test the cron job right now to ensure it works:

```sql
-- Make a test HTTP request with authentication
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

**Then check the response (wait 5-10 seconds):**
```sql
SELECT id, status_code, content::json->>'success' as success, created
FROM net._http_response
ORDER BY created DESC
LIMIT 1;
```

✅ **Expected:** `status_code = 200` and `success = true`
❌ **If you see:** `status_code = 401` → Double-check your anon key is correct

**Cron Expression Reference:**
```
0 9 * * *
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, both 0 and 7 are Sunday)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23) [9 = 9:00 AM UTC]
└─────────── Minute (0-59) [0 = :00]
```

**Timezone Conversion:**
- **EAT (East Africa Time):** UTC+3
- **Target Time:** 12:00 PM EAT
- **UTC Time:** 9:00 AM UTC
- **Cron Expression:** `0 9 * * *`

---

## Step 6: Monitor First Execution

### 6.1 View Function Logs

1. Go to **Edge Functions** → `calculate-penalties`
2. Click **Logs** tab
3. Set time range to **Last 24 hours**

### 6.2 Expected Log Output

After first automatic run (tomorrow at 12 PM EAT), you should see:

```
=== Starting Automatic Penalty Calculation ===
Timestamp: 2025-11-05T09:00:00.000Z
Timezone: EAT (UTC+3)
✅ Penalty calculation completed: { success: true, ... }
📧 Processing notifications for X new penalties...
✅ Notification queued for user: [Name] (X shillings)
📬 Notification queuing complete
🔍 Checking for users approaching deactivation threshold...
✅ No users approaching deactivation threshold
=== Penalty Calculation Function Complete ===
```

### 6.3 Verify in Database

```sql
-- Check latest execution log
SELECT *
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 1;

-- Check penalties created today
SELECT p.*, u.name
FROM penalties p
JOIN users u ON p.user_id = u.id
WHERE p.date_incurred = CURRENT_DATE - INTERVAL '1 day'
ORDER BY p.created_at DESC;

-- Check notification queue
SELECT *
FROM notification_queue
WHERE created_at > CURRENT_DATE
ORDER BY created_at DESC;
```

---

## Step 7: Environment Variables (Optional)

The function automatically uses:
- `SUPABASE_URL` - Injected by Supabase
- `SUPABASE_SERVICE_ROLE_KEY` - Injected by Supabase

If you need additional environment variables (for FCM, etc.), add them:

1. Go to **Edge Functions** → `calculate-penalties`
2. Click **Settings** tab
3. Add **Environment Variables**
4. Example:
   - `FCM_SERVER_KEY` = your_firebase_server_key
   - `MAILGUN_API_KEY` = your_mailgun_key

---

## Troubleshooting

### Function deployment fails
**Error:** `Project not linked`
**Solution:** Run `supabase link --project-ref YOUR_REF` first

### Function runs but returns error
**Check logs:**
```bash
supabase functions logs calculate-penalties
```

### 401 Unauthorized Error
**Error:** HTTP response shows `status_code = 401`

**Cause:** Missing or incorrect authorization header

**Solution:**
1. Verify you completed Step 5 (pg_cron setup, NOT dashboard cron)
2. Check your anon key is correct:
   ```sql
   SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'supabase_anon_key';
   ```
3. If wrong, delete and recreate:
   ```sql
   SELECT vault.delete_secret('supabase_anon_key');
   SELECT vault.create_secret('YOUR_CORRECT_ANON_KEY', 'supabase_anon_key', 'Anon key');
   ```

### Cron job doesn't run
**Verify:**
```sql
-- Check job exists and is active
SELECT * FROM cron.job WHERE jobname = 'daily-penalty-calculation';

-- Check execution history
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation')
ORDER BY start_time DESC LIMIT 5;
```

### Extensions not available
**Error:** `extension "vault" does not exist`

**Solution:** Enable extensions manually:
```sql
CREATE EXTENSION IF NOT EXISTS vault;
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;
```

If still failing, contact Supabase support—some extensions may need project-level enablement.

### Wrong timezone
**Adjust cron expression:**
- For 12 PM EAT (UTC+3): Use `0 9 * * *` (9 AM UTC)
- For 1 PM EAT: Use `0 10 * * *` (10 AM UTC)
- For 11 AM EAT: Use `0 8 * * *` (8 AM UTC)

**To change schedule:**
```sql
SELECT cron.alter_job(
  job_id := (SELECT jobid FROM cron.job WHERE jobname = 'daily-penalty-calculation'),
  schedule := '0 10 * * *'  -- Change to your desired time
);
```

---

## ✅ Phase 2 Complete!

Checklist:
- ✅ Supabase CLI installed
- ✅ Project linked
- ✅ Edge Function deployed
- ✅ Manual test successful via CLI
- ✅ pg_cron configured with Vault authentication (NOT dashboard cron)
- ✅ Cron job scheduled (0 9 * * * UTC = 12 PM EAT)
- ✅ Test HTTP request returns status 200 (not 401)
- ✅ Logs showing successful execution in database

**IMPORTANT:** If you used the Supabase Dashboard cron feature earlier, make sure to disable/delete it. Only the pg_cron setup (Step 5) should be active to avoid 401 errors.

**Next:** Phase 3 - Notification System Integration

---

## Quick Reference Commands

```bash
# Deploy function
supabase functions deploy calculate-penalties

# Test manually
supabase functions invoke calculate-penalties

# View logs
supabase functions logs calculate-penalties

# View logs in real-time
supabase functions logs calculate-penalties --tail

# Delete function (if needed)
supabase functions delete calculate-penalties
```

---

## Maintenance

### Update Function Code
1. Edit `supabase/functions/calculate-penalties/index.ts`
2. Run: `supabase functions deploy calculate-penalties`
3. Test: `supabase functions invoke calculate-penalties`

### Disable Automatic Execution (Temporarily)
1. Go to Dashboard → Edge Functions → calculate-penalties
2. Find the cron job
3. Toggle **Enabled** to OFF

### Re-enable
1. Toggle **Enabled** to ON
