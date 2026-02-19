# WhatsApp Web Admin Implementation

**Date**: February 3, 2026
**Phase**: 70 - WhatsApp Integration Enhancement

---

## Overview

This document describes the implementation of comprehensive WhatsApp notification management for the web admin panel, including removal of WhatsApp features from the Flutter app.

---

## 1. Removed WhatsApp from Flutter App

### Changes Made

**File**: `sabiquun_app/lib/features/admin/presentation/pages/manual_notification_page.dart`

- Removed delivery channel dropdown (push/whatsapp/both)
- Removed WhatsApp-specific logic from send confirmation dialog
- Simplified to push notifications only

**Reason**: WhatsApp notification sending should be managed exclusively from the web admin panel for better control and monitoring.

---

## 2. Created `whatsapp_logs` Database Table

### Migration File

**Location**: `supabase/migrations/20250203_whatsapp_logs.sql`

### Table Structure

```sql
CREATE TABLE whatsapp_logs (
  id UUID PRIMARY KEY,

  -- Recipient Information
  user_id UUID REFERENCES users(id),
  phone_number VARCHAR(20) NOT NULL,
  user_name VARCHAR(255),

  -- Message Information
  template_name VARCHAR(255) NOT NULL,
  template_language VARCHAR(10) DEFAULT 'en',
  template_variables JSONB DEFAULT '{}',
  message_content TEXT,

  -- Delivery Status
  status VARCHAR(50) CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
  whatsapp_message_id VARCHAR(255),

  -- Response from WhatsApp API
  api_response JSONB,
  error_code VARCHAR(100),
  error_message TEXT,

  -- Metadata
  notification_type VARCHAR(100),
  sent_by UUID REFERENCES users(id),
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  delivered_at TIMESTAMP WITH TIME ZONE,
  read_at TIMESTAMP WITH TIME ZONE,

  -- Tracking
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Indexes Created

1. `idx_whatsapp_logs_user_id` - Query by user
2. `idx_whatsapp_logs_phone` - Query by phone number
3. `idx_whatsapp_logs_status` - Query by status
4. `idx_whatsapp_logs_template` - Query by template
5. `idx_whatsapp_logs_sent_at` - Query by date range
6. `idx_whatsapp_logs_failed` - Failed messages only
7. `idx_whatsapp_logs_user_date` - User + date compound index

### Helper Functions

#### `get_recent_whatsapp_logs()`
```sql
SELECT * FROM get_recent_whatsapp_logs(
  limit_count := 50,
  offset_count := 0,
  filter_status := 'failed',
  filter_template := 'deed_reminder',
  search_phone := '+254'
);
```

Retrieves recent logs with optional filtering.

#### `get_whatsapp_delivery_stats()`
```sql
SELECT * FROM get_whatsapp_delivery_stats(days_back := 7);
```

Returns:
- `total_sent`: Total messages sent
- `total_delivered`: Messages delivered
- `total_read`: Messages read
- `total_failed`: Failed messages
- `delivery_rate`: Percentage delivered
- `read_rate`: Percentage read
- `failure_rate`: Percentage failed

### View Created

**`whatsapp_logs_summary`** - Daily summary statistics grouped by date, template, and status.

---

## 3. Web Admin WhatsApp Page

### Location

**File**: `sabiquun-web/src/app/dashboard/whatsapp/page.tsx`

### Features Implemented

## Tab 1: Send Messages

### User Selection
- **Search**: Filter users by name, email, or phone number
- **Filter**: Show all users, verified only, or unverified only
- **Checkboxes**: Select individual users or select all verified users
- **Verification Badge**: Visual indicator showing which users have verified WhatsApp numbers
- **Phone Display**: Shows WhatsApp phone number for each user

### Template Selection
- **Dropdown**: Lists all WhatsApp-enabled templates
- **Language Badge**: Shows template language (en, sw, ar, so)
- **Template Info**: Displays Meta template name

### Dynamic Variable Inputs
The system automatically detects required variables based on template name:

| Template Pattern | Variables |
|------------------|-----------|
| `deed_reminder` | user_name, progress, target |
| `penalty_alert` | user_name, amount, balance |
| `payment_confirmed` | user_name, amount, balance |
| `payment_rejected` | user_name, amount, reason |
| `deadline_warning` | user_name, hours_remaining |
| `account_warning` | user_name, balance, threshold |
| `account_deactivated` | user_name, reason |

**Fallback**: If template doesn't match patterns, defaults to `user_name`, `var1`, `var2`

### Send Process
1. Validates:
   - At least one recipient selected
   - Template selected
   - All variables filled
2. Queues messages to `whatsapp_logs` table with status `pending`
3. Shows success/failure count
4. Edge Function processes pending messages

---

## Tab 2: Delivery Logs

### Statistics Dashboard

Four metric cards showing last 7 days:

1. **Total Sent**: Count of all sent messages
2. **Delivery Rate**: Percentage successfully delivered (green)
3. **Read Rate**: Percentage read by recipients (blue)
4. **Failed**: Count and percentage of failures (red)

### Logs Table

**Columns**:
- Recipient (name + phone)
- Template (name + language badge)
- Status (badge with icon)
- Sent At (timestamp)
- Actions (View Details button)

**Filters**:
- Phone number search
- Status filter (all, pending, sent, delivered, read, failed)
- Refresh button

**Status Badges**:
- ⏰ Pending (gray)
- 📤 Sent (default)
- ✅ Delivered (green)
- ✅ Read (green)
- ❌ Failed (red)

### Detailed View Dialog

Clicking "View Details" opens a modal showing:

**General Info**:
- Recipient name and phone
- Status badge
- Template name and language
- WhatsApp Message ID

**Template Variables**:
- JSON formatted display of all variables sent

**Timestamps**:
- Sent At
- Delivered At
- Read At

**Error Details** (if failed):
- Error code
- Error message
- Highlighted in red box

---

## How to Use

### 1. Deploy the Migration

```bash
cd d:/sabiquun_app
psql -U postgres -d your_database -f supabase/migrations/20250203_whatsapp_logs.sql
```

Or use Supabase dashboard SQL editor to run the migration.

### 2. Access WhatsApp Page

1. Log in to web admin as an admin user
2. Navigate to **System** > **WhatsApp** in the sidebar
3. The page opens with two tabs: **Send Messages** and **Delivery Logs**

### 3. Send WhatsApp Messages

**Step 1**: Select Recipients
- Use search to find specific users
- Filter by verification status
- Check boxes next to users to select
- Or click "Select All Verified"

**Step 2**: Choose Template
- Select from dropdown of WhatsApp-enabled templates
- Only templates with `whatsapp_enabled = true` appear

**Step 3**: Fill Variables
- Input fields appear dynamically based on template
- Each variable must be filled

**Step 4**: Send
- Click "Send to X User(s)" button
- Messages are queued to `whatsapp_logs`
- Success/failure toast notifications appear
- Form resets after sending

### 4. View Logs

**Statistics**:
- View 7-day delivery metrics at the top

**Filter Logs**:
- Search by phone number
- Filter by status
- Refresh to see latest logs

**View Details**:
- Click "View Details" on any log entry
- See complete message information
- Check error details for failed messages

---

## Template Status Feature

### Template States

The system shows template status:

1. **Active** (whatsapp_enabled = true):
   - Appears in dropdown
   - Can be used for sending
   - Green indicator

2. **In Review** (whatsapp_enabled = false):
   - Does NOT appear in dropdown
   - Cannot be used
   - Orange indicator (not implemented yet in UI, but filtered out)

**Note**: Only **Active** templates appear in the Send tab dropdown.

---

## Integration with Edge Function

### Message Flow

1. **Web Admin**: Admin queues messages via Send tab
   - Inserts rows into `whatsapp_logs` with `status = 'pending'`

2. **Edge Function** (`send-whatsapp-notification`):
   - Runs every 5 minutes (cron job)
   - Fetches pending messages
   - Calls WhatsApp Cloud API
   - Updates status to `sent`, `delivered`, `read`, or `failed`

3. **Webhooks** (future):
   - WhatsApp sends delivery receipts
   - Update `delivered_at` and `read_at` timestamps
   - Update status accordingly

### Status Updates

The Edge Function should update logs like this:

```typescript
// After successful API call
await supabase
  .from('whatsapp_logs')
  .update({
    status: 'sent',
    whatsapp_message_id: response.messages[0].id,
    api_response: response,
  })
  .eq('id', logId);

// After failure
await supabase
  .from('whatsapp_logs')
  .update({
    status: 'failed',
    error_code: error.code,
    error_message: error.message,
    api_response: error.response,
  })
  .eq('id', logId);
```

---

## User Requirements

### Prerequisites

1. **WhatsApp Settings Configured**:
   - `whatsapp_enabled = true` in system settings
   - Valid Phone Number ID
   - Valid Access Token
   - API Version set

2. **Templates Created**:
   - At least one template with `whatsapp_enabled = true`
   - WhatsApp template name matches Meta-approved template
   - Template language set

3. **Users Setup**:
   - Users have WhatsApp phone numbers in `user_notification_preferences`
   - Admin has marked `whatsapp_verified = true` for users

### Permissions

**Required Role**: `admin`

Only admins can:
- Access the WhatsApp page
- Send messages
- View logs

---

## Common Error Messages

### "Please select at least one recipient"
- No users are checked
- **Fix**: Select at least one user with verified WhatsApp

### "Please select a template"
- No template chosen from dropdown
- **Fix**: Select a template

### "Please fill in the {variable} variable"
- Template variable is empty
- **Fix**: Enter value for each required variable

### "Failed to send messages"
- Database error or permission issue
- **Fix**: Check console logs and database permissions

---

## Monitoring and Troubleshooting

### Check Delivery Statistics

```sql
SELECT * FROM get_whatsapp_delivery_stats(7);
```

### Find Failed Messages

```sql
SELECT * FROM whatsapp_logs
WHERE status = 'failed'
ORDER BY sent_at DESC
LIMIT 20;
```

### Get User's Message History

```sql
SELECT * FROM whatsapp_logs
WHERE user_id = 'user-uuid-here'
ORDER BY sent_at DESC;
```

### Daily Summary

```sql
SELECT * FROM whatsapp_logs_summary
WHERE date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY date DESC;
```

---

## Future Enhancements

### Planned Features

1. **Template Status Indicator**:
   - Show "In Review" badge for templates awaiting Meta approval
   - Show "Active" badge for approved templates
   - Show "Rejected" badge for rejected templates

2. **Bulk Import**:
   - Upload CSV with phone numbers and variables
   - Send to users not in system

3. **Scheduling**:
   - Schedule messages for future delivery
   - Recurring messages (daily reminders)

4. **Webhook Integration**:
   - Real-time delivery status updates
   - Automatic `delivered_at` and `read_at` timestamps

5. **Message Templates Preview**:
   - Show actual template with variable substitution
   - Preview before sending

6. **Export Logs**:
   - CSV export of logs
   - PDF reports

---

## Files Modified/Created

### Created Files

| File | Purpose |
|------|---------|
| `supabase/migrations/20250203_whatsapp_logs.sql` | WhatsApp logs table and functions |
| `sabiquun-web/src/app/dashboard/whatsapp/page.tsx` | WhatsApp notification page with Send and Logs tabs |

### Modified Files

| File | Changes |
|------|---------|
| `sabiquun_app/lib/features/admin/presentation/pages/manual_notification_page.dart` | Removed WhatsApp delivery channel option |
| `sabiquun-web/src/components/dashboard/sidebar.tsx` | Added WhatsApp menu item |

---

## Testing Checklist

- [ ] Migration runs successfully
- [ ] WhatsApp menu item appears in sidebar
- [ ] Page loads without errors
- [ ] Users list displays correctly
- [ ] Search and filters work
- [ ] Template dropdown shows only enabled templates
- [ ] Variable inputs appear dynamically
- [ ] Send button queues messages successfully
- [ ] Logs tab loads statistics
- [ ] Logs table displays messages
- [ ] Status badges show correctly
- [ ] Details dialog opens and shows all information
- [ ] Failed messages show error details
- [ ] Filters work on logs tab

---

## Security Notes

1. **RLS Policies**: Only admins can view/manage WhatsApp logs
2. **Phone Numbers**: Stored securely in `user_notification_preferences`
3. **Access Token**: Never exposed to client, stored in database settings
4. **Rate Limiting**: Edge Function should implement rate limiting
5. **Audit Trail**: All sends logged with `sent_by` user ID

---

*Implementation Complete: February 3, 2026*
*Phase 70 - WhatsApp Web Admin Enhancement*
