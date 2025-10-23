# Admin Screens

This document outlines all screens and interfaces available to administrators. Admins have access to all user, supervisor, and cashier features plus complete system management capabilities.

---

## Overview

Administrators inherit all features from:
- [Normal User Screens](./02-user-screens.md)
- [Supervisor Screens](./03-supervisor-screens.md)
- [Cashier Screens](./04-cashier-screens.md)

Plus exclusive access to:
- User Management Dashboard
- Deed Template Management
- System Settings
- Notification Template Management
- Rest Days Management
- Penalty Management
- Report Management
- Enhanced Analytics Dashboard
- Audit Log Viewer
- Content Management

---

## User Management Dashboard

Comprehensive user management with approval, editing, and role assignment capabilities.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  User Management               │
│                                     │
│  [Pending (5)] [Active (150)]       │
│  [Suspended (3)] [Deactivated (2)]  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🔍 [Search users...]               │
│  [Filters ▼]        [Export 📥]     │
│                                     │
└─────────────────────────────────────┘
```

### Pending Approval Tab

```
┌─────────────────────────────────────┐
│  PENDING APPROVAL (5)               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Ahmad Mohamed          │   │
│  │                             │   │
│  │ Email: ahmad@example.com    │   │
│  │ Phone: +252 61 123 4567     │   │
│  │ Registered: Oct 20, 2025    │   │
│  │                             │   │
│  │ [View Details]              │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Fatima Ali             │   │
│  │                             │   │
│  │ Email: fatima@example.com   │   │
│  │ Phone: +252 61 987 6543     │   │
│  │ Registered: Oct 21, 2025    │   │
│  │                             │   │
│  │ [View Details]              │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Bulk Approve Selected (2)]        │
│                                     │
└─────────────────────────────────────┘
```

### Active Users Tab

```
┌─────────────────────────────────────┐
│  ACTIVE USERS (150)                 │
│                                     │
│  🔍 [Search...]  [A-Z ▼]            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Ahmad Mohamed          │   │
│  │      💎 Exclusive           │   │
│  │                             │   │
│  │ Balance: 150,000            │   │
│  │ Last Report: 2 hours ago    │   │
│  │ Compliance: 85%             │   │
│  │                             │   │
│  │ [⋮ Actions]                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Fatima Ali             │   │
│  │      🌱 New Member          │   │
│  │                             │   │
│  │ Balance: 0                  │   │
│  │ Last Report: 1 hour ago     │   │
│  │ Compliance: 92%             │   │
│  │                             │   │
│  │ [⋮ Actions]                 │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### User Actions Menu

```
┌─────────────────────────────────────┐
│  Ahmad Mohamed - Actions            │
├─────────────────────────────────────┤
│                                     │
│  📊 View Full Profile               │
│  📋 View Reports                    │
│  💰 View Payment History            │
│  ✏️  Edit User                      │
│  🔄 Change Role                     │
│  ⭐ Upgrade Membership              │
│  ⏸️  Suspend User                   │
│  🗑️  Delete User                    │
│                                     │
└─────────────────────────────────────┘
```

### User Profile Edit Screen

```
┌─────────────────────────────────────┐
│  [←]  Edit User - Ahmad Mohamed     │
├─────────────────────────────────────┤
│                                     │
│  BASIC INFORMATION                  │
│                                     │
│  Profile Photo                      │
│  [Photo Upload]                     │
│                                     │
│  Full Name                          │
│  ┌───────────────────────────────┐  │
│  │ Ahmad Mohamed                 │  │
│  └───────────────────────────────┘  │
│                                     │
│  Email                              │
│  ┌───────────────────────────────┐  │
│  │ ahmad@example.com             │  │
│  └───────────────────────────────┘  │
│                                     │
│  Phone                              │
│  ┌───────────────────────────────┐  │
│  │ +252 61 123 4567              │  │
│  └───────────────────────────────┘  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ROLE & STATUS                      │
│                                     │
│  Role                               │
│  [User ▼]                           │
│  • User                             │
│  • Supervisor                       │
│  • Cashier                          │
│  • Admin                            │
│                                     │
│  Membership Status                  │
│  [Exclusive ▼]                      │
│  • New                              │
│  • Exclusive                        │
│  • Legacy                           │
│                                     │
│  Account Status                     │
│  ● Active                           │
│  ○ Suspended                        │
│  ○ Pending                          │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  STATISTICS (View Only)             │
│                                     │
│  Member Since: Jan 15, 2025         │
│  Total Reports: 287                 │
│  Compliance Rate: 85%               │
│  Current Balance: 150,000           │
│  Training Ends: Feb 14, 2025        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [View Audit Log]                   │
│                                     │
│  [Cancel] [Save Changes]            │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Pending Approval Tab
- **User Cards**: New registrations awaiting approval
  - Profile photo
  - Name, email, phone
  - Registration timestamp
  - View Details button
  - Approve/Reject buttons
- **Bulk Actions**: Select multiple for batch approval
- **Rejection Dialog**: Requires reason input

#### Active Users Tab
- **Search Bar**: Real-time filter
- **Sort Dropdown**: Name, compliance, balance, last report
- **User Cards**:
  - Profile photo
  - Name with membership badge
  - Current balance
  - Last report timestamp
  - Compliance percentage
  - Actions menu (⋮)

#### User Actions Menu
- **View Options**: Profile, reports, payments
- **Edit User**: Modify user information
- **Change Role**: Promote to supervisor/cashier/admin
- **Upgrade Membership**: Manual tier change
- **Suspend User**: Temporary deactivation
- **Delete User**: Permanent removal (requires confirmation)

#### User Profile Edit
- **Basic Information**:
  - Photo upload
  - Name, email, phone (all editable)
- **Role & Status**:
  - Role dropdown
  - Membership dropdown
  - Account status radio buttons
- **Statistics**: Read-only metrics
- **Audit Log Link**: View all changes to this user
- **Save Button**: Commit changes with confirmation

---

## Deed Template Management

Configure the deeds that users track daily.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Deed Management               │
│                                     │
│  Daily Target: 10 deeds             │
│  (5 Fara'id + 5 Sunnah)             │
│                                     │
│  [+ Add New Deed]                   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🕌 FARA'ID DEEDS (5)               │
│  Drag to reorder                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Fajr                     │   │
│  │    🕌 Fara'id | Binary      │   │
│  │    [●─→] Active             │   │
│  │    🔒 System Default        │   │
│  │                             │   │
│  │    [✏️ Edit]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Dhuhr                    │   │
│  │    🕌 Fara'id | Binary      │   │
│  │    [●─→] Active             │   │
│  │    🔒 System Default        │   │
│  │                             │   │
│  │    [✏️ Edit]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Asr                      │   │
│  │    🕌 Fara'id | Binary      │   │
│  │    [●─→] Active             │   │
│  │    🔒 System Default        │   │
│  │                             │   │
│  │    [✏️ Edit]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  📖 SUNNAH DEEDS (5)                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Night Prayer (Qiyam)     │   │
│  │    📖 Sunnah | Fractional   │   │
│  │    [●─→] Active             │   │
│  │    🔒 System Default        │   │
│  │                             │   │
│  │    [✏️ Edit]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Duha Prayer              │   │
│  │    📖 Sunnah | Fractional   │   │
│  │    [─○→] Inactive           │   │
│  │    ✏️ Custom                │   │
│  │                             │   │
│  │    [✏️ Edit] [🗑️ Delete]   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Add/Edit Deed Form

```
┌─────────────────────────────────────┐
│  [←]  Add New Deed                  │
├─────────────────────────────────────┤
│                                     │
│  Deed Name                          │
│  ┌───────────────────────────────┐  │
│  │ Tahajjud Prayer               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Deed Key (Auto-generated)          │
│  ┌───────────────────────────────┐  │
│  │ tahajjud_prayer               │  │
│  └───────────────────────────────┘  │
│  Used for internal identification   │
│                                     │
│  Category                           │
│  ● Fara'id (Required)               │
│  ○ Sunnah (Recommended)             │
│                                     │
│  Value Type                         │
│  ● Binary (Complete/Incomplete)     │
│  ○ Fractional (0.0 - 1.0)           │
│                                     │
│  Sort Order                         │
│  ┌───────────────────────────────┐  │
│  │ 6                             │  │
│  └───────────────────────────────┘  │
│  Position in user's deed list       │
│                                     │
│  Status                             │
│  [●─→] Active                       │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ⚠️ IMPACT NOTICE                   │
│                                     │
│  Adding this Fara'id deed will:     │
│  • Increase daily target to 11      │
│  • Apply to all users immediately   │
│  • Affect penalty calculations      │
│                                     │
│  Existing reports will not change.  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Cancel] [Save Deed]               │
│                                     │
└─────────────────────────────────────┘
```

### Deactivate Deed Confirmation

```
┌─────────────────────────────────────┐
│  Deactivate Deed                    │
├─────────────────────────────────────┤
│                                     │
│  Deed: Duha Prayer                  │
│  Category: Sunnah                   │
│  Current Users: 150                 │
│                                     │
│  ⚠️ WARNING                         │
│                                     │
│  Deactivating this deed will:       │
│  • Decrease daily target from 10→9  │
│  • Hide deed from new reports       │
│  • Keep existing report data intact │
│  • Affect compliance calculations   │
│                                     │
│  You can reactivate this deed later.│
│                                     │
│  Are you sure you want to continue? │
│                                     │
│  [Cancel] [Confirm Deactivate]      │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Deed List
- **Target Display**: Shows current daily target calculation
- **Add Button**: Create new deed
- **Category Sections**: Fara'id and Sunnah grouped
- **Drag Handles**: ⋮⋮ icon for reordering
- **Deed Cards**:
  - Deed name
  - Category and value type badges
  - Active/Inactive toggle
  - System default lock icon (cannot delete)
  - Edit button
  - Delete button (custom deeds only)

#### Add/Edit Form
- **Deed Name**: Text input
- **Deed Key**: Auto-generated slug, editable
- **Category Radio**: Fara'id or Sunnah
- **Value Type Radio**: Binary or Fractional
- **Sort Order**: Numeric input
- **Active Toggle**: Enable/disable deed
- **Impact Notice**: Warning about system-wide effects
- **Save Button**: Commit changes

#### Confirmation Dialogs
- **Add Deed**: Show impact on target
- **Deactivate**: Warn about target decrease
- **Delete**: Confirm permanent removal (custom only)

---

## System Settings

Global application configuration and parameters.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  System Settings               │
│                                     │
│  [General] [Payment] [Notifications]│
│  [App Version] [Bulk Operations]    │
│                                     │
├─────────────────────────────────────┤
```

### General Settings Tab

```
┌─────────────────────────────────────┐
│  GENERAL SETTINGS                   │
│                                     │
│  📊 DEED & PENALTY CONFIGURATION    │
│                                     │
│  Daily Deed Target (Auto)           │
│  ┌───────────────────────────────┐  │
│  │ 10 deeds                      │  │
│  └───────────────────────────────┘  │
│  Calculated from active deeds       │
│                                     │
│  Penalty Per Deed                   │
│  ┌───────────────────────────────┐  │
│  │ 5,000 shillings               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Grace Period Hours                 │
│  ┌───────────────────────────────┐  │
│  │ 12 hours                      │  │
│  └───────────────────────────────┘  │
│  After midnight deadline            │
│                                     │
│  Training Period Days               │
│  ┌───────────────────────────────┐  │
│  │ 30 days                       │  │
│  └───────────────────────────────┘  │
│  New members pay no penalties       │
│                                     │
│  Auto-Deactivation Threshold        │
│  ┌───────────────────────────────┐  │
│  │ 500,000 shillings             │  │
│  └───────────────────────────────┘  │
│  Automatic account suspension       │
│                                     │
│  Warning Thresholds (JSON)          │
│  ┌───────────────────────────────┐  │
│  │ [400000, 450000]              │  │
│  └───────────────────────────────┘  │
│  Balance levels for alerts          │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Test Configuration]               │
│  [Save Changes]                     │
│                                     │
└─────────────────────────────────────┘
```

### Payment Settings Tab

```
┌─────────────────────────────────────┐
│  PAYMENT SETTINGS                   │
│                                     │
│  💳 PAYMENT METHODS                 │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ ZAAD                     │   │
│  │    [●─→] Active             │   │
│  │    [✏️ Edit] [🗑️ Delete]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ eDahab                   │   │
│  │    [●─→] Active             │   │
│  │    [✏️ Edit] [🗑️ Delete]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ Cash                     │   │
│  │    [●─→] Active             │   │
│  │    [✏️ Edit] [🗑️ Delete]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  [+ Add Payment Method]             │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📄 RECEIPT CONFIGURATION           │
│                                     │
│  Organization Name                  │
│  ┌───────────────────────────────┐  │
│  │ Sabiquun Community            │  │
│  └───────────────────────────────┘  │
│                                     │
│  Receipt Footer Text                │
│  ┌───────────────────────────────┐  │
│  │ JazakAllah khair for your    │  │
│  │ commitment to daily deeds!    │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Preview Receipt]                  │
│  [Save Changes]                     │
│                                     │
└─────────────────────────────────────┘
```

### Notification Settings Tab

```
┌─────────────────────────────────────┐
│  NOTIFICATION SETTINGS              │
│                                     │
│  📧 EMAIL SERVICE (Mailgun)         │
│                                     │
│  API Key                            │
│  ┌───────────────────────────────┐  │
│  │ key-xxxxxxxxxxxxxxxxxxxxx     │  │
│  └───────────────────────────────┘  │
│                                     │
│  Domain                             │
│  ┌───────────────────────────────┐  │
│  │ mg.sabiquun.app               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Sender Email                       │
│  ┌───────────────────────────────┐  │
│  │ noreply@sabiquun.app          │  │
│  └───────────────────────────────┘  │
│                                     │
│  Sender Name                        │
│  ┌───────────────────────────────┐  │
│  │ Sabiquun                      │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Test Email]                       │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📱 PUSH NOTIFICATIONS (FCM)        │
│                                     │
│  Server Key                         │
│  ┌───────────────────────────────┐  │
│  │ AAAAxxxxxxxxxxxxxxxxxxxxxxxx  │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Test Push Notification]           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Save Changes]                     │
│                                     │
└─────────────────────────────────────┘
```

### App Version Control Tab

```
┌─────────────────────────────────────┐
│  APP VERSION CONTROL                │
│                                     │
│  📱 CURRENT VERSION                 │
│                                     │
│  App Version                        │
│  ┌───────────────────────────────┐  │
│  │ 1.0.2                         │  │
│  └───────────────────────────────┘  │
│                                     │
│  Minimum Required Version           │
│  ┌───────────────────────────────┐  │
│  │ 1.0.0                         │  │
│  └───────────────────────────────┘  │
│  Users below this must update       │
│                                     │
│  Force Update                       │
│  [─○→] OFF                          │
│  Block app access if outdated       │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📝 UPDATE MESSAGE                  │
│                                     │
│  Title                              │
│  ┌───────────────────────────────┐  │
│  │ Update Available              │  │
│  └───────────────────────────────┘  │
│                                     │
│  Message                            │
│  ┌───────────────────────────────┐  │
│  │ A new version with improved   │  │
│  │ features is available. Please │  │
│  │ update for the best experience│  │
│  └───────────────────────────────┘  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🎯 PLATFORM SPECIFIC               │
│                                     │
│  iOS Min Version: 1.0.0             │
│  Android Min Version: 1.0.0         │
│                                     │
│  [Save Changes]                     │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### General Settings
- **Deed Target**: Auto-calculated, display only
- **Penalty Per Deed**: Numeric input with currency
- **Grace Period**: Hours input
- **Training Period**: Days input
- **Auto-Deactivation**: Balance threshold input
- **Warning Thresholds**: JSON array input
- **Test Button**: Validate configuration
- **Save Button**: Commit all changes

#### Payment Settings
- **Payment Methods List**: Drag to reorder
  - Method name
  - Active toggle
  - Edit/Delete buttons
- **Add Method**: Create new option
- **Receipt Config**: Organization details and template
- **Preview**: Generate sample receipt

#### Notification Settings
- **Email Service**: Mailgun credentials
  - API key (hidden)
  - Domain
  - Sender email and name
  - Test button
- **Push Service**: FCM configuration
  - Server key (hidden)
  - Test button
- **Save Button**: Store credentials securely

#### App Version Control
- **Version Numbers**: Current and minimum
- **Force Update Toggle**: Enable/disable blocking
- **Update Message**: Customizable notification
- **Platform Specific**: iOS and Android minimums

---

## Notification Template Management

Configure automated notification messages.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Notification Templates        │
│                                     │
│  [Templates] [Schedules]            │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🔍 [Search templates...]           │
│  [Filter by Type ▼]                 │
│                                     │
│  📬 REPORT NOTIFICATIONS            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Report Reminder             │   │
│  │ [●─→] Active                │   │
│  │ 🔒 System Default           │   │
│  │                             │   │
│  │ "Don't forget to submit     │   │
│  │  your daily report!"        │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Grace Period Warning        │   │
│  │ [●─→] Active                │   │
│  │ 🔒 System Default           │   │
│  │                             │   │
│  │ "Only 3 hours left to       │   │
│  │  submit without penalty!"   │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  💰 PAYMENT NOTIFICATIONS           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Payment Approved            │   │
│  │ [●─→] Active                │   │
│  │ 🔒 System Default           │   │
│  │                             │   │
│  │ "Your payment of {amount}   │   │
│  │  has been approved!"        │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Edit Template Form

```
┌─────────────────────────────────────┐
│  [←]  Edit Template                 │
│       Report Reminder               │
├─────────────────────────────────────┤
│                                     │
│  Template Type                      │
│  Report Notification (System)       │
│                                     │
│  Active Status                      │
│  [●─→] ON                           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📧 EMAIL CONTENT                   │
│                                     │
│  Subject                            │
│  ┌───────────────────────────────┐  │
│  │ {user_name}, Submit Your      │  │
│  │ Daily Report                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Body                               │
│  ┌───────────────────────────────┐  │
│  │ Assalamu alaikum {user_name}, │  │
│  │                               │  │
│  │ This is a reminder to submit  │  │
│  │ your daily deed report for    │  │
│  │ {date}.                       │  │
│  │                               │  │
│  │ You have {hours_left} hours   │  │
│  │ remaining in your grace period│  │
│  │                               │  │
│  │ JazakAllah khair!             │  │
│  └───────────────────────────────┘  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📱 PUSH NOTIFICATION               │
│                                     │
│  Title                              │
│  ┌───────────────────────────────┐  │
│  │ Report Reminder               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Body                               │
│  ┌───────────────────────────────┐  │
│  │ Don't forget to submit your   │  │
│  │ daily report! {hours_left}h   │  │
│  │ remaining in grace period.    │  │
│  └───────────────────────────────┘  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💡 AVAILABLE PLACEHOLDERS          │
│                                     │
│  {user_name} - User's full name     │
│  {email} - User's email             │
│  {date} - Current date              │
│  {balance} - User's balance         │
│  {amount} - Payment/penalty amount  │
│  {deeds} - Deed count               │
│  {penalty} - Penalty amount         │
│  {hours_left} - Grace period hours  │
│                                     │
│  [Insert Placeholder ▼]             │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🔍 PREVIEW                         │
│                                     │
│  [Show Email Preview]               │
│  [Show Push Preview]                │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Cancel] [Save Template]           │
│                                     │
└─────────────────────────────────────┘
```

### Notification Schedules Tab

```
┌─────────────────────────────────────┐
│  NOTIFICATION SCHEDULES             │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Daily Report Reminder       │   │
│  │ Template: Report Reminder   │   │
│  │                             │   │
│  │ Schedule: Daily at 8:00 PM  │   │
│  │ Condition: No report today  │   │
│  │ [●─→] Active                │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Grace Period Warning        │   │
│  │ Template: Grace Warning     │   │
│  │                             │   │
│  │ Schedule: Daily at 9:00 AM  │   │
│  │ Condition: In grace period  │   │
│  │ [●─→] Active                │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Weekly Leaderboard          │   │
│  │ Template: Leaderboard       │   │
│  │                             │   │
│  │ Schedule: Sunday at 9:00 AM │   │
│  │ Condition: All active users │   │
│  │ [●─→] Active                │   │
│  │                             │   │
│  │ [✏️ Edit]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  [+ Add Schedule]                   │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Templates Tab
- **Search Bar**: Filter templates by name/type
- **Type Filter**: Group by notification category
- **Template Cards**:
  - Template name
  - Active toggle
  - System default lock (cannot delete)
  - Preview snippet
  - Edit button
- **Template Types**:
  - Report notifications
  - Payment notifications
  - Excuse notifications
  - Balance warnings
  - Admin actions
  - System announcements

#### Edit Template Form
- **Email Content**:
  - Subject line with placeholders
  - Body text area
  - Rich text formatting
- **Push Content**:
  - Title (max 60 chars)
  - Body (max 200 chars)
- **Placeholders**:
  - List of available variables
  - Insert dropdown
  - Auto-completion
- **Preview**:
  - Sample data rendering
  - Both email and push formats
- **Save Button**: Validate and commit

#### Schedules Tab
- **Schedule Cards**:
  - Schedule name
  - Associated template
  - Timing (daily/weekly/monthly)
  - Conditions for sending
  - Active toggle
  - Edit button
- **Add Schedule**: Create new automated send
- **Edit Schedule**:
  - Time picker
  - Frequency selector
  - Condition builder
  - Active toggle

---

## Rest Days Management

Configure dates when penalties are not applied.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Rest Days Management          │
│                                     │
│  [Calendar View] [List View]        │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📅 OCTOBER 2025                    │
│  [◀ Prev]            [Next ▶]       │
│                                     │
│  S   M   T   W   T   F   S          │
│            1   2   3   4   5        │
│  6   7   8   9   10  11  12         │
│  13  14  15  16  17  18  19         │
│  20  21  22  23  24  25  26         │
│  27  28  29  30  31                 │
│                                     │
│  🟢 = Rest Day                      │
│  ⚪ = Regular Day                   │
│                                     │
│  Rest Days this month: 2            │
│  • Oct 12: Eid al-Fitr              │
│  • Oct 20: Mawlid an-Nabi           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [+ Add Rest Day]                   │
│  [Bulk Import]                      │
│                                     │
└─────────────────────────────────────┘
```

### Add Rest Day Form

```
┌─────────────────────────────────────┐
│  Add Rest Day                 [✕]   │
├─────────────────────────────────────┤
│                                     │
│  Date Selection                     │
│  ● Single Date                      │
│  ○ Date Range                       │
│                                     │
│  Date                               │
│  [Oct 12, 2025 ▼]                   │
│                                     │
│  Description                        │
│  ┌───────────────────────────────┐  │
│  │ Eid al-Fitr                   │  │
│  └───────────────────────────────┘  │
│                                     │
│  Recurring Annually                 │
│  [●─→] YES                          │
│  Automatically add for future years │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Impact:                            │
│  • No penalties applied this date   │
│  • Reports still required           │
│  • Deeds marked "excused" if missed │
│                                     │
│  [Cancel] [Add Rest Day]            │
│                                     │
└─────────────────────────────────────┘
```

### List View

```
┌─────────────────────────────────────┐
│  REST DAYS - LIST VIEW              │
│                                     │
│  [Filter by Year ▼] [Export 📥]     │
│                                     │
│  ━━━━━━ 2025 ━━━━━━                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Jan 1, 2025                 │   │
│  │ New Year (Non-Islamic)      │   │
│  │ 🔄 Recurring Annually       │   │
│  │                             │   │
│  │ [✏️ Edit] [🗑️ Delete]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Apr 10-12, 2025             │   │
│  │ Eid al-Fitr (3 days)        │   │
│  │ 🔄 Recurring Annually       │   │
│  │                             │   │
│  │ [✏️ Edit] [🗑️ Delete]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Jun 16-19, 2025             │   │
│  │ Eid al-Adha (4 days)        │   │
│  │ 🔄 Recurring Annually       │   │
│  │                             │   │
│  │ [✏️ Edit] [🗑️ Delete]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━ 2026 ━━━━━━                │
│  (Showing recurring dates...)       │
│                                     │
└─────────────────────────────────────┘
```

### Bulk Import

```
┌─────────────────────────────────────┐
│  Bulk Import Rest Days        [✕]   │
├─────────────────────────────────────┤
│                                     │
│  Upload File (CSV/Excel)            │
│  ┌───────────────────────────────┐  │
│  │ [📎 Choose File]              │  │
│  │ No file selected              │  │
│  └───────────────────────────────┘  │
│                                     │
│  Required columns:                  │
│  • date (YYYY-MM-DD)                │
│  • description                      │
│  • recurring (true/false)           │
│                                     │
│  Example:                           │
│  date,description,recurring         │
│  2025-04-10,Eid al-Fitr,true        │
│  2025-06-16,Eid al-Adha,true        │
│                                     │
│  [Download Template]                │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Cancel] [Upload & Import]         │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Calendar View
- **Month Navigation**: Previous/Next buttons
- **Calendar Grid**: Visual date picker
  - Rest days highlighted in green
  - Click date to add/remove
- **Legend**: Color coding explanation
- **Monthly Summary**: Rest days this month
- **Add Button**: Create new rest day
- **Bulk Import**: Upload CSV/Excel

#### Add Form
- **Date Selection**: Single date or range
- **Date Picker**: Calendar interface
- **Description**: Text input for occasion name
- **Recurring Toggle**: Annual repetition
- **Impact Notice**: What happens on rest days
- **Save Button**: Create rest day

#### List View
- **Year Filter**: Dropdown to select year
- **Export Button**: Download as CSV
- **Rest Day Cards**:
  - Date or date range
  - Description
  - Recurring indicator
  - Edit/Delete buttons
- **Grouped by Year**: Organized display

#### Bulk Import
- **File Upload**: CSV or Excel
- **Format Requirements**: Column specifications
- **Example Data**: Template download
- **Import Button**: Process file

---

## Penalty Management

Manual penalty operations for corrections and adjustments.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Penalty Management            │
├─────────────────────────────────────┤
│                                     │
│  🔍 USER SEARCH                     │
│  ┌───────────────────────────────┐  │
│  │ Search by name or email...    │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### User Penalty Overview

```
┌─────────────────────────────────────┐
│  [←]  Ahmad Mohamed - Penalties     │
├─────────────────────────────────────┤
│                                     │
│  👤 USER INFO                       │
│  Ahmad Mohamed                      │
│  💎 Exclusive Member                │
│  Current Balance: 150,000           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💰 PENALTY HISTORY                 │
│                                     │
│  [All] [Unpaid] [Paid] [Waived]     │
│                                     │
│  UNPAID PENALTIES                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 15, 2025                │   │
│  │ Amount: 25,000 shillings    │   │
│  │ Reason: 5 missing deeds     │   │
│  │ Status: Unpaid              │   │
│  │                             │   │
│  │ [Waive] [Edit] [Remove]     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 18, 2025                │   │
│  │ Amount: 30,000 shillings    │   │
│  │ Reason: 6 missing deeds     │   │
│  │ Status: Unpaid              │   │
│  │                             │   │
│  │ [Waive] [Edit] [Remove]     │   │
│  └─────────────────────────────┘   │
│                                     │
│  PAID PENALTIES                     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 10, 2025                │   │
│  │ Amount: 25,000 shillings    │   │
│  │ Reason: 5 missing deeds     │   │
│  │ Status: ✓ Paid              │   │
│  │ Paid on: Oct 20, 2025       │   │
│  │                             │   │
│  │ [View Payment]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ⚙️ MANUAL PENALTY ACTIONS          │
│                                     │
│  [+ Add Penalty]                    │
│  [Bulk Waive Selected]              │
│                                     │
└─────────────────────────────────────┘
```

### Add Manual Penalty

```
┌─────────────────────────────────────┐
│  Add Manual Penalty           [✕]   │
├─────────────────────────────────────┤
│                                     │
│  User: Ahmad Mohamed                │
│  Current Balance: 150,000           │
│                                     │
│  Date                               │
│  [Oct 22, 2025 ▼]                   │
│                                     │
│  Amount (Shillings)                 │
│  ┌───────────────────────────────┐  │
│  │ 15,000                        │  │
│  └───────────────────────────────┘  │
│                                     │
│  Reason (Required)                  │
│  ┌───────────────────────────────┐  │
│  │ Administrative penalty for    │  │
│  │ late submission of excuse     │  │
│  │ request documentation.        │  │
│  └───────────────────────────────┘  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Impact:                            │
│  New Balance: 165,000               │
│                                     │
│  Actions:                           │
│  ☑ Add to user's balance            │
│  ☑ Send notification to user        │
│  ☑ Log in audit trail               │
│                                     │
│  [Cancel] [Add Penalty]             │
│                                     │
└─────────────────────────────────────┘
```

### Remove Penalty

```
┌─────────────────────────────────────┐
│  Remove Penalty                [✕]  │
├─────────────────────────────────────┤
│                                     │
│  Penalty Details:                   │
│  Date: Oct 15, 2025                 │
│  Amount: 25,000 shillings           │
│  Reason: 5 missing deeds            │
│                                     │
│  Reason for Removal (Required)      │
│  ┌───────────────────────────────┐  │
│  │ Penalty was applied in error  │  │
│  │ due to system glitch. User    │  │
│  │ had actually submitted report.│  │
│  └───────────────────────────────┘  │
│                                     │
│  ⚠️ WARNING                         │
│  This will:                         │
│  • Remove penalty from balance      │
│  • Reduce balance by 25,000         │
│  • Cannot be undone                 │
│  • Creates audit log entry          │
│                                     │
│  New Balance: 125,000               │
│                                     │
│  [Cancel] [Confirm Removal]         │
│                                     │
└─────────────────────────────────────┘
```

### Waive Penalty

```
┌─────────────────────────────────────┐
│  Waive Penalty                 [✕]  │
├─────────────────────────────────────┤
│                                     │
│  Penalty Details:                   │
│  Date: Oct 15, 2025                 │
│  Amount: 25,000 shillings           │
│  Reason: 5 missing deeds            │
│                                     │
│  Reason for Waiver (Required)       │
│  ┌───────────────────────────────┐  │
│  │ User was hospitalized during  │  │
│  │ this period. Waiving penalty  │  │
│  │ as compassionate exception.   │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions:                           │
│  ☑ Mark penalty as waived           │
│  ☑ Reduce balance by 25,000         │
│  ☑ Keep penalty record (historical) │
│  ☑ Send notification to user        │
│  ☑ Log in audit trail               │
│                                     │
│  New Balance: 125,000               │
│                                     │
│  [Cancel] [Confirm Waiver]          │
│                                     │
└─────────────────────────────────────┘
```

### Edit Penalty Amount

```
┌─────────────────────────────────────┐
│  Edit Penalty Amount           [✕]  │
├─────────────────────────────────────┤
│                                     │
│  Current Penalty:                   │
│  Date: Oct 15, 2025                 │
│  Current Amount: 25,000             │
│  Reason: 5 missing deeds            │
│                                     │
│  New Amount (Shillings)             │
│  ┌───────────────────────────────┐  │
│  │ 15,000                        │  │
│  └───────────────────────────────┘  │
│                                     │
│  Reason for Change (Required)       │
│  ┌───────────────────────────────┐  │
│  │ Reducing penalty to 3 deeds   │  │
│  │ worth as 2 deeds were marked  │  │
│  │ as Sunnah, not Fara'id.       │  │
│  └───────────────────────────────┘  │
│                                     │
│  Impact:                            │
│  Difference: -10,000                │
│  New Balance: 140,000               │
│                                     │
│  [Cancel] [Save Changes]            │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Search Interface
- **User Search**: Type-ahead autocomplete
- **Recent Users**: Quick access list

#### Penalty Overview
- **User Info Card**: Name, membership, balance
- **Tab Filters**: All, Unpaid, Paid, Waived
- **Penalty Cards**:
  - Date incurred
  - Amount
  - Reason
  - Status badge
  - Action buttons
- **Manual Actions**:
  - Add Penalty button
  - Bulk operations

#### Action Dialogs
- **Add Penalty**:
  - Date picker
  - Amount input
  - Reason text area (required)
  - Impact preview
  - Confirmation
- **Remove Penalty**:
  - Penalty summary
  - Removal reason (required)
  - Warning about permanence
  - Balance preview
- **Waive Penalty**:
  - Penalty summary
  - Waiver reason (required)
  - Actions checklist
  - Balance preview
- **Edit Amount**:
  - Current amount display
  - New amount input
  - Change reason (required)
  - Difference calculation

---

## Report Management

Edit user reports for corrections.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Report Management             │
├─────────────────────────────────────┤
│                                     │
│  🔍 SEARCH REPORTS                  │
│                                     │
│  User                               │
│  [Select user ▼]                    │
│                                     │
│  Date Range                         │
│  [Start Date ▼] [End Date ▼]        │
│                                     │
│  Status                             │
│  ○ All                              │
│  ○ Submitted                        │
│  ○ Draft                            │
│                                     │
│  [Search]                           │
│                                     │
└─────────────────────────────────────┘
```

### Report Edit Screen

```
┌─────────────────────────────────────┐
│  [←]  Edit Report                   │
│       Ahmad Mohamed - Oct 22, 2025  │
├─────────────────────────────────────┤
│                                     │
│  ⚠️ EDIT MODE - ADMIN OVERRIDE      │
│  Changes will recalculate penalties │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🕌 FARA'ID DEEDS                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Fajr              1.0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Dhuhr             1.0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Asr               1.0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Maghrib           1.0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐ Isha              0.0     │   │
│  └─────────────────────────────┘   │
│                                     │
│  📖 SUNNAH DEEDS                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Night Prayer    ──────●─    │   │
│  │                 0.7         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 SUMMARY                         │
│                                     │
│  Original: 7.5/10                   │
│  Current: 8.2/10                    │
│                                     │
│  Original Penalty: 12,500           │
│  New Penalty: 9,000                 │
│  Difference: -3,500                 │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Reason for Edit (Required)         │
│  ┌───────────────────────────────┐  │
│  │ User submitted paper copy     │  │
│  │ showing additional deeds.     │  │
│  │ Updating to reflect accurate  │  │
│  │ completion.                   │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions on save:                   │
│  ☑ Update report values             │
│  ☑ Recalculate penalties            │
│  ☑ Adjust user balance              │
│  ☑ Send notification to user        │
│  ☑ Log in audit trail               │
│                                     │
│  [Cancel] [Save Changes]            │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Search Interface
- **User Selector**: Dropdown with search
- **Date Range**: Start and end date pickers
- **Status Filter**: Radio buttons
- **Search Button**: Execute query
- **Results List**: Matching reports

#### Edit Screen
- **Warning Banner**: Admin override notice
- **Deed Inputs**: Same as user report screen
  - Checkboxes for binary
  - Sliders for fractional
  - Real-time updates
- **Summary Comparison**:
  - Original values
  - Current values
  - Difference calculations
- **Reason Field**: Required explanation
- **Actions Checklist**: What will happen
- **Save Button**: Commit changes with confirmation

---

## Enhanced Analytics Dashboard

Comprehensive system-wide metrics and insights.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Analytics Dashboard           │
│                                     │
│  [Today] [Week] [Month] [Custom]    │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  👥 USER METRICS                    │
│                                     │
│  ┌──────┬──────┬──────┬──────┐     │
│  │Pend  │Active│Susp  │Deact │     │
│  │  5   │ 150  │  3   │  2   │     │
│  └──────┴──────┴──────┴──────┘     │
│                                     │
│  By Membership:                     │
│  🌱 New: 12 | 💎 Exclusive: 120    │
│  👑 Legacy: 18                      │
│                                     │
│  ⚠️ At Risk (>400k balance): 8     │
│  📈 New Registrations: +5 this week │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 DEED METRICS                    │
│                                     │
│  Total Deeds Submitted              │
│  Today: 1,245 | Week: 8,960         │
│  Month: 35,420 | All: 450,000       │
│                                     │
│  Average Per User                   │
│  Today: 8.3 | Week: 8.5 | Month: 8.7│
│                                     │
│  Compliance Rate                    │
│  Today: 65% (97/150 users)          │
│  Week: 72% | Month: 68%             │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Top Performers              │   │
│  │ 1. Fatima Ali - 9.8 avg     │   │
│  │ 2. Ahmad Mohamed - 9.5 avg  │   │
│  │ 3. Omar Hassan - 9.2 avg    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Need Attention              │   │
│  │ 1. Khadija - 4.2 avg        │   │
│  │ 2. Maryam - 5.1 avg         │   │
│  │ 3. Hassan - 5.5 avg         │   │
│  └─────────────────────────────┘   │
│                                     │
│  Deed Compliance:                   │
│  Fara'id: 88% | Sunnah: 76%         │
│                                     │
│  Individual Deeds:                  │
│  Most: Maghrib (95%)                │
│  Least: Duha (62%)                  │
│                                     │
│  [View Detailed Breakdown →]        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💰 FINANCIAL METRICS               │
│                                     │
│  Penalties Incurred                 │
│  This Month: 2,500,000              │
│  All Time: 35,000,000               │
│                                     │
│  Payments Received                  │
│  This Month: 1,800,000              │
│  All Time: 28,000,000               │
│                                     │
│  Outstanding Balance: 7,000,000     │
│                                     │
│  Pending Payments                   │
│  Count: 15 | Amount: 450,000        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📱 ENGAGEMENT METRICS              │
│                                     │
│  DAU: 142/150 (95%)                 │
│  Report Submission Rate: 89%        │
│  Avg Submission Time: 9:30 PM       │
│  Notification Open Rate: 78%        │
│  Avg Response Time: 45 min          │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🛡️ EXCUSE METRICS                 │
│                                     │
│  Pending: 8                         │
│  Approval Rate: 85%                 │
│  Most Common: Sickness (45%)        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Export Full Report 📥]            │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

Comprehensive metrics across all system areas:

- **User Metrics**: Counts by status and membership
- **Deed Metrics**: Submission stats and compliance
- **Financial Metrics**: Penalties and payments
- **Engagement Metrics**: User activity patterns
- **Excuse Metrics**: Request statistics
- **Export Options**: PDF or Excel with charts

---

## Audit Log Viewer

Complete history of all administrative actions.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Audit Log                     │
│                                     │
│  [Filters ▼]        [Export 📥]     │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ━━━━━━ TODAY ━━━━━━               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 2:45 PM                     │   │
│  │ Penalty Waived              │   │
│  │                             │   │
│  │ By: Admin Yusuf             │   │
│  │ User: Ahmad Mohamed         │   │
│  │ Amount: 25,000              │   │
│  │                             │   │
│  │ Old: 150,000 → New: 125,000 │   │
│  │                             │   │
│  │ Reason: Medical emergency   │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 11:30 AM                    │   │
│  │ Report Edited               │   │
│  │                             │   │
│  │ By: Admin Yusuf             │   │
│  │ User: Fatima Ali            │   │
│  │ Report: Oct 21, 2025        │   │
│  │                             │   │
│  │ Changes: Fajr 0→1, Total    │   │
│  │ 7.5→8.5, Penalty 12.5k→7.5k │   │
│  │                             │   │
│  │ Reason: Paper submission    │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Filter Options

```
┌─────────────────────────────────────┐
│  Audit Log Filters          [✕]     │
├─────────────────────────────────────┤
│                                     │
│  Date Range                         │
│  [Start Date ▼] [End Date ▼]        │
│                                     │
│  Action Type                        │
│  ☐ Penalty Adjusted                 │
│  ☐ Report Edited                    │
│  ☐ User Suspended                   │
│  ☐ User Approved                    │
│  ☐ Payment Processed                │
│  ☐ Settings Changed                 │
│  ☐ Deed Modified                    │
│  ☐ Excuse Processed                 │
│                                     │
│  Performed By                       │
│  [Select admin/cashier ▼]           │
│                                     │
│  Entity Type                        │
│  ○ All                              │
│  ○ User                             │
│  ○ Report                           │
│  ○ Penalty                          │
│  ○ Payment                          │
│  ○ System                           │
│                                     │
│  User Affected                      │
│  [Select user ▼]                    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Clear All] [Apply Filters]        │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Filters**: Comprehensive filtering options
- **Log Entries**: Chronological list
  - Timestamp
  - Action type
  - Performer (admin/cashier name)
  - Affected user
  - Entity details
  - Before/after values
  - Reason/notes
  - Expandable details
- **Export**: Download filtered logs as Excel

---

## Content Management

Manage app content and announcements.

### Rules & Policies Editor

```
┌─────────────────────────────────────┐
│  [←]  Rules & Policies Editor       │
│                                     │
│  [Edit Mode] [Preview Mode]         │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📝 SECTIONS                        │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ 1. Introduction          │   │
│  │    [✏️ Edit] [🗑️]          │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ⋮⋮ 2. Membership Tiers      │   │
│  │    [✏️ Edit] [🗑️]          │   │
│  └─────────────────────────────┘   │
│                                     │
│  [+ Add Section]                    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  EDIT: Introduction                 │
│                                     │
│  Section Title                      │
│  ┌───────────────────────────────┐  │
│  │ Introduction                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Content (Rich Text Editor)         │
│  ┌───────────────────────────────┐  │
│  │ [B] [I] [U] [List] [Link]     │  │
│  ├───────────────────────────────┤  │
│  │ Welcome to Sabiquun! This app │  │
│  │ helps you track your daily    │  │
│  │ Islamic deeds and maintain... │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Cancel] [Save Section]            │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Preview] [Publish Changes]        │
│  [View Version History]             │
│                                     │
└─────────────────────────────────────┘
```

### App Announcements

```
┌─────────────────────────────────────┐
│  [←]  App Announcements             │
│                                     │
│  [Active] [Scheduled] [Past]        │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ACTIVE ANNOUNCEMENTS               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🎉 Ramadan Schedule         │   │
│  │ Priority: High              │   │
│  │                             │   │
│  │ "Special grace period       │   │
│  │  extended during Ramadan!"  │   │
│  │                             │   │
│  │ Started: Oct 15, 2025       │   │
│  │ Ends: Nov 14, 2025          │   │
│  │                             │   │
│  │ Persistent (non-dismissible)│   │
│  │                             │   │
│  │ [✏️ Edit] [End Now]         │   │
│  └─────────────────────────────┘   │
│                                     │
│  [+ Create Announcement]            │
│                                     │
└─────────────────────────────────────┘
```

### Create Announcement

```
┌─────────────────────────────────────┐
│  Create Announcement          [✕]   │
├─────────────────────────────────────┤
│                                     │
│  Title                              │
│  ┌───────────────────────────────┐  │
│  │ System Maintenance Notice     │  │
│  └───────────────────────────────┘  │
│                                     │
│  Message                            │
│  ┌───────────────────────────────┐  │
│  │ The app will be under         │  │
│  │ maintenance on Oct 25 from    │  │
│  │ 2-4 AM. Please submit reports │  │
│  │ before this time.             │  │
│  └───────────────────────────────┘  │
│                                     │
│  Display Period                     │
│  Start: [Oct 24, 2025 ▼]            │
│  End: [Oct 26, 2025 ▼]              │
│                                     │
│  Priority Level                     │
│  ○ Low (Info)                       │
│  ● Medium (Notice)                  │
│  ○ High (Alert)                     │
│                                     │
│  Display Type                       │
│  ● Dismissible (users can close)    │
│  ○ Persistent (always visible)      │
│                                     │
│  Target Users                       │
│  ● All users                        │
│  ○ Specific membership tiers        │
│                                     │
│  [Cancel] [Create Announcement]     │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Rules Editor
- **Section List**: Drag to reorder
- **Rich Text Editor**: Formatting toolbar
- **Preview Mode**: See user view
- **Version History**: Track changes
- **Publish Button**: Make changes live

#### Announcements
- **Active Tab**: Currently displayed
- **Scheduled Tab**: Future announcements
- **Past Tab**: Expired announcements
- **Create Form**:
  - Title and message
  - Date range
  - Priority level
  - Dismissible option
  - Target audience
- **Edit/Delete**: Manage existing

---

## Related Documentation

- [Normal User Screens](./02-user-screens.md)
- [Supervisor Screens](./03-supervisor-screens.md)
- [Cashier Screens](./04-cashier-screens.md)
- [Authentication Screens](./01-authentication.md)
- [Database Schema](../database/)
- [System Architecture](../technical/)

---

*Last Updated: 2025-10-22*
