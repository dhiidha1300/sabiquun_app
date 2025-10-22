# Supervisor Screens

This document outlines all screens and interfaces available to supervisors. Supervisors have access to all normal user features plus additional oversight and management capabilities.

---

## Overview

Supervisors inherit all features from [Normal User Screens](./02-user-screens.md) and gain access to:

- User Reports Dashboard
- Leaderboard Management
- Manual Notification System
- Excuse Management
- Analytics Dashboard

---

## User Reports Dashboard

Comprehensive view of all user reports with search and filtering capabilities.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  All User Reports              │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ 🔍 Search users...            │  │
│  └───────────────────────────────┘  │
│                                     │
│  [Filters 🔽]     [Export 📥]       │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Active Users (142)                 │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Ahmad Mohamed          │   │
│  │      💎 Exclusive           │   │
│  │                             │   │
│  │  Today: [████████░░] 8/10   │   │
│  │  Last Report: 2 hours ago   │   │
│  │  Compliance: 85%            │   │
│  │                             │   │
│  │  [View Details →]           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Fatima Ali             │   │
│  │      🌱 New Member          │   │
│  │                             │   │
│  │  Today: [██████████] 10/10  │   │
│  │  Last Report: 1 hour ago    │   │
│  │  Compliance: 92%            │   │
│  │                             │   │
│  │  [View Details →]           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Omar Hassan            │   │
│  │      💎 Exclusive           │   │
│  │                             │   │
│  │  Today: [████░░░░░░] 4/10   │   │
│  │  Last Report: 3 days ago ⚠️ │   │
│  │  Compliance: 62%            │   │
│  │                             │   │
│  │  [View Details →]           │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [👥] [🔔] [⚙️]         │
└─────────────────────────────────────┘
```

### Filter Drawer

```
┌─────────────────────────────────────┐
│  Filters                      [✕]   │
├─────────────────────────────────────┤
│                                     │
│  Membership Status                  │
│  ☑ New                              │
│  ☑ Exclusive                        │
│  ☑ Legacy                           │
│                                     │
│  Compliance Rate                    │
│  ○ All                              │
│  ○ High (90%+)                      │
│  ○ Medium (70-89%)                  │
│  ○ Low (<70%)                       │
│                                     │
│  Today's Report Status              │
│  ○ All                              │
│  ○ Submitted                        │
│  ○ Not Submitted                    │
│  ○ Incomplete                       │
│                                     │
│  Sort By                            │
│  ○ Name (A-Z)                       │
│  ○ Compliance (High to Low)         │
│  ○ Last Report (Recent First)       │
│  ○ Balance (High to Low)            │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Clear All] [Apply Filters]        │
│                                     │
└─────────────────────────────────────┘
```

### User Details View

```
┌─────────────────────────────────────┐
│  [←]  Ahmad Mohamed                 │
├─────────────────────────────────────┤
│                                     │
│  [👤 Profile Photo]                 │
│  💎 Exclusive Member                │
│  ahmad@example.com                  │
│  +252 61 123 4567                   │
│  Member since: Jan 15, 2025         │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 STATISTICS                      │
│                                     │
│  Overall Compliance: 85%            │
│  Current Balance: 150,000           │
│  Total Reports: 287                 │
│  Current Streak: 12 days            │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📋 RECENT REPORTS                  │
│                                     │
│  [This Week] [This Month] [All]     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 22  [████████░░] 8/10   │   │
│  │ Penalty: 10,000 shillings   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 21  [██████████] 10/10  │   │
│  │ No Penalty                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [View All Reports →]               │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💳 PAYMENT HISTORY                 │
│  [View Payment History →]           │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Header
- **Back Button**: Return to supervisor dashboard
- **Title**: "All User Reports"
- **Search Bar**: Real-time search by name/email
  - Shows matching results as user types
- **Filter Icon**: Opens filter drawer
- **Export Icon**: Download reports

#### User Cards
- **Profile Photo**: Circular avatar
- **Name**: User's full name
- **Membership Badge**: Visual tier indicator
- **Today's Progress**:
  - Progress bar
  - Ratio display (e.g., "8/10")
- **Last Report Timestamp**:
  - Relative time (e.g., "2 hours ago")
  - Warning icon if > 24 hours
- **Compliance Rate**: Overall percentage
- **View Details Button**: Navigate to user profile

#### Export Options
- **Date Range Selector**: Custom period
- **User Selection**:
  - All users (filtered)
  - Specific users (multi-select)
- **Format Options**:
  - PDF (summary report)
  - Excel (detailed data)
- **Include Options**:
  - User information
  - Report details
  - Penalty calculations
  - Payment history

---

## Leaderboard Management

Create and manage leaderboards to encourage healthy competition.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Leaderboard                   │
│                                     │
│  [Daily] [Weekly] [Monthly] [All]   │
│                                     │
│  [⚙️ Settings]        [📥 Export]   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🏆 TOP PERFORMERS - THIS WEEK      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🥇 #1                       │   │
│  │ [👤] Fatima Ali             │   │
│  │      💎 Exclusive           │   │
│  │      9.8 avg | 🌅 Fajr ✓   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🥈 #2                       │   │
│  │ [👤] Ahmad Mohamed          │   │
│  │      💎 Exclusive           │   │
│  │      9.5 avg | 🌅 Fajr ✓   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🥉 #3                       │   │
│  │ [👤] Khadija Nur            │   │
│  │      🌱 New Member          │   │
│  │      9.2 avg                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ #4  [👤] Omar Hassan        │   │
│  │     💎 Exclusive | 8.9 avg  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ #5  [👤] Maryam Abdi        │   │
│  │     💎 Exclusive | 8.7 avg  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Load More...]                     │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [👥] [🔔] [⚙️]         │
└─────────────────────────────────────┘
```

### Special Tags Management

```
┌─────────────────────────────────────┐
│  [←]  Special Tags Management       │
├─────────────────────────────────────┤
│                                     │
│  🏅 ACHIEVEMENT TAGS                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌅 Fajr Champion            │   │
│  │ Criteria: 90%+ Fajr for 30  │   │
│  │          consecutive days   │   │
│  │                             │   │
│  │ Auto-assign: [●─→] ON       │   │
│  │ Active Users: 15            │   │
│  │                             │   │
│  │ [Edit Rules] [View Users]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 💯 Perfect Week             │   │
│  │ Criteria: 10/10 all 7 days  │   │
│  │                             │   │
│  │ Auto-assign: [●─→] ON       │   │
│  │ Active Users: 8             │   │
│  │                             │   │
│  │ [Edit Rules] [View Users]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🔥 On Fire (Custom)         │   │
│  │ Criteria: Manual assignment │   │
│  │                             │   │
│  │ Auto-assign: [─○→] OFF      │   │
│  │ Active Users: 3             │   │
│  │                             │   │
│  │ [Edit Rules] [View Users]   │   │
│  └─────────────────────────────┘   │
│                                     │
│  [+ Create New Tag]                 │
│                                     │
└─────────────────────────────────────┘
```

### Leaderboard Settings

```
┌─────────────────────────────────────┐
│  [←]  Leaderboard Settings          │
├─────────────────────────────────────┤
│                                     │
│  Display Options                    │
│                                     │
│  ☑ Show profile photos              │
│  ☑ Show membership badges           │
│  ☑ Show special tags                │
│  ☑ Show average deeds               │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Filters                            │
│                                     │
│  Membership Status                  │
│  ☑ Include New Members              │
│  ☑ Include Exclusive Members        │
│  ☑ Include Legacy Members           │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Calculation Method                 │
│  ● Average deeds per day            │
│  ○ Total deeds in period            │
│  ○ Compliance percentage            │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  Reset Schedule                     │
│                                     │
│  Daily: Midnight                    │
│  Weekly: Sunday 00:00               │
│  Monthly: 1st of month              │
│                                     │
│  [Manual Reset Now]                 │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Save Settings]                    │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Leaderboard View
- **Time Period Tabs**: Filter by timeframe
  - Daily: Today's rankings
  - Weekly: This week
  - Monthly: This month
  - All-Time: Historical rankings
- **Rank Cards**:
  - Medal icons for top 3 (🥇🥈🥉)
  - Rank number
  - Profile photo
  - User name
  - Membership badge
  - Average or total deeds
  - Special achievement tags
- **Settings Icon**: Configure leaderboard options
- **Export Icon**: Download as PDF/Excel

#### Special Tags Section
- **Tag Cards**: Display achievement criteria
  - Tag icon and name
  - Criteria description
  - Auto-assign toggle
  - Active users count
  - Edit and view buttons
- **Create Tag Button**: Define new achievement
- **Manual Assignment**: Select users for tag

#### Settings Panel
- **Display Toggles**: Show/hide information
- **Membership Filters**: Include/exclude tiers
- **Calculation Method**: How ranks are determined
- **Reset Schedule**: Automatic reset timing
- **Manual Reset**: Immediate leaderboard reset

---

## Manual Notification Screen

Send custom notifications to users or user groups.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Send Notification             │
├─────────────────────────────────────┤
│                                     │
│  ✉️ COMPOSE NOTIFICATION            │
│                                     │
│  Title                              │
│  ┌───────────────────────────────┐  │
│  │ Ramadan Schedule Update       │  │
│  └───────────────────────────────┘  │
│                                     │
│  Message                            │
│  ┌───────────────────────────────┐  │
│  │ Assalamu alaikum {user_name}, │  │
│  │                               │  │
│  │ Please note that during       │  │
│  │ Ramadan, the grace period     │  │
│  │ will be extended to 6 hours.  │  │
│  │                               │  │
│  │ JazakAllah khair!             │  │
│  └───────────────────────────────┘  │
│                                     │
│  💡 Available Placeholders:         │
│  {user_name}, {balance}, {deeds},   │
│  {date}, {penalty}                  │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📤 RECIPIENTS                      │
│                                     │
│  ○ All Active Users (142)           │
│  ○ By Membership Status             │
│    ☐ New Members (12)               │
│    ☐ Exclusive Members (120)        │
│    ☐ Legacy Members (10)            │
│  ○ Specific Users                   │
│    [Select Users...]                │
│  ○ Users with no report today (8)   │
│  ○ Users with high balance (23)     │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ⏰ DELIVERY                        │
│                                     │
│  ● Send Now                         │
│  ○ Schedule for Later               │
│    Date: [Select...]                │
│    Time: [Select...]                │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Preview] [Send Notification]      │
│                                     │
└─────────────────────────────────────┘
```

### Notification History

```
┌─────────────────────────────────────┐
│  [←]  Notification History          │
├─────────────────────────────────────┤
│                                     │
│  [Sent] [Scheduled] [Drafts]        │
│                                     │
│  ━━━━━━ TODAY ━━━━━━               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📬 Ramadan Schedule Update  │   │
│  │ Sent: Oct 22, 2:30 PM       │   │
│  │ To: All Active Users (142)  │   │
│  │ Delivered: 139 | Opened: 98 │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━ YESTERDAY ━━━━━━           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📬 Payment Reminder         │   │
│  │ Sent: Oct 21, 6:00 PM       │   │
│  │ To: High Balance Users (23) │   │
│  │ Delivered: 23 | Opened: 18  │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━ LAST WEEK ━━━━━━           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📬 Weekly Leaderboard       │   │
│  │ Sent: Oct 18, 9:00 AM       │   │
│  │ To: All Active Users (145)  │   │
│  │ Delivered: 145 | Opened: 112│   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Compose Form
- **Title Input**: Notification headline (max 60 chars)
- **Message Text Area**: Main content with placeholder support
  - Rich text formatting (bold, italic)
  - Character counter
  - Placeholder insertion buttons
- **Placeholder Guide**: List of available variables

#### Recipient Selection
- **Radio Button Groups**: Targeting options
  - All Active Users: Broadcast to everyone
  - By Membership: Filter by tier (checkboxes)
  - Specific Users: Multi-select picker
  - Conditional Groups: Predefined filters
    - No report today
    - High balance (threshold configurable)
    - Low compliance
- **Recipient Count**: Live update of target users

#### Delivery Options
- **Send Now**: Immediate delivery
- **Schedule**: Date and time pickers
  - Calendar for date
  - Time selector (24-hour)
  - Timezone display

#### Action Buttons
- **Preview**: Show formatted notification
  - Sample data for placeholders
  - Both push and email preview
- **Send/Schedule Button**: Primary action
  - Confirmation dialog
  - Shows recipient count

#### Notification History
- **Tab Filters**: Sent, Scheduled, Drafts
- **Notification Cards**:
  - Icon and title
  - Send timestamp
  - Recipient description
  - Delivery statistics
  - Open rate
  - View details button
- **Detail View**: Full notification with analytics
  - Complete message
  - Recipient list
  - Delivery status per user
  - Open timestamps

---

## Excuse Management Screen

Review and approve/reject user excuse requests.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Excuse Management             │
├─────────────────────────────────────┤
│  [Pending (8)] [History]            │
├─────────────────────────────────────┤
│                                     │
│  🔍 [Search users...]               │
│  [Filters ▼]     [☑ Select Mode]    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [☐] Ahmad Mohamed           │   │
│  │     💎 Exclusive            │   │
│  │                             │   │
│  │ Date: Oct 20, 2025          │   │
│  │ Type: Sickness              │   │
│  │ Deeds: All deeds            │   │
│  │                             │   │
│  │ Description:                │   │
│  │ "Severe flu, unable to      │   │
│  │  perform prayers on time"   │   │
│  │                             │   │
│  │ Submitted: Oct 20, 9:30 AM  │   │
│  │                             │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [☐] Fatima Ali              │   │
│  │     🌱 New Member           │   │
│  │                             │   │
│  │ Date: Oct 21-22, 2025       │   │
│  │ Type: Travel                │   │
│  │ Deeds: Fajr, Dhuhr, Asr     │   │
│  │                             │   │
│  │ Description:                │   │
│  │ "Traveling to Mogadishu     │   │
│  │  for family emergency"      │   │
│  │                             │   │
│  │ Submitted: Oct 21, 7:00 AM  │   │
│  │                             │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [☑ 2 selected]                     │
│  [Bulk Approve] [Bulk Reject]       │
│                                     │
└─────────────────────────────────────┘
```

### Approval/Rejection Dialog

```
┌─────────────────────────────────────┐
│  Approve Excuse Request             │
├─────────────────────────────────────┤
│                                     │
│  User: Ahmad Mohamed                │
│  Date: Oct 20, 2025                 │
│  Type: Sickness                     │
│  Deeds: All deeds                   │
│                                     │
│  Add Note (optional):               │
│  ┌───────────────────────────────┐  │
│  │ Approved. Get well soon!      │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions on approval:               │
│  ☑ Waive penalties for this date    │
│  ☑ Send notification to user        │
│                                     │
│  [Cancel] [Confirm Approval]        │
│                                     │
└─────────────────────────────────────┘
```

```
┌─────────────────────────────────────┐
│  Reject Excuse Request              │
├─────────────────────────────────────┤
│                                     │
│  User: Ahmad Mohamed                │
│  Date: Oct 20, 2025                 │
│  Type: Sickness                     │
│  Deeds: All deeds                   │
│                                     │
│  Reason for Rejection (required):   │
│  ┌───────────────────────────────┐  │
│  │ Please provide medical        │  │
│  │ documentation for multi-day   │  │
│  │ sick leave requests.          │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions on rejection:              │
│  ☑ Apply penalties for this date    │
│  ☑ Send notification to user        │
│                                     │
│  [Cancel] [Confirm Rejection]       │
│                                     │
└─────────────────────────────────────┘
```

### Excuse History Tab

```
┌─────────────────────────────────────┐
│  [←]  Excuse Management             │
├─────────────────────────────────────┤
│  [Pending] [History]                │
├─────────────────────────────────────┤
│                                     │
│  [Filters ▼]        [Export 📥]     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Ahmad Mohamed               │   │
│  │ Oct 15, 2025 | Travel       │   │
│  │ ✓ APPROVED                  │   │
│  │                             │   │
│  │ Reviewed by: You            │   │
│  │ Reviewed: Oct 15, 11:00 AM  │   │
│  │ Note: Safe travels!         │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Omar Hassan                 │   │
│  │ Oct 12, 2025 | Raining      │   │
│  │ ✗ REJECTED                  │   │
│  │                             │   │
│  │ Reviewed by: Supervisor Ali │   │
│  │ Reviewed: Oct 12, 3:00 PM   │   │
│  │ Note: No rain recorded      │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Pending Excuses Tab
- **Search Bar**: Filter by user name
- **Filters**: Status, type, date range
- **Select Mode Toggle**: Enable bulk actions
- **Excuse Cards**:
  - Checkbox (when select mode active)
  - User info with profile photo
  - Membership badge
  - Date(s) of excuse
  - Excuse type badge
  - Affected deeds list
  - Description text
  - Submission timestamp
  - Approve/Reject buttons
- **Bulk Action Buttons**: (When items selected)
  - Bulk Approve
  - Bulk Reject

#### Approval/Rejection Dialogs
- **User Summary**: Who and what
- **Note Field**: Optional message (required for rejection)
- **Action Checkboxes**: What happens
  - Waive/apply penalties
  - Send notification
- **Confirm Button**: Execute action

#### History Tab
- **Filter Options**:
  - Status (Approved/Rejected)
  - User search
  - Date range
  - Excuse type
  - Reviewer filter
- **History Cards**:
  - User name
  - Date and excuse type
  - Status badge (green/red)
  - Reviewer name
  - Review timestamp
  - Reviewer notes
  - View details button
- **Export Button**: Download as Excel

---

## Analytics Dashboard

Overview of user engagement and system metrics.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Analytics                     │
│                                     │
│  [Today] [Week] [Month] [Custom]    │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📊 OVERVIEW                        │
│                                     │
│  ┌──────────┬──────────┬────────┐  │
│  │  Active  │  Average │  Top   │  │
│  │  Users   │  Deeds   │ Compl. │  │
│  │   142    │   8.3    │  92%   │  │
│  └──────────┴──────────┴────────┘  │
│                                     │
│  📈 COMPLIANCE TRENDS               │
│  ┌─────────────────────────────┐   │
│  │     Daily Compliance        │   │
│  │                             │   │
│  │ 100%│         ╱╲            │   │
│  │  90%│      ╱╲╱  ╲╱╲         │   │
│  │  80%│   ╱╲╱          ╲      │   │
│  │  70%│╱╲╱                ╲   │   │
│  │  60%└───────────────────────│   │
│  │     M  T  W  T  F  S  S     │   │
│  └─────────────────────────────┘   │
│                                     │
│  📊 DEED TYPE BREAKDOWN             │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │  Fara'id: 88% ████████░░    │   │
│  │  Sunnah:  76% ███████░░░    │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  👥 USER ENGAGEMENT                 │
│  ┌─────────────────────────────┐   │
│  │ Active Users: 142/150 (95%) │   │
│  │ Report Submission: 89%      │   │
│  │ Avg Submission Time: 9:30PM │   │
│  │                             │   │
│  │ Most Missed: Duha (38%)     │   │
│  │ Best Performing: Maghrib    │   │
│  └─────────────────────────────┘   │
│                                     │
│  📋 INDIVIDUAL DEED HEATMAP         │
│  ┌─────────────────────────────┐   │
│  │ Fajr    ████████░░ 88%      │   │
│  │ Dhuhr   █████████░ 92%      │   │
│  │ Asr     ████████░░ 87%      │   │
│  │ Maghrib ██████████ 95%      │   │
│  │ Isha    ███████░░░ 82%      │   │
│  │ Qiyam   █████░░░░░ 65%      │   │
│  │ Duha    ████░░░░░░ 62%      │   │
│  │ Fasting ███████░░░ 78%      │   │
│  │ Rawatib ██████░░░░ 71%      │   │
│  │ Witr    ███████░░░ 76%      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Export Report 📥]                 │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Time Period Selector
- **Tabs**: Today, Week, Month, Custom
- **Custom Range**: Date picker for start/end

#### Overview Cards
- **Active Users**: Count of users who submitted today
- **Average Deeds**: Mean completion across all users
- **Top Compliance**: Highest individual rate
- **Large Numbers**: Prominent display

#### Compliance Trends Chart
- **Line Graph**: Daily compliance over time
- **X-Axis**: Days of selected period
- **Y-Axis**: Percentage (0-100%)
- **Interactive**: Tap points for details

#### Deed Type Breakdown
- **Progress Bars**: Visual percentage
- **Fara'id vs Sunnah**: Separate compliance rates
- **Color Coding**: Green for high, yellow for medium

#### User Engagement Metrics
- **Active User Ratio**: Fraction and percentage
- **Submission Rate**: % who submitted report
- **Average Time**: When most users submit
- **Most Missed Deed**: Lowest completion rate
- **Best Deed**: Highest completion rate

#### Individual Deed Heatmap
- **Horizontal Bars**: One per deed
- **Completion Percentage**: % of users who completed
- **Color Gradient**: Visual heat indication
- **Sort Order**: Matches deed template order

#### Export Button
- **PDF**: Visual charts and summary
- **Excel**: Raw data with calculations
- **Date Range**: Included in filename

---

## Bottom Navigation

Supervisors have an extended navigation bar:

```
┌─────────────────────────────────────┐
│  [🏠] [📊] [👥] [🔔] [⚙️]         │
│  Home  Analytics  Users  Notify  Settings
└─────────────────────────────────────┘
```

- **🏠 Home**: Supervisor dashboard (same as normal user)
- **📊 Analytics**: Analytics dashboard
- **👥 Users**: User reports dashboard
- **🔔 Notify**: Manual notification screen
- **⚙️ Settings**: Settings (with supervisor options)

---

## Related Documentation

- [Normal User Screens](./02-user-screens.md)
- [Cashier Screens](./04-cashier-screens.md)
- [Admin Screens](./05-admin-screens.md)
- [Authentication Screens](./01-authentication.md)
- [Feature Specifications](../features/)

---

*Last Updated: 2025-10-22*
