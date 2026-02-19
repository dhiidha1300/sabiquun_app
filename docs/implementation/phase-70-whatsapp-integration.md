# Phase 70: WhatsApp Business Cloud API Integration

## Implementation Guide

This document provides step-by-step instructions for deploying and configuring the WhatsApp Business Cloud API integration for the Sabiquun App.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Database Migration](#database-migration)
3. [Meta Business Setup](#meta-business-setup)
4. [WhatsApp Template Creation](#whatsapp-template-creation)
5. [App Configuration](#app-configuration)
6. [Edge Function Deployment](#edge-function-deployment)
7. [User Verification Workflow](#user-verification-workflow)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- [ ] Meta Business Account
- [ ] WhatsApp Business Account (WABA)
- [ ] Phone number registered with WhatsApp Business
- [ ] Access to Meta Business Suite
- [ ] Supabase project with Edge Functions enabled
- [ ] Admin access to the Sabiquun App

---

## Database Migration

### Step 1: Run the Migration

Execute the migration file in your Supabase SQL editor:

```bash
# File: supabase/migrations/20250122_whatsapp_integration.sql
```

Or run via Supabase CLI:
```bash
supabase db push
```

### Step 2: Verify Migration

Check that the following were created:

1. **Settings entries** (5 new WhatsApp settings):
```sql
SELECT * FROM settings WHERE setting_key LIKE 'whatsapp%';
```

2. **notification_templates columns**:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'notification_templates'
AND column_name LIKE 'whatsapp%';
```

3. **user_notification_preferences table** with WhatsApp columns:
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'user_notification_preferences';
```

4. **whatsapp_template_mapping table**:
```sql
SELECT * FROM whatsapp_template_mapping;
```

5. **Database functions**:
```sql
SELECT proname FROM pg_proc WHERE proname LIKE '%whatsapp%';
```

---

## Meta Business Setup

### Step 1: Create WhatsApp Business Account

1. Go to [Meta Business Suite](https://business.facebook.com/)
2. Navigate to **All Tools** > **WhatsApp Manager**
3. Click **Get Started** if you don't have a WABA
4. Follow the setup wizard to create your business account

### Step 2: Add Phone Number

1. In WhatsApp Manager, go to **Phone Numbers**
2. Click **Add Phone Number**
3. Verify your phone number via SMS or Voice Call
4. Complete the business verification if required

### Step 3: Get API Credentials

1. **Phone Number ID**:
   - Go to WhatsApp Manager > Phone Numbers
   - Click on your phone number
   - Copy the **Phone Number ID** from the panel

2. **Business Account ID (WABA ID)**:
   - Go to WhatsApp Manager > Account
   - Find the **WhatsApp Business Account ID**

3. **Create System User & Access Token**:
   - Go to Business Settings > Users > System Users
   - Click **Add** to create a new system user
   - Name it (e.g., "Sabiquun WhatsApp Bot")
   - Assign **Admin** role
   - Click **Generate New Token**
   - Select permissions:
     - `whatsapp_business_messaging`
     - `whatsapp_business_management`
   - Set token expiration to **Never** for permanent token
   - Copy and securely store the access token

---

## WhatsApp Template Creation

### Step 1: Create Templates in Meta Business Suite

Templates must be pre-approved by Meta. Go to WhatsApp Manager > Message Templates.

### Required Templates

Create the following templates:

#### 1. deed_reminder
```
Template Name: deed_reminder
Category: UTILITY
Language: English (en)

Header: None
Body: Hello {{1}}, this is a reminder to submit your daily deeds. Current progress: {{2}}. Submit before the deadline to avoid penalties.
Footer: Sabiquun App
Buttons: None
```

#### 2. penalty_alert
```
Template Name: penalty_alert
Category: UTILITY
Language: English (en)

Body: Hello {{1}}, a penalty of {{2}} shillings has been applied to your account. Your current balance is {{3}} shillings. Please make a payment to clear your dues.
```

#### 3. payment_confirmed
```
Template Name: payment_confirmed
Category: UTILITY
Language: English (en)

Body: Hello {{1}}, your payment of {{2}} shillings has been approved. Your new balance is {{3}} shillings. Thank you!
```

#### 4. payment_rejected
```
Template Name: payment_rejected
Category: UTILITY
Language: English (en)

Body: Hello {{1}}, your payment of {{2}} shillings was rejected. Reason: {{3}}. Please resubmit with correct details.
```

#### 5. deeds_confirmation
```
Template Name: deeds_confirmation
Category: UTILITY
Language: English (en)

Body: Hello {{1}}, your deeds report for {{3}} has been submitted successfully. Total deeds: {{2}}.
```

#### 6. account_warning
```
Template Name: account_warning
Category: UTILITY
Language: English (en)

Body: WARNING: Hello {{1}}, your penalty balance is {{2}} shillings. Your account will be deactivated at 500,000 shillings. Please pay immediately.
```

#### 7. account_deactivated
```
Template Name: account_deactivated
Category: UTILITY
Language: English (en)

Body: Hello {{1}}, your account has been deactivated due to a penalty balance of {{2}} shillings. Please contact the administrator for reactivation.
```

#### 8. deadline_warning
```
Template Name: deadline_warning
Category: UTILITY
Language: English (en)

Body: URGENT: Hello {{1}}, you have {{2}} left to submit yesterday's deeds. Submit now to avoid penalties!
```

### Step 2: Wait for Approval

- Templates typically take 24-48 hours for review
- Check status in WhatsApp Manager > Message Templates
- Approved templates show a green checkmark

### Step 3: Update Template Mapping

After templates are approved, update the mapping if template names differ:

```sql
UPDATE whatsapp_template_mapping
SET whatsapp_template_name = 'your_actual_template_name'
WHERE notification_type = 'deadline_reminder';
```

---

## App Configuration

### Step 1: Configure WhatsApp Settings (Admin)

1. Log in as Admin
2. Navigate to **System Settings** > **WhatsApp** tab
3. Enable WhatsApp Notifications toggle
4. Enter credentials:
   - **Phone Number ID**: From Meta Business Suite
   - **Business Account ID**: Your WABA ID
   - **Access Token**: The permanent token you generated
   - **API Version**: v18.0 (or latest stable)
5. Click **Save WhatsApp Settings**

### Step 2: Test Connection (Optional)

Click "Test Connection" to verify API credentials are valid.

---

## Edge Function Deployment

### Step 1: Deploy the Edge Function

```bash
cd sabiquun_app
supabase functions deploy send-whatsapp-notification
```

### Step 2: Set Environment Variables

Ensure your Supabase project has the following secrets:
- `SUPABASE_URL` (automatically set)
- `SUPABASE_SERVICE_ROLE_KEY` (automatically set)

### Step 3: Create a Scheduled Invocation (Optional)

To process WhatsApp queue automatically, create a cron job in Supabase:

```sql
-- Run every 5 minutes
SELECT cron.schedule(
  'process-whatsapp-notifications',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/send-whatsapp-notification',
    headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
```

Or trigger manually via API call when notifications are queued.

---

## User Verification Workflow

### Admin Verification Process

1. **User requests WhatsApp notifications** (contacts admin)
2. **Admin verifies phone number**:
   - Go to User Management
   - Find the user
   - Enter their WhatsApp phone number (international format: +254712345678)
   - Toggle "WhatsApp Verified" to ON
   - Save changes

3. **User receives confirmation**:
   - User's Notification Settings will show "Verified" status
   - User can now toggle WhatsApp notifications ON/OFF

### Database Update (Alternative)

Admin can also update directly in database:

```sql
UPDATE user_notification_preferences
SET
  whatsapp_phone = '+254712345678',
  whatsapp_verified = true,
  updated_at = NOW()
WHERE user_id = 'user-uuid-here';
```

---

## Testing

### Step 1: Test Template Message

Send a test message using the Edge Function:

```bash
curl -X POST 'https://your-project.supabase.co/functions/v1/send-whatsapp-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"limit": 1}'
```

### Step 2: Queue a Test Notification

```sql
SELECT queue_whatsapp_notification(
  'user-uuid-here',
  'deeds_submitted',
  '{"user_name": "Test User", "total_deeds": "5", "date": "Jan 23, 2025"}'::jsonb
);
```

### Step 3: Verify Delivery

Check the notification_queue table:

```sql
SELECT * FROM notification_queue
WHERE delivery_channel = 'whatsapp'
ORDER BY created_at DESC
LIMIT 10;
```

---

## Troubleshooting

### Common Issues

#### 1. "Template not found" error
- Verify template name matches exactly (case-sensitive)
- Check template is approved in Meta Business Suite
- Update whatsapp_template_mapping if needed

#### 2. "Invalid phone number" error
- Ensure phone is in international format without + (e.g., 254712345678)
- Verify the recipient has WhatsApp installed
- Check the number is not blocked

#### 3. "Authentication failed" error
- Verify access token is correct and not expired
- Check System User has correct permissions
- Regenerate token if needed

#### 4. "Rate limit exceeded" error
- WhatsApp has a limit of ~80 messages/second
- Implement batching with delays
- Check your tier limits in Meta Business Suite

#### 5. Messages not sending
- Check Edge Function logs in Supabase Dashboard
- Verify WhatsApp is enabled in settings
- Ensure user has whatsapp_verified = true

### Debugging Queries

```sql
-- Check pending notifications
SELECT * FROM notification_queue
WHERE delivery_channel = 'whatsapp' AND status = 'pending';

-- Check failed notifications
SELECT * FROM notification_queue
WHERE delivery_channel = 'whatsapp' AND status = 'failed';

-- Check WhatsApp settings
SELECT * FROM settings WHERE setting_key LIKE 'whatsapp%';

-- Check user's WhatsApp status
SELECT u.name, unp.whatsapp_phone, unp.whatsapp_enabled, unp.whatsapp_verified
FROM users u
LEFT JOIN user_notification_preferences unp ON u.id = unp.user_id
WHERE u.account_status = 'active';
```

---

## File Reference

### New Files Created

| File | Purpose |
|------|---------|
| `supabase/migrations/20250122_whatsapp_integration.sql` | Database schema changes |
| `supabase/functions/send-whatsapp-notification/index.ts` | Edge Function for sending messages |
| `lib/features/admin/presentation/widgets/whatsapp_settings_tab.dart` | Admin UI for configuration |
| `lib/features/settings/domain/entities/user_notification_preferences_entity.dart` | User preferences entity |
| `lib/features/settings/data/models/user_notification_preferences_model.dart` | User preferences model |
| `lib/features/settings/domain/repositories/user_notification_preferences_repository.dart` | Repository interface |
| `lib/features/settings/data/repositories/user_notification_preferences_repository_impl.dart` | Repository implementation |
| `lib/features/settings/data/datasources/user_notification_preferences_remote_datasource.dart` | Remote data source |

### Modified Files

| File | Changes |
|------|---------|
| `lib/features/admin/domain/entities/system_settings_entity.dart` | Added WhatsApp fields |
| `lib/features/admin/data/models/system_settings_model.dart` | Added WhatsApp JSON mappings |
| `lib/features/admin/presentation/pages/system_settings_page.dart` | Added WhatsApp tab |
| `lib/features/settings/pages/notification_settings_page.dart` | Added WhatsApp section |
| `lib/features/admin/domain/entities/notification_template_entity.dart` | Added WhatsApp fields |
| `lib/features/admin/data/models/notification_template_model.dart` | Added WhatsApp JSON mappings |
| `lib/features/admin/domain/repositories/admin_repository.dart` | Updated method signatures |
| `lib/features/admin/data/repositories/admin_repository_impl.dart` | Updated implementation |
| `lib/features/admin/data/datasources/admin_remote_datasource.dart` | Updated data source methods |
| `docs/features/05-notification-system.md` | Added WhatsApp documentation |

---

## Security Considerations

1. **Access Token Storage**: The access token is stored in the settings table. Consider using Supabase Vault for additional security.

2. **Phone Verification**: Only admins can verify phone numbers to prevent abuse.

3. **Rate Limiting**: Implement rate limiting on the Edge Function to prevent abuse.

4. **Audit Trail**: All settings changes are logged with `updated_by` field.

5. **RLS Policies**: User notification preferences are protected by Row Level Security.

---

## Next Steps

After successful implementation:

1. [ ] Train admins on user verification process
2. [ ] Monitor Edge Function logs for errors
3. [ ] Set up alerting for failed notifications
4. [ ] Consider implementing read receipts via webhooks
5. [ ] Add support for additional languages if needed

---

*Last Updated: January 2025*
*Phase 70 - WhatsApp Business Cloud API Integration*
