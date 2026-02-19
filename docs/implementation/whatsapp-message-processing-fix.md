# WhatsApp Message Processing Fix

**Date**: February 10, 2026
**Issue**: Messages stuck in "Pending" status, not being sent
**Root Cause**: Missing edge function trigger after queuing messages

---

## Problem Summary

### Symptoms
1. Messages queued successfully but status remains "Pending"
2. No WhatsApp messages actually being sent
3. No visibility into WhatsApp API errors
4. No way to manually retry stuck messages
5. No delivery/read status updates from WhatsApp

### Root Causes Identified

1. **Missing Edge Function Trigger**: Web admin queued messages into `whatsapp_logs` but never triggered the processing edge function
2. **Architecture Mismatch**: Two separate systems using different tables:
   - **Automated notifications**: Use `notification_queue` (processed by `send-whatsapp-notification`)
   - **Manual admin messages**: Use `whatsapp_logs` (had no processor)
3. **No Webhook Integration**: No way to receive delivery/read status updates from WhatsApp

---

## Solutions Implemented

### 1. Created `process-whatsapp-logs` Edge Function

**File**: `supabase/functions/process-whatsapp-logs/index.ts`

**Purpose**: Process pending messages from `whatsapp_logs` table (manual admin messages)

**Key Features**:
- Reads pending messages from `whatsapp_logs`
- Sends via WhatsApp Cloud API
- Updates status to `sent` or `failed`
- Captures WhatsApp message ID
- Detailed error logging

**How it works**:
```typescript
1. Fetch pending messages from whatsapp_logs (status = 'pending')
2. For each message:
   a. Format phone number (remove non-digits)
   b. Build template request with variables
   c. Call WhatsApp Cloud API
   d. Update status based on response:
      - Success: status = 'sent', save message_id
      - Failure: status = 'failed', save error details
```

**Response Format**:
```json
{
  "success": true,
  "processed": 10,
  "sent": 8,
  "failed": 2,
  "errors": ["msg_id: error details"],
  "timestamp": "2026-02-10T08:30:00Z"
}
```

### 2. Updated Web Admin to Trigger Processing

**File**: `sabiquun-web/src/app/dashboard/whatsapp/page.tsx`

**Changes**:
1. **Auto-trigger after queueing**: After successfully queuing messages, immediately call `process-whatsapp-logs` edge function
2. **Real-time feedback**: Show success/failure count with toast notifications
3. **Auto-refresh**: Reload logs to show updated status

**Code Flow**:
```typescript
handleSend():
1. Queue messages to whatsapp_logs (status = 'pending')
2. Show "Queued X message(s)" toast
3. Immediately call process-whatsapp-logs edge function
4. Show "✅ Successfully sent Y message(s)" or "❌ Z failed"
5. Reload logs to display updated status
```

### 3. Added Manual "Process Queue" Button

**File**: `sabiquun-web/src/app/dashboard/whatsapp/page.tsx`

**Location**: Delivery Logs section header

**Purpose**: Manually retry stuck messages

**Features**:
- Processes all pending messages in the queue
- Shows detailed results (processed/sent/failed counts)
- Refreshes logs and stats after processing
- Useful for:
  - Retrying failed messages
  - Processing messages if auto-trigger failed
  - Manual intervention when needed

### 4. Implemented WhatsApp Webhooks

**File**: `supabase/functions/whatsapp-webhook/index.ts`

**Purpose**: Receive real-time status updates from WhatsApp

**Supported Statuses**:
- `sent` - Message sent to WhatsApp servers
- `delivered` - Message delivered to recipient's phone
- `read` - Recipient opened the message
- `failed` - Message failed after being sent

**Webhook Flow**:
```
WhatsApp Cloud API → Webhook Endpoint → Update Database
                                        ↓
                              whatsapp_logs.status
                              whatsapp_logs.delivered_at
                              whatsapp_logs.read_at
```

**Verification**:
- GET request with `hub.verify_token`
- Responds with `hub.challenge` if token matches
- Token stored in `WHATSAPP_VERIFY_TOKEN` env variable

**Status Processing**:
- `delivered`: Sets `delivered_at` timestamp
- `read`: Sets `read_at` timestamp, ensures `delivered_at` exists
- `failed`: Sets `error_code` and `error_message`

---

## Database Schema (No Changes Required)

Existing `whatsapp_logs` table already has all required fields:

```sql
CREATE TABLE whatsapp_logs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  phone_number VARCHAR(20) NOT NULL,
  user_name TEXT,
  template_name VARCHAR(255) NOT NULL,
  template_language VARCHAR(10) NOT NULL,
  template_variables JSONB,
  status VARCHAR(20) NOT NULL,  -- pending, sent, delivered, read, failed
  whatsapp_message_id VARCHAR(255),  -- From WhatsApp API
  error_code VARCHAR(50),
  error_message TEXT,
  notification_type TEXT,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ
);
```

---

## Deployment Guide

### Step 1: Deploy Edge Functions

Deploy all three edge functions:

```bash
# Deploy process-whatsapp-logs (new)
supabase functions deploy process-whatsapp-logs

# Deploy whatsapp-webhook (new)
supabase functions deploy whatsapp-webhook

# Redeploy existing send-whatsapp-notification (if needed)
supabase functions deploy send-whatsapp-notification
```

### Step 2: Set Environment Variables

In Supabase Dashboard → Edge Functions → Secrets:

```
WHATSAPP_VERIFY_TOKEN=your_secure_random_token_here
```

### Step 3: Deploy Web Admin Changes

```bash
cd sabiquun-web
npm run build
npm run deploy  # or your deployment command
```

### Step 4: Configure WhatsApp Webhook in Meta Business Manager

1. Go to https://business.facebook.com
2. Navigate to WhatsApp → Configuration
3. Add webhook callback URL:
   ```
   https://your-project.supabase.co/functions/v1/whatsapp-webhook
   ```
4. Add verify token (same as `WHATSAPP_VERIFY_TOKEN`)
5. Subscribe to fields:
   - `messages` ✓
   - `message_status` ✓

### Step 5: Test the Flow

#### Test Manual Sending:
1. Go to Web Admin → WhatsApp
2. Select verified user(s)
3. Choose template
4. Fill variables
5. Click "Send Messages"
6. Verify:
   - Toast: "Queued X message(s)"
   - Toast: "✅ Successfully sent Y message(s)"
   - Logs show status = "sent"
   - Actually receive WhatsApp message

#### Test Manual Processing:
1. Go to Delivery Logs tab
2. Click "Process Queue" button
3. Verify pending messages get processed

#### Test Webhook:
1. Send a message
2. Check message on your phone
3. Open the message (mark as read)
4. Check web admin logs:
   - Status updates to "delivered"
   - Status updates to "read"
   - Timestamps populated

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│  Web Admin (Next.js)                                │
│  - Send Messages                                    │
│  - Manual "Process Queue" button                    │
└─────────────────┬───────────────────────────────────┘
                  │
                  ├─ 1. Queue message
                  │
┌─────────────────▼───────────────────────────────────┐
│  whatsapp_logs Table                                │
│  - Stores manual messages from web admin            │
│  - Status: pending → sent/failed → delivered → read │
└─────────────────┬───────────────────────────────────┘
                  │
                  ├─ 2. Auto-trigger OR Manual trigger
                  │
┌─────────────────▼───────────────────────────────────┐
│  Edge Function: process-whatsapp-logs               │
│  - Reads pending messages                           │
│  - Sends via WhatsApp API                           │
│  - Updates status                                   │
└─────────────────┬───────────────────────────────────┘
                  │
                  ├─ 3. Send request
                  │
┌─────────────────▼───────────────────────────────────┐
│  WhatsApp Cloud API                                 │
│  - POST /messages (send template)                   │
│  - Returns message_id if successful                 │
└─────────────────┬───────────────────────────────────┘
                  │
                  ├─ 4. Status updates (webhook)
                  │
┌─────────────────▼───────────────────────────────────┐
│  Edge Function: whatsapp-webhook                    │
│  - Receives: sent, delivered, read, failed          │
│  - Updates whatsapp_logs status                     │
└─────────────────────────────────────────────────────┘
```

---

## Separate System: Automated Notifications

**Important**: Automated notifications (deeds, penalties, payments) use a **different** system:

```
Triggers (deeds_submitted, etc.)
       ↓
queue_whatsapp_notification()
       ↓
notification_queue table
       ↓
send-whatsapp-notification edge function (cron/manual)
       ↓
WhatsApp API
```

Both systems are **independent** and work in parallel:
- **Manual system**: `whatsapp_logs` → `process-whatsapp-logs`
- **Automated system**: `notification_queue` → `send-whatsapp-notification`

---

## Troubleshooting

### Messages Still Stuck in "Pending"

**Check**:
1. Are WhatsApp credentials configured correctly in Settings?
2. Check edge function logs for errors
3. Click "Process Queue" button manually
4. Verify WhatsApp Business Phone Number is active

**Debug**:
```bash
# Check edge function logs
supabase functions logs process-whatsapp-logs

# Look for errors:
- "WhatsApp API credentials not configured"
- "WhatsApp API error: ..."
- Network errors
```

### Messages Sent but Status Not Updating to "Delivered"

**Check**:
1. Is webhook configured in Meta Business Manager?
2. Is `WHATSAPP_VERIFY_TOKEN` set correctly?
3. Is webhook subscription active?

**Verify**:
```bash
# Check webhook logs
supabase functions logs whatsapp-webhook

# Should see:
- "Webhook verified successfully"
- "Processing status update: msg_id - delivered"
```

### Webhook Verification Failing

**Error**: "Forbidden" or webhook not verified in Meta

**Fix**:
1. Ensure `WHATSAPP_VERIFY_TOKEN` matches the token in Meta
2. Webhook URL must be exactly:
   ```
   https://YOUR_PROJECT.supabase.co/functions/v1/whatsapp-webhook
   ```
3. Check edge function logs for verification attempts

---

## Testing Checklist

- [ ] Deploy `process-whatsapp-logs` edge function
- [ ] Deploy `whatsapp-webhook` edge function
- [ ] Set `WHATSAPP_VERIFY_TOKEN` environment variable
- [ ] Deploy web admin updates
- [ ] Configure webhook in Meta Business Manager
- [ ] Verify webhook (should show green checkmark in Meta)
- [ ] Send test message from web admin
- [ ] Verify message sent immediately (not stuck in pending)
- [ ] Check message status updates to "delivered"
- [ ] Open message on phone
- [ ] Check message status updates to "read"
- [ ] Test "Process Queue" button with pending messages
- [ ] Test with invalid phone number (should fail gracefully)
- [ ] Check error logging in failed messages

---

## Performance Considerations

- **Batch Size**: Processes up to 50 messages per invocation
- **Timeout**: Edge functions have 60s timeout (adjust if needed)
- **Rate Limits**: WhatsApp Cloud API allows 80 msg/sec (tier-dependent)
- **Webhook Response**: Must respond within 5 seconds (already optimized)

---

## Security

1. **Environment Variables**: Access tokens stored in Edge Function secrets (encrypted)
2. **Webhook Verification**: Token-based verification prevents unauthorized updates
3. **RLS Policies**: Database tables protected by Row Level Security
4. **Service Role Key**: Edge functions use service role for database access

---

## Future Enhancements

1. **Scheduled Processing**: Add cron job to process pending messages every 5 minutes
   ```sql
   SELECT cron.schedule('process-whatsapp-queue', '*/5 * * * *', $$
     SELECT net.http_post(
       url := 'https://your-project.supabase.co/functions/v1/process-whatsapp-logs',
       headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '"}'
     )
   $$);
   ```

2. **Retry Logic**: Automatically retry failed messages after delay
3. **Message Templates**: Cache WhatsApp templates from Meta API (already implemented separately)
4. **Analytics Dashboard**: Delivery rates, open rates, failure reasons
5. **Bulk Operations**: Send to thousands of users with queue management

---

## Files Created/Modified

### New Files Created

| File | Purpose |
|------|---------|
| `supabase/functions/process-whatsapp-logs/index.ts` | Process pending messages from whatsapp_logs |
| `supabase/functions/whatsapp-webhook/index.ts` | Receive WhatsApp status updates |
| `docs/implementation/whatsapp-message-processing-fix.md` | This documentation |

### Modified Files

| File | Changes |
|------|---------|
| `sabiquun-web/src/app/dashboard/whatsapp/page.tsx` | Added auto-trigger, manual "Process Queue" button, improved feedback |
| `supabase/migrations/20250210_fix_whatsapp_notification_type_mismatch.sql` | Fixed PostgreSQL type mismatches |

---

## Migration Notes

### From Old Behavior to New Behavior

**Before**:
```
Admin sends message → Queued (status: pending) → STUCK FOREVER ❌
```

**After**:
```
Admin sends message → Queued (status: pending) → Auto-processed → Sent ✅
                                                                      ↓
                                                        Webhook updates: delivered → read
```

**Breaking Changes**: None - fully backward compatible

**Database Changes**: None - uses existing schema

---

*Implementation Complete: February 10, 2026*
*Feature: WhatsApp Message Processing & Webhook Integration*
