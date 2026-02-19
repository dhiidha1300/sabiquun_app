# Edge Function Deployment Guide
## WhatsApp Notification Edge Function

This guide provides step-by-step instructions for deploying and scheduling the WhatsApp notification Edge Function.

**Two deployment methods available:**
1. **Manual Deployment (Dashboard)** ⭐ Recommended for beginners
2. **CLI Deployment** - For advanced users and automation

----

## Quick Start (Dashboard Method)

For those who want to get started quickly:

1. Copy code from `d:\sabiquun_app\supabase\functions\send-whatsapp-notification\index.ts`
2. Go to your [Supabase Dashboard](https://app.supabase.com/) > **Edge Functions**
3. Click **"Create a new function"**
4. Name: `send-whatsapp-notification`
5. Paste the code and click **"Deploy function"**
6. Go to **SQL Editor** and run:
   ```sql
   CREATE EXTENSION IF NOT EXISTS pg_cron;

   SELECT cron.schedule(
     'process-whatsapp-notifications',
     '*/5 * * * *',
     $$
     SELECT net.http_post(
       url := 'https://YOUR_PROJECT_URL/functions/v1/send-whatsapp-notification',
       headers := jsonb_build_object('Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'),
       body := jsonb_build_object('limit', 50)
     ) AS request_id;
     $$
   );
   ```
   Replace `YOUR_PROJECT_URL` and `YOUR_SERVICE_ROLE_KEY` from **Settings** > **API**

Done! Your WhatsApp notifications will process every 5 minutes.

---

## Prerequisites

- Supabase project created
- WhatsApp Business API configured
- Database migration completed

---

## Method 1: Manual Deployment via Dashboard (Recommended)

**Deployment Workflow**:
```
1. Copy code from local file
   ↓
2. Create function in Dashboard
   ↓
3. Deploy function
   ↓
4. Test with sample request
   ↓
5. Set up cron job for automation
```

### Step 1: Prepare the Function Code

1. Open the Edge Function file on your computer:
   ```
   d:\sabiquun_app\supabase\functions\send-whatsapp-notification\index.ts
   ```

2. Copy the entire contents of the file

### Step 2: Create Function in Supabase Dashboard

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to **Edge Functions** (left sidebar)
4. Click the **"Create a new function"** button

### Step 3: Configure the Function

1. **Function Name**: Enter `send-whatsapp-notification`
2. **Function Code**: Paste the code you copied from `index.ts`
3. Click **"Deploy function"** button

### Step 4: Verify Deployment

1. You should see the function listed in the Edge Functions page
2. Note the function URL displayed (format: `https://your-project-ref.supabase.co/functions/v1/send-whatsapp-notification`)
3. Function status should show as "Active" or "Deployed"

### Step 5: Test the Function (Dashboard Method)

1. In the Edge Functions page, click on `send-whatsapp-notification`
2. Click the **"Invoke function"** button
3. In the request body, enter:
   ```json
   {
     "limit": 5
   }
   ```
4. Click **"Run"**
5. Check the response - should show:
   ```json
   {
     "success": true,
     "processed": 0,
     "sent": 0,
     "failed": 0,
     "errors": [],
     "timestamp": "2025-01-23T10:30:00.000Z"
   }
   ```

### Step 6: View Logs (Dashboard Method)

1. In the Edge Functions page, click on `send-whatsapp-notification`
2. Click the **"Logs"** tab
3. You can see all function invocations, errors, and console logs here
4. Use filters to find specific log entries

### Step 7: Manual Trigger (Optional)

To manually process pending notifications anytime:

1. Go to **Edge Functions** > `send-whatsapp-notification`
2. Click **"Invoke function"**
3. Enter request body:
   ```json
   {"limit": 10}
   ```
4. Click **"Run"**
5. Check the response and logs

This is useful for:
- Testing after configuration changes
- Immediate processing of queued notifications
- Troubleshooting delivery issues

---

## Method 2: CLI Deployment (Optional)

### Part 1: Install Supabase CLI

### Windows

```powershell
# Using scoop (recommended)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Or using npm
npm install -g supabase
```

### macOS

```bash
# Using Homebrew
brew install supabase/tap/supabase

# Or using npm
npm install -g supabase
```

### Linux

```bash
# Using npm (recommended for all Linux distributions)
npm install -g supabase
```

### Verify Installation

```bash
supabase --version
```

### Part 2: Link Your Supabase Project

### Step 1: Get Your Project Ref

1. Go to your [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Go to **Settings** > **General**
4. Copy your **Project ID** (Reference ID)

### Step 2: Login to Supabase CLI

```bash
supabase login
```

This will open a browser window for authentication.

### Step 3: Link Your Project

```bash
cd d:/sabiquun_app
supabase link --project-ref YOUR_PROJECT_REF
```

Replace `YOUR_PROJECT_REF` with the Project ID from Step 1.

You'll be prompted to enter your database password.

### Part 3: Deploy the Edge Function

#### Step 1: Navigate to Project Directory

```bash
cd d:/sabiquun_app
```

#### Step 2: Deploy the Function

```bash
supabase functions deploy send-whatsapp-notification
```

This will:
- Package the function code
- Upload to Supabase
- Create the function endpoint
- Return the function URL

Expected output:
```
Deploying Function send-whatsapp-notification (project ref: your-project-ref)
Bundled send-whatsapp-notification in X seconds
Function deployed successfully!
Function URL: https://your-project.supabase.co/functions/v1/send-whatsapp-notification
```

#### Step 3: Verify Deployment

Check if the function is deployed:

```bash
supabase functions list
```

You should see `send-whatsapp-notification` in the list.

---

## Common Steps (Both Methods)

### Set Up Environment Variables (Optional - CLI Only)

If your function needs custom environment variables:

```bash
# Set an environment variable
supabase secrets set MY_SECRET_KEY=value

# List all secrets
supabase secrets list

# Unset a secret
supabase secrets unset MY_SECRET_KEY
```

For WhatsApp function, the required variables are already stored in the database settings table, so no additional secrets are needed.

---

### Test the Function

#### Get Your API Credentials

Before testing, you need to get your API keys:

1. Go to **Settings** > **API** in your Supabase Dashboard
2. Find your **Project URL** (format: `https://xxxxx.supabase.co`)
3. Copy the **anon** **public** key for testing

#### Manual Test via cURL

```bash
curl -X POST 'https://your-project-ref.supabase.co/functions/v1/send-whatsapp-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"limit": 5}'
```

Replace:
- `your-project-ref.supabase.co` with your **Project URL** from Settings > API
- `YOUR_ANON_KEY` with your **anon public** key from Settings > API

Expected response:
```json
{
  "success": true,
  "processed": 0,
  "sent": 0,
  "failed": 0,
  "errors": [],
  "timestamp": "2025-01-23T10:30:00.000Z"
}
```

### Test with Postman

1. Create a new POST request
2. URL: `https://your-project-ref.supabase.co/functions/v1/send-whatsapp-notification`
3. Headers:
   - `Authorization`: `Bearer YOUR_ANON_KEY`
   - `Content-Type`: `application/json`
4. Body (raw JSON):
   ```json
   {
     "limit": 10
   }
   ```
5. Send the request

---

### Set Up Automatic Invocation

You have two options for automatically processing WhatsApp notifications:

#### Option A: Scheduled Cron Job (Recommended)

Create a cron job that runs every 5 minutes using `pg_cron`.

**Step 1: Get Your Service Role Key**

1. Go to **Settings** > **API** in Supabase Dashboard
2. Find the **service_role** key (click "Reveal" to show it)
3. Copy this key - you'll need it for the cron job
4. ⚠️ **Important**: This key has admin access - keep it secure!

**Step 2: Enable pg_cron Extension**

Run this in Supabase SQL Editor:

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

**Step 3: Create the Cron Job**

Run this in Supabase SQL Editor (replace the placeholders):

```sql
-- Schedule the WhatsApp notification processing every 5 minutes
SELECT cron.schedule(
  'process-whatsapp-notifications',  -- Job name
  '*/5 * * * *',                      -- Every 5 minutes (cron schedule)
  $$
  SELECT
    net.http_post(
      url := 'https://YOUR_PROJECT_URL/functions/v1/send-whatsapp-notification',
      headers := jsonb_build_object(
        'Content-Type', 'application/json',
        'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
      ),
      body := jsonb_build_object('limit', 50)
    ) AS request_id;
  $$
);
```

**Replace these values** (from Settings > API):
- `YOUR_PROJECT_URL`: Your full project URL (e.g., `https://xxxxx.supabase.co`)
- `YOUR_SERVICE_ROLE_KEY`: Your service_role key (click "Reveal" to show)

**Step 4: Verify Cron Job**

```sql
-- Check if cron job was created
SELECT * FROM cron.job WHERE jobname = 'process-whatsapp-notifications';

-- View cron job run history
SELECT * FROM cron.job_run_details
WHERE jobid = (SELECT jobid FROM cron.job WHERE jobname = 'process-whatsapp-notifications')
ORDER BY start_time DESC
LIMIT 10;
```

**Step 5: Update or Delete Cron Job (if needed)**

```sql
-- Update cron schedule (example: every 10 minutes)
SELECT cron.schedule(
  'process-whatsapp-notifications',
  '*/10 * * * *',  -- New schedule
  $$
  SELECT net.http_post(...) AS request_id;
  $$
);

-- Delete cron job
SELECT cron.unschedule('process-whatsapp-notifications');
```

#### Option B: Database Trigger (Real-time)

Trigger the Edge Function immediately when a notification is queued:

```sql
-- Create a function to trigger Edge Function
CREATE OR REPLACE FUNCTION trigger_whatsapp_function()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-whatsapp-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
    ),
    body := jsonb_build_object('limit', 1)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on notification_queue table
CREATE TRIGGER on_whatsapp_queued
AFTER INSERT ON notification_queue
FOR EACH ROW
WHEN (NEW.delivery_channel = 'whatsapp' AND NEW.status = 'pending')
EXECUTE FUNCTION trigger_whatsapp_function();
```

**Note**: This approach processes notifications immediately but may generate many HTTP requests if you have high notification volume.

---

### Monitor Edge Function

#### View Function Logs

**Using Supabase Dashboard** (Recommended)

1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Select your project
3. Navigate to **Edge Functions**
4. Click on `send-whatsapp-notification`
5. View logs in the **Logs** tab

**Using CLI** (Optional - for advanced users)

```bash
# View real-time logs
supabase functions logs send-whatsapp-notification --follow

# View last 50 logs
supabase functions logs send-whatsapp-notification --limit 50

# Filter logs by time
supabase functions logs send-whatsapp-notification --since "2025-01-23 10:00:00"
```

#### Common Log Messages

```
✅ = Success
❌ = Error
📧 = Processing
ℹ️ = Information

Examples:
✅ Sent to +254712345678: deeds_submitted
❌ Failed for +254712345678: Invalid template name
📬 Notification queuing complete
ℹ️ No pending WhatsApp notifications to process
```

---

### Update Edge Function

When you make changes to the function code:

#### Dashboard Method

1. Open the updated `index.ts` file
2. Copy all the code
3. Go to **Edge Functions** > `send-whatsapp-notification`
4. Click **"Edit"** or the code editor
5. Paste the new code
6. Click **"Deploy"**
7. Check the deployment status

#### CLI Method

```bash
# Navigate to project directory
cd d:/sabiquun_app

# Deploy updated function
supabase functions deploy send-whatsapp-notification

# Verify deployment
supabase functions list
```

The function will be updated with zero downtime.

---

### Troubleshooting

#### Function Not Found

**Error**: Function doesn't appear in Edge Functions list

**Solution**:
- **Dashboard**: Redeploy the function manually
- **CLI**: Run `supabase functions deploy send-whatsapp-notification`

#### Authentication Errors

**Error**: Invalid JWT / Unauthorized

**Solution**:
1. Go to **Settings** > **API** in Supabase Dashboard
2. Verify you're using the correct key:
   - For testing: Use **anon public** key
   - For cron job: Use **service_role** key
3. Make sure the key hasn't been rotated

#### Timeout Errors

The Edge Function has a default timeout of 60 seconds. If processing takes longer:

1. Reduce the `limit` parameter in the request
2. Process notifications in smaller batches
3. Optimize the WhatsApp API calls

#### Permission Errors

```sql
-- Grant necessary permissions
GRANT USAGE ON SCHEMA net TO postgres;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA net TO postgres;
```

#### Cron Job Not Running

```sql
-- Check cron job status
SELECT * FROM cron.job WHERE jobname = 'process-whatsapp-notifications';

-- Check for errors in job runs
SELECT * FROM cron.job_run_details
WHERE status = 'failed'
ORDER BY start_time DESC
LIMIT 10;

-- Delete and recreate if needed
SELECT cron.unschedule('process-whatsapp-notifications');
-- Then recreate using the schedule command above
```

---

### Production Checklist

Before going to production:

- [ ] Function deployed successfully
- [ ] Test connection works in System Settings
- [ ] Cron job scheduled and running
- [ ] Logs show no errors
- [ ] Test sending to a real WhatsApp number
- [ ] Monitor for first 24 hours
- [ ] Set up alerting for failed notifications
- [ ] Document the deployment in your team wiki

---

## Cron Schedule Examples

```
*/5 * * * *    # Every 5 minutes
*/10 * * * *   # Every 10 minutes
0 * * * *      # Every hour at minute 0
0 */2 * * *    # Every 2 hours
0 9 * * *      # Every day at 9:00 AM
0 9-17 * * *   # Every hour from 9 AM to 5 PM
```

Use [Crontab Guru](https://crontab.guru/) to create custom schedules.

---

## Function URLs

- Development: `https://your-project-ref.supabase.co/functions/v1/send-whatsapp-notification`
- You can also call it internally from database using `net.http_post`

---

## Additional Resources

- [Supabase Edge Functions Documentation](https://supabase.com/docs/guides/functions)
- [Deno Documentation](https://deno.land/manual)
- [pg_cron Documentation](https://github.com/citusdata/pg_cron)
- [Meta WhatsApp Business API](https://developers.facebook.com/docs/whatsapp/cloud-api)

---

*Last Updated: January 2025*
*Phase 70 - WhatsApp Integration*
