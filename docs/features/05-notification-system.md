# Notification System

The notification system provides multi-channel communication to keep users informed about deadlines, penalties, payments, and other important events. It supports push notifications, email, and in-app notifications.

## Notification Infrastructure

The system uses multiple channels for reliable notification delivery:

| Channel | Technology | Purpose |
|---------|-----------|---------|
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Real-time mobile alerts |
| **Email Notifications** | Mailgun (configurable) | Email alerts and summaries |
| **In-App Notifications** | Notification bell with badge | Historical notification center |

## Notification Types

### 1. Deadline Reminder

Reminds users to submit their daily deed reports before the deadline.

- **Trigger:** Scheduled by admin (e.g., 9 PM daily)
- **Recipient:** All active users who haven't submitted today's report
- **Title:** "Reminder: Submit Today's Deeds"
- **Body:** "You have until 12 PM tomorrow to submit today's report. Current progress: {progress}"
- **Action:** Opens report submission screen

### 2. Penalty Incurred

Notifies users when a penalty has been applied to their account.

- **Trigger:** Automatic at 12 PM when penalty calculated
- **Recipient:** User who incurred penalty
- **Title:** "Penalty Applied"
- **Body:** "Penalty of {amount} shillings applied for {missed_deeds} missed deeds on {date}. Current balance: {balance}"
- **Action:** Opens payment screen

### 3. Payment Submitted (to Admin/Cashier)

Alerts admins and cashiers when a new payment requires review.

- **Trigger:** User submits payment
- **Recipient:** All Admins and Cashiers
- **Title:** "New Payment Submission"
- **Body:** "{user_name} submitted payment of {amount} shillings. Pending review."
- **Action:** Opens payment review screen

### 4. Payment Approved (to User)

Confirms to the user that their payment has been approved.

- **Trigger:** Admin/Cashier approves payment
- **Recipient:** User who submitted payment
- **Title:** "Payment Approved ✅"
- **Body:** "Your payment of {amount} shillings has been approved. New balance: {balance}"
- **Action:** Opens payment history

### 5. Payment Rejected (to User)

Informs the user that their payment submission was rejected.

- **Trigger:** Admin/Cashier rejects payment
- **Recipient:** User who submitted payment
- **Title:** "Payment Rejected"
- **Body:** "Your payment of {amount} was rejected. Reason: {reason}. Please resubmit."
- **Action:** Opens payment screen

### 6. Payment Reminder

Periodic reminder for users with outstanding penalty balances.

- **Trigger:** Scheduled by admin (e.g., weekly) if balance > threshold
- **Recipient:** Users with high penalty balance
- **Title:** "Payment Reminder"
- **Body:** "Your penalty balance is {balance} shillings. Please clear your dues to avoid account deactivation."
- **Action:** Opens payment screen

### 7. Auto-Deactivation Warning

Critical warning when user is approaching the deactivation threshold.

- **Trigger:** Balance reaches configurable threshold (e.g., 400K, 450K)
- **Recipient:** User approaching deactivation
- **Title:** "⚠️ Account Deactivation Warning"
- **Body:** "Your balance is {balance}. Account will be deactivated at 500,000. Please pay immediately."
- **Action:** Opens payment screen

**Example Warning Thresholds:**
```
Balance: 400,000 → First warning
Balance: 450,000 → Final warning
Balance: 500,000 → Deactivation
```

### 8. Account Deactivated

Notifies user that their account has been deactivated due to high penalty balance.

- **Trigger:** Balance reaches 500K threshold
- **Recipient:** Deactivated user
- **Title:** "Account Deactivated"
- **Body:** "Your account has been deactivated due to penalty balance of {balance}. Contact admin for reactivation."
- **Action:** Opens contact/support screen

### 9. Account Reactivated

Welcomes user back after admin reactivates their account.

- **Trigger:** Admin reactivates account
- **Recipient:** Reactivated user
- **Title:** "Account Reactivated ✅"
- **Body:** "Your account has been reactivated by admin. You can now submit reports."
- **Action:** Opens home screen

### 10. New User Registration (to Admin)

Alerts admins when a new user registers and needs approval.

- **Trigger:** New user signs up
- **Recipient:** All Admins
- **Title:** "New User Registration"
- **Body:** "{user_name} ({email}) registered. Pending approval."
- **Action:** Opens user management screen

### 11. User Approved (to User)

Welcomes new user after admin approval.

- **Trigger:** Admin approves new user
- **Recipient:** Approved user
- **Title:** "Welcome! Account Approved ✅"
- **Body:** "Your account has been approved. You can now start tracking your daily deeds!"
- **Action:** Opens home screen

### 12. User Rejected (to User)

Informs user that their registration was not approved.

- **Trigger:** Admin rejects registration
- **Recipient:** Rejected user (email only)
- **Title:** "Registration Rejected"
- **Body:** "Your registration was not approved. Reason: {reason}. Contact admin for more info."
- **Action:** None (email only)

### 13. Rest Day Announcement

Announces upcoming rest days to all users.

- **Trigger:** Scheduled by admin (e.g., day before rest day)
- **Recipient:** All active users
- **Title:** "Rest Day Tomorrow"
- **Body:** "Tomorrow ({date}) is a rest day. No reports needed, no penalties."
- **Action:** None

### 14. Excuse Approved

Confirms that a user's excuse request has been approved.

- **Trigger:** Supervisor/Admin approves excuse
- **Recipient:** User who submitted excuse
- **Title:** "Excuse Approved ✅"
- **Body:** "Your excuse for {deeds} on {date} has been approved. Penalties waived."
- **Action:** Opens excuse history

### 15. Excuse Rejected

Informs user that their excuse request was rejected.

- **Trigger:** Supervisor/Admin rejects excuse
- **Recipient:** User who submitted excuse
- **Title:** "Excuse Rejected"
- **Body:** "Your excuse for {date} was rejected. Reason: {reason}. Penalties applied."
- **Action:** Opens excuse history

### 16. Manual Report Reminder (Supervisor)

Allows supervisors to send custom reminders to users.

- **Trigger:** Supervisor sends manually
- **Recipient:** Selected users or all users
- **Title:** Custom (set by Supervisor)
- **Body:** Custom (set by Supervisor)
- **Action:** Opens report submission screen

**Use Cases:**
- Special announcements
- Event reminders
- Custom motivational messages
- Targeted reminders for specific groups

### 17. Grace Period Ending Soon

Urgent reminder when the grace period is about to expire.

- **Trigger:** Scheduled (e.g., 11 AM - 1 hour before grace period ends)
- **Recipient:** Users with pending drafts or no submission for yesterday
- **Title:** "⏰ Grace Period Ending Soon"
- **Body:** "You have 1 hour left to submit yesterday's report. Submit now to avoid penalty."
- **Action:** Opens report submission screen

## Notification Configuration (Admin)

### Template Management

Admins can customize notification templates:

**Features:**
- View all notification templates
- Edit title and body text
- Use placeholders for dynamic content
- Enable/disable specific notifications
- Cannot delete system default templates

**Available Placeholders:**

| Placeholder | Description | Example |
|------------|-------------|---------|
| `{user_name}` | User's full name | "John Doe" |
| `{amount}` | Monetary amount | "30,000" |
| `{date}` | Date value | "Jan 15, 2025" |
| `{balance}` | Penalty balance | "45,000" |
| `{progress}` | Completion status | "3/5 deeds" |
| `{missed_deeds}` | List of missed deeds | "Fajr, Dhuhr" |
| `{reason}` | Rejection reason | "Payment not verified" |
| `{deeds}` | Deed names | "Fajr, Maghrib" |
| `{email}` | User email | "user@example.com" |

**Example Template:**
```
Title: Payment Approved ✅
Body: Your payment of {amount} shillings has been approved.
      New balance: {balance}. Thank you for staying current!
```

### Schedule Management

Configure when and how often notifications are sent:

**Settings:**
- Set time for scheduled notifications (deadline reminders, payment reminders)
- Set frequency (daily, weekly, monthly)
- Set conditions (e.g., payment reminder only if balance > X)
- Enable/disable schedules
- Create custom manual notification templates

**Example Schedule:**
```
┌──────────────────────────────────────────────┐
│ Notification Schedule Configuration          │
├──────────────────────────────────────────────┤
│ Deadline Reminder:                           │
│   ⚪ Enabled                                 │
│   Time: 9:00 PM                              │
│   Frequency: Daily                           │
│                                              │
│ Payment Reminder:                            │
│   ⚪ Enabled                                 │
│   Frequency: Weekly (Sundays)                │
│   Condition: Balance > 50,000                │
│                                              │
│ Grace Period Warning:                        │
│   ⚪ Enabled                                 │
│   Time: 11:00 AM                             │
│   Frequency: Daily                           │
└──────────────────────────────────────────────┘
```

### Email Configuration

Set up email notification delivery:

**Configuration Options:**
- Configure Mailgun API credentials
- Set sender email and name
- Test email sending
- Enable/disable email notifications per type
- Email template customization (HTML templates)

**Setup Process:**
1. Enter Mailgun API key
2. Enter Mailgun domain
3. Set sender email (e.g., "noreply@sabiquun.app")
4. Set sender name (e.g., "Sabiquun App")
5. Test configuration
6. Enable email notifications

**Email Template Customization:**
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    /* Custom styling */
  </style>
</head>
<body>
  <div class="container">
    <h1>{{title}}</h1>
    <p>{{body}}</p>
    <a href="{{action_url}}" class="button">
      {{action_text}}
    </a>
  </div>
</body>
</html>
```

## Notification UI (User)

### Notification Center

Users access their notifications through an in-app notification center:

**Features:**
- Bell icon with unread count badge
- List of all notifications (newest first)
- Mark as read/unread
- Delete notification
- Filter by type
- Clear all read notifications

**Interface Example:**
```
┌────────────────────────────────────────────┐
│ 🔔 Notifications (3)                       │
├────────────────────────────────────────────┤
│ ● Payment Approved ✅                      │
│   Your payment of 30,000 has been...      │
│   2 hours ago                              │
├────────────────────────────────────────────┤
│ ○ Deadline Reminder                        │
│   You have until 12 PM tomorrow to...     │
│   Yesterday at 9:00 PM                     │
├────────────────────────────────────────────┤
│ ○ Rest Day Tomorrow                        │
│   Tomorrow (Jan 20) is a rest day...      │
│   2 days ago                               │
├────────────────────────────────────────────┤
│ [Clear All Read]                           │
└────────────────────────────────────────────┘
```

### Notification Preferences

Users can customize their notification preferences:

**Settings:**

| Setting | Options | Description |
|---------|---------|-------------|
| **Push Notifications** | On/Off | Enable/disable mobile push alerts |
| **Email Notifications** | On/Off | Enable/disable email delivery |
| **Notification Sound** | Sound picker | Choose alert tone |
| **Quiet Hours** | Time range | Mute notifications during specific times |

**Quiet Hours Configuration:**
```
┌──────────────────────────────────────┐
│ Quiet Hours                          │
├──────────────────────────────────────┤
│ ⚪ Enabled                           │
│                                      │
│ From: [10:00 PM ▼]                  │
│ To:   [7:00 AM ▼]                   │
│                                      │
│ During quiet hours, notifications    │
│ will be delivered silently.          │
└──────────────────────────────────────┘
```

## Notification Priority Levels

Notifications are categorized by priority to ensure important alerts are not missed:

| Priority | Examples | Behavior |
|----------|----------|----------|
| **Critical** | Account Deactivated, Deactivation Warning | Override quiet hours, persistent alert |
| **High** | Penalty Incurred, Grace Period Ending | Standard notification, high importance badge |
| **Medium** | Deadline Reminder, Payment Submitted | Standard notification |
| **Low** | Rest Day Announcement | Can be grouped, respects quiet hours |

## Notification Delivery Flow

```
┌──────────────┐
│   Event      │
│  Triggered   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Check      │
│   User       │
│  Preferences │
└──────┬───────┘
       │
       ├────────────┬─────────────┬──────────────┐
       ▼            ▼             ▼              ▼
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│   Push   │  │  Email   │  │  In-App  │  │ SMS (fut)│
│   (FCM)  │  │(Mailgun) │  │   (DB)   │  │          │
└──────────┘  └──────────┘  └──────────┘  └──────────┘
```

## Database Schema Reference

```sql
-- Notifications table
notifications
  - id
  - user_id (FK → users)
  - type (enum: deadline_reminder, penalty_incurred, etc.)
  - title (string)
  - body (text)
  - data (json) -- Additional payload for actions
  - priority (enum: low, medium, high, critical)
  - is_read (boolean)
  - read_at (timestamp, nullable)
  - created_at
  - updated_at

-- Notification templates table
notification_templates
  - id
  - type (enum: deadline_reminder, penalty_incurred, etc.)
  - title_template (string)
  - body_template (text)
  - is_enabled (boolean)
  - created_at
  - updated_at

-- Notification schedules table
notification_schedules
  - id
  - notification_type (enum)
  - schedule_type (enum: time_based, condition_based)
  - time (time, nullable)
  - frequency (enum: daily, weekly, monthly, nullable)
  - condition (json, nullable)
  - is_enabled (boolean)
  - created_at
  - updated_at

-- User notification preferences table
user_notification_preferences
  - id
  - user_id (FK → users)
  - push_enabled (boolean)
  - email_enabled (boolean)
  - sound (string)
  - quiet_hours_enabled (boolean)
  - quiet_hours_start (time, nullable)
  - quiet_hours_end (time, nullable)
  - created_at
  - updated_at
```

## API Endpoints Reference

```
GET    /api/notifications              - Get user's notifications
POST   /api/notifications/:id/read     - Mark notification as read
DELETE /api/notifications/:id          - Delete notification
POST   /api/notifications/read-all     - Mark all as read
DELETE /api/notifications/clear-read   - Clear all read notifications

GET    /api/notifications/preferences  - Get user preferences
PUT    /api/notifications/preferences  - Update user preferences

# Admin endpoints
GET    /api/admin/notification-templates     - Get all templates
PUT    /api/admin/notification-templates/:id - Update template
GET    /api/admin/notification-schedules     - Get all schedules
PUT    /api/admin/notification-schedules/:id - Update schedule
POST   /api/admin/notifications/send-manual  - Send manual notification
```

## Best Practices

### For Users
- **Enable notifications** - Stay informed about important events
- **Set quiet hours** - Prevent late-night disruptions
- **Check notification center daily** - Don't miss important updates
- **Provide valid email** - Ensure email notifications can reach you

### For Admins
- **Test templates** - Verify placeholders work correctly
- **Use appropriate priority** - Don't overuse critical priority
- **Schedule wisely** - Consider user time zones and habits
- **Monitor delivery rates** - Ensure notifications are being received
- **Personalize messages** - Use placeholders to make notifications relevant

## Integration with Other Systems

The notification system integrates with all major features:

- **Penalty System** - Penalty incurred notifications
- **Payment System** - Payment status updates
- **Excuse System** - Excuse approval/rejection
- **User Management** - Registration and account status
- **Deed System** - Deadline reminders and progress updates

---

[← Back: Payment System](04-payment-system.md) | [Main README](../../README.md)
