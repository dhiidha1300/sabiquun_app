# Phase 3: Notification System Integration

## Overview

Phase 3 integrates the notification system with the automated penalty calculation. When penalties are created, users automatically receive notifications about:
- New penalties applied
- Current penalty balance
- Deactivation warnings (at 400K and 450K thresholds)
- Account deactivation (at 500K threshold)

---

## Step 1: Deploy Notification Queue Table

### 1.1 Execute SQL Script

1. Open Supabase Dashboard → **SQL Editor**
2. Copy entire contents of `supabase_notification_queue.sql`
3. Click **Run**
4. Wait for confirmation: "Success"

### 1.2 Verify Table Created

```sql
-- Check notification_queue table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'notification_queue';
```

**Expected:** `notification_queue | BASE TABLE`

### 1.3 Verify Indexes Created

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'notification_queue';
```

You should see 5 indexes:
- `notification_queue_pkey` (PRIMARY KEY)
- `idx_notification_queue_user_id`
- `idx_notification_queue_status`
- `idx_notification_queue_created_at`
- `idx_notification_queue_type`
- `idx_notification_queue_user_status`

### 1.4 Verify Functions Created

```sql
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%notification%';
```

**Expected functions:**
- `queue_penalty_notification`
- `queue_deactivation_warning`
- `get_pending_notifications`
- `mark_notification_sent`
- `mark_notification_failed`
- `cleanup_old_notifications`

### 1.5 Verify Trigger Created

```sql
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'after_penalty_insert';
```

**Expected:**
```
after_penalty_insert | INSERT | penalties
```

---

## Step 2: Test Notification Queue

### 2.1 Create a Test Penalty (Manual)

```sql
-- Insert a test penalty to trigger notification
INSERT INTO penalties (
  user_id,
  amount,
  date_incurred,
  status,
  paid_amount
)
SELECT
  id,
  5000,
  CURRENT_DATE - INTERVAL '1 day',
  'unpaid',
  0
FROM users
WHERE account_status = 'active'
LIMIT 1;
```

### 2.2 Verify Notification Queued

```sql
-- Check notification was automatically created
SELECT
  id,
  user_id,
  type,
  title,
  body,
  status,
  created_at
FROM notification_queue
ORDER BY created_at DESC
LIMIT 1;
```

**Expected output:**
```
type: penalty_incurred
title: Penalty Applied
body: Penalty of 5000 shillings applied for missed deeds. Current balance: XXXX shillings.
status: pending
```

### 2.3 Test Get Pending Notifications

```sql
-- Get pending notifications ready to be sent
SELECT * FROM get_pending_notifications(10);
```

You should see the test notification with user details.

---

## Step 3: Edge Function Integration

The Edge Function (`calculate-penalties`) already includes notification integration code. It will:

1. ✅ Automatically queue notifications via trigger (when penalties created)
2. ✅ Check for deactivation warnings (400K, 450K, 500K thresholds)
3. ✅ Auto-deactivate users at 500K threshold

**No additional code changes needed!** The Edge Function is already integrated.

---

## Step 4: Create Notification Processor (Optional)

For actually **sending** the notifications via FCM/email, you have two options:

### Option A: Process in Same Edge Function (Simpler)

The existing Edge Function already queues notifications. To actually send them, we need FCM credentials.

**Skip this for now** - notifications are queued and ready. You can implement FCM sending later.

### Option B: Separate Notification Processor (Recommended)

Create a separate Edge Function that processes the queue periodically.

**Create:** `supabase/functions/process-notifications/index.ts`

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    console.log('Processing notification queue...')

    // Get pending notifications
    const { data: notifications, error } = await supabase
      .rpc('get_pending_notifications', { p_limit: 100 })

    if (error) throw error

    if (!notifications || notifications.length === 0) {
      console.log('No pending notifications')
      return new Response(
        JSON.stringify({ success: true, processed: 0 }),
        { headers: corsHeaders, status: 200 }
      )
    }

    console.log(`Found ${notifications.length} pending notifications`)

    let sentCount = 0
    let failedCount = 0

    // Process each notification
    for (const notification of notifications) {
      try {
        // Send FCM notification if token exists
        if (notification.fcm_token && fcmServerKey) {
          const fcmResponse = await fetch(
            'https://fcm.googleapis.com/fcm/send',
            {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `key=${fcmServerKey}`
              },
              body: JSON.stringify({
                to: notification.fcm_token,
                notification: {
                  title: notification.title,
                  body: notification.body,
                  sound: 'default'
                },
                data: notification.data,
                priority: 'high'
              })
            }
          )

          const fcmResult = await fcmResponse.json()

          if (fcmResult.success === 1) {
            // Mark as sent
            await supabase.rpc('mark_notification_sent', {
              p_notification_id: notification.id,
              p_fcm_message_id: fcmResult.results[0].message_id
            })
            sentCount++
            console.log(`✅ Sent to ${notification.user_name}`)
          } else {
            throw new Error(fcmResult.results[0].error || 'FCM send failed')
          }
        } else {
          // No FCM token - mark as failed
          await supabase.rpc('mark_notification_failed', {
            p_notification_id: notification.id,
            p_error_message: 'No FCM token available'
          })
          failedCount++
        }

      } catch (error) {
        // Mark as failed
        await supabase.rpc('mark_notification_failed', {
          p_notification_id: notification.id,
          p_error_message: error.message
        })
        failedCount++
        console.error(`❌ Failed for ${notification.user_name}: ${error.message}`)
      }
    }

    console.log(`Processing complete: ${sentCount} sent, ${failedCount} failed`)

    return new Response(
      JSON.stringify({
        success: true,
        processed: notifications.length,
        sent: sentCount,
        failed: failedCount
      }),
      {
        headers: corsHeaders,
        status: 200
      }
    )

  } catch (error) {
    console.error('Error processing notifications:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: corsHeaders, status: 500 }
    )
  }
})
```

**Deploy:**
```bash
supabase functions deploy process-notifications
```

**Setup Cron:**
- Schedule: `*/15 * * * *` (every 15 minutes)
- This will process any pending notifications every 15 minutes

---

## Step 5: Verify Integration End-to-End

### 5.1 Run Penalty Calculation Manually

```bash
supabase functions invoke calculate-penalties
```

### 5.2 Check Notifications Queued

```sql
-- View notifications created in last hour
SELECT
  nq.type,
  u.name as user_name,
  nq.title,
  nq.body,
  nq.status,
  nq.created_at
FROM notification_queue nq
JOIN users u ON nq.user_id = u.id
WHERE nq.created_at > CURRENT_TIMESTAMP - INTERVAL '1 hour'
ORDER BY nq.created_at DESC;
```

### 5.3 Check Deactivation Warnings

```sql
-- View warning notifications
SELECT
  u.name,
  nq.type,
  nq.body,
  nq.data->>'balance' as balance,
  nq.created_at
FROM notification_queue nq
JOIN users u ON nq.user_id = u.id
WHERE nq.type LIKE '%warning%'
  OR nq.type = 'account_deactivated'
ORDER BY nq.created_at DESC;
```

---

## Step 6: Configure FCM (For Actual Sending)

To actually send push notifications, you need Firebase Cloud Messaging credentials.

### 6.1 Get FCM Server Key

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your Sabiquun project
3. Go to **Project Settings** → **Cloud Messaging**
4. Copy **Server Key**

### 6.2 Add to Supabase Environment

1. Supabase Dashboard → **Edge Functions**
2. Select `process-notifications` (if created)
3. **Settings** → **Environment Variables**
4. Add:
   - Key: `FCM_SERVER_KEY`
   - Value: [Your Firebase Server Key]

---

## Step 7: Test Complete Flow

### 7.1 Create Test Scenario

```sql
-- 1. Ensure test user exists
INSERT INTO users (id, name, email, membership_status, account_status, created_at, fcm_token)
VALUES (
  gen_random_uuid(),
  'Test User',
  'test@example.com',
  'exclusive',
  'active',
  CURRENT_TIMESTAMP - INTERVAL '60 days',
  'test-fcm-token-123'
) ON CONFLICT DO NOTHING;

-- 2. Create incomplete report
INSERT INTO deeds_reports (user_id, report_date, total_deeds, status)
SELECT id, CURRENT_DATE - INTERVAL '1 day', 7.5, 'submitted'
FROM users WHERE email = 'test@example.com';
```

### 7.2 Run Penalty Calculation

```bash
supabase functions invoke calculate-penalties
```

### 7.3 Verify Results

```sql
-- Check penalty created
SELECT * FROM penalties
WHERE date_incurred = CURRENT_DATE - INTERVAL '1 day'
ORDER BY created_at DESC
LIMIT 1;

-- Check notification queued
SELECT * FROM notification_queue
ORDER BY created_at DESC
LIMIT 1;

-- Check execution log
SELECT * FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 1;
```

---

## ✅ Phase 3 Complete!

Checklist:
- ✅ notification_queue table created
- ✅ Helper functions deployed
- ✅ Trigger on penalties table active
- ✅ Edge Function queues notifications
- ✅ Deactivation warnings implemented
- ✅ Auto-deactivation at 500K working
- ✅ FCM integration ready (optional)

**Next:** Phase 4 - Monitoring & Admin Dashboard

---

## Notification Types Reference

The system now automatically queues these notifications:

| Type | Trigger | When |
|------|---------|------|
| `penalty_incurred` | New penalty created | After daily calculation |
| `deactivation_warning` | Balance ≥ 400K | During calculation check |
| `deactivation_warning_final` | Balance ≥ 450K | During calculation check |
| `account_deactivated` | Balance ≥ 500K | During calculation check |

---

## Troubleshooting

### Notifications not queued
**Check trigger exists:**
```sql
SELECT * FROM information_schema.triggers
WHERE trigger_name = 'after_penalty_insert';
```

### Trigger not firing
**Test manually:**
```sql
-- Insert test penalty
INSERT INTO penalties (user_id, amount, date_incurred, status, paid_amount)
SELECT id, 1000, CURRENT_DATE, 'unpaid', 0
FROM users LIMIT 1;

-- Check if notification appeared
SELECT * FROM notification_queue ORDER BY created_at DESC LIMIT 1;
```

### Can't send FCM notifications
- Verify FCM_SERVER_KEY environment variable set
- Check FCM token is valid in users table
- Deploy process-notifications Edge Function
- Check function logs for errors

---

## Optional: Cleanup Old Notifications

Run periodically (e.g., monthly) to clean up old sent notifications:

```sql
SELECT cleanup_old_notifications();
```

Or create a cron Edge Function to run this automatically monthly.
