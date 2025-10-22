# Cashier Screens

This document outlines all screens and interfaces available to cashiers. Cashiers have access to all normal user features plus payment management capabilities.

---

## Overview

Cashiers inherit all features from [Normal User Screens](./02-user-screens.md) and gain access to:

- Payment Review Dashboard
- User Balance Management
- Payment Analytics

---

## Payment Review Dashboard

Central interface for reviewing and processing user payment submissions.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Payment Management            │
├─────────────────────────────────────┤
│  [Pending (15)] [History]           │
├─────────────────────────────────────┤
│                                     │
│  🔍 [Search by user or ref...]      │
│  [Filters ▼]        [Export 📥]     │
│                                     │
│  PENDING PAYMENTS                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Ahmad Mohamed          │   │
│  │      💎 Exclusive           │   │
│  │                             │   │
│  │ Amount: 50,000 Shillings    │   │
│  │ Method: ZAAD                │   │
│  │ Ref: ZD1234567890           │   │
│  │                             │   │
│  │ Current Balance: 150,000    │   │
│  │ Submitted: 2 hours ago      │   │
│  │                             │   │
│  │ [View Details]              │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Fatima Ali             │   │
│  │      🌱 New Member          │   │
│  │                             │   │
│  │ Amount: 100,000 Shillings   │   │
│  │ Method: eDahab              │   │
│  │ Ref: ED9876543210           │   │
│  │                             │   │
│  │ Current Balance: 100,000    │   │
│  │ Submitted: 5 hours ago      │   │
│  │                             │   │
│  │ [View Details]              │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Omar Hassan            │   │
│  │      💎 Exclusive           │   │
│  │                             │   │
│  │ Amount: 75,000 Shillings    │   │
│  │ Method: ZAAD                │   │
│  │ Ref: ZD1122334455           │   │
│  │                             │   │
│  │ Current Balance: 250,000    │   │
│  │ Submitted: 1 day ago ⚠️     │   │
│  │                             │   │
│  │ [View Details]              │   │
│  │ [✓ Approve] [✗ Reject]      │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [👥] [⚙️]         │
└─────────────────────────────────────┘
```

### Payment Details Modal

```
┌─────────────────────────────────────┐
│  Payment Details              [✕]   │
├─────────────────────────────────────┤
│                                     │
│  👤 USER INFORMATION                │
│                                     │
│  Name: Ahmad Mohamed                │
│  Email: ahmad@example.com           │
│  Phone: +252 61 123 4567            │
│  Member: 💎 Exclusive               │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💳 PAYMENT DETAILS                 │
│                                     │
│  Amount: 50,000 Shillings           │
│  Method: ZAAD                       │
│  Reference: ZD1234567890            │
│  Type: Partial Payment              │
│  Submitted: Oct 22, 2025 2:30 PM    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💰 BALANCE INFORMATION             │
│                                     │
│  Current Balance: 150,000           │
│  After Payment: 100,000             │
│                                     │
│  Penalty Breakdown (FIFO):          │
│  ┌─────────────────────────────┐   │
│  │ Oct 10 - 25,000 → PAID ✓    │   │
│  │ Oct 12 - 25,000 → PAID ✓    │   │
│  │ Oct 15 - 30,000 → 5,000 left│   │
│  │ Oct 18 - 40,000 (unpaid)    │   │
│  │ Oct 20 - 30,000 (unpaid)    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 PAYMENT DISTRIBUTION PREVIEW    │
│                                     │
│  50,000 will be applied to:         │
│  • Oct 10 penalty: -25,000          │
│  • Oct 12 penalty: -25,000          │
│  • Remaining: 0                     │
│                                     │
│  New balance: 100,000               │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [✓ Approve Payment]                │
│  [✗ Reject Payment]                 │
│                                     │
└─────────────────────────────────────┘
```

### Approval Confirmation Dialog

```
┌─────────────────────────────────────┐
│  Approve Payment                    │
├─────────────────────────────────────┤
│                                     │
│  Confirm payment approval:          │
│                                     │
│  User: Ahmad Mohamed                │
│  Amount: 50,000 Shillings           │
│  Method: ZAAD                       │
│  Reference: ZD1234567890            │
│                                     │
│  Notes (optional):                  │
│  ┌───────────────────────────────┐  │
│  │ Payment verified. Receipt     │  │
│  │ confirmed via ZAAD system.    │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions on approval:               │
│  ☑ Apply payment to balance (FIFO)  │
│  ☑ Generate receipt for user        │
│  ☑ Send confirmation notification   │
│  ☑ Log in audit trail               │
│                                     │
│  [Cancel] [Confirm Approval]        │
│                                     │
└─────────────────────────────────────┘
```

### Rejection Dialog

```
┌─────────────────────────────────────┐
│  Reject Payment                     │
├─────────────────────────────────────┤
│                                     │
│  Reject payment submission:         │
│                                     │
│  User: Ahmad Mohamed                │
│  Amount: 50,000 Shillings           │
│  Method: ZAAD                       │
│  Reference: ZD1234567890            │
│                                     │
│  Reason (required):                 │
│  ┌───────────────────────────────┐  │
│  │ Invalid reference number.     │  │
│  │ Payment not found in ZAAD     │  │
│  │ system. Please verify and     │  │
│  │ resubmit with correct ref.    │  │
│  └───────────────────────────────┘  │
│                                     │
│  Actions on rejection:              │
│  ☑ Send notification to user        │
│  ☑ Include reason in notification   │
│  ☑ Log in audit trail               │
│                                     │
│  [Cancel] [Confirm Rejection]       │
│                                     │
└─────────────────────────────────────┘
```

### Payment History Tab

```
┌─────────────────────────────────────┐
│  [←]  Payment Management            │
├─────────────────────────────────────┤
│  [Pending] [History]                │
├─────────────────────────────────────┤
│                                     │
│  [Filters ▼]        [Export 📥]     │
│                                     │
│  ━━━━━━ TODAY ━━━━━━               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Ahmad Mohamed          │   │
│  │ 50,000 | ZAAD               │   │
│  │ ✓ APPROVED                  │   │
│  │                             │   │
│  │ Reviewed by: You            │   │
│  │ Reviewed: 10 minutes ago    │   │
│  │ Note: Verified via ZAAD     │   │
│  │                             │   │
│  │ [View Details] [Receipt]    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━ YESTERDAY ━━━━━━           │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Fatima Ali             │   │
│  │ 100,000 | eDahab            │   │
│  │ ✓ APPROVED                  │   │
│  │                             │   │
│  │ Reviewed by: Cashier Amina  │   │
│  │ Reviewed: Oct 21, 3:00 PM   │   │
│  │ Note: Full payment          │   │
│  │                             │   │
│  │ [View Details] [Receipt]    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ [👤] Omar Hassan            │   │
│  │ 75,000 | ZAAD               │   │
│  │ ✗ REJECTED                  │   │
│  │                             │   │
│  │ Reviewed by: You            │   │
│  │ Reviewed: Oct 21, 11:00 AM  │   │
│  │ Note: Invalid reference     │   │
│  │                             │   │
│  │ [View Details]              │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Pending Payments Tab
- **Search Bar**: Filter by user name, email, or reference number
- **Filters Dropdown**: Status, payment method, date range, amount range
- **Export Button**: Download as Excel/PDF
- **Payment Cards**: Display pending submissions
  - User profile photo
  - User name with membership badge
  - Amount submitted
  - Payment method
  - Reference number
  - Current user balance (before payment)
  - Submission timestamp
  - Warning icon if > 24 hours old
  - View Details button
  - Approve/Reject buttons

#### Payment Details Modal
- **User Information Section**:
  - Name, email, phone
  - Membership status
- **Payment Details Section**:
  - Amount
  - Payment method
  - Reference number
  - Payment type (Full/Partial)
  - Submission timestamp
- **Balance Information**:
  - Current balance
  - Balance after payment
  - Penalty breakdown (FIFO order)
- **Payment Distribution Preview**:
  - Shows which penalties will be paid
  - Calculation breakdown
  - New balance after application
- **Action Buttons**:
  - Approve Payment (green)
  - Reject Payment (red)

#### Approval/Rejection Dialogs
- **Confirmation Summary**: Payment details
- **Notes Field**:
  - Optional for approval
  - Required for rejection
- **Action Checkboxes**: What will happen
- **Confirm Button**: Execute action

#### Payment History Tab
- **Filters**: Status, cashier, date range, user, method
- **History Cards**:
  - User info
  - Amount and method
  - Status badge (✓ Approved / ✗ Rejected)
  - Reviewer name
  - Review timestamp
  - Reviewer notes
  - View Details button
  - Receipt button (if approved)
- **Export Options**: Excel or PDF

---

## User Balance Management

Direct balance management and manual adjustments for users.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  User Balance Management       │
├─────────────────────────────────────┤
│                                     │
│  🔍 USER SEARCH                     │
│  ┌───────────────────────────────┐  │
│  │ Search by name, email, phone  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Recent Searches:                   │
│  • Ahmad Mohamed                    │
│  • Fatima Ali                       │
│  • Omar Hassan                      │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  👥 USERS WITH HIGH BALANCE         │
│  (Balance > 300,000)                │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Omar Hassan                 │   │
│  │ Balance: 450,000 ⚠️         │   │
│  │ [Manage →]                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Khadija Nur                 │   │
│  │ Balance: 380,000 ⚠️         │   │
│  │ [Manage →]                  │   │
│  └─────────────────────────────┘   │
│                                     │
│  [View All Users →]                 │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [👥] [⚙️]         │
└─────────────────────────────────────┘
```

### User Balance Detail Screen

```
┌─────────────────────────────────────┐
│  [←]  Ahmad Mohamed - Balance       │
├─────────────────────────────────────┤
│                                     │
│  👤 USER INFO                       │
│  [Profile Photo]                    │
│  Ahmad Mohamed                      │
│  💎 Exclusive Member                │
│  ahmad@example.com                  │
│  Member since: Jan 15, 2025         │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💰 CURRENT BALANCE                 │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │      150,000 Shillings      │   │
│  │                             │   │
│  │  Last updated: 2 hours ago  │   │
│  └─────────────────────────────┘   │
│                                     │
│  📋 UNPAID PENALTIES (FIFO)         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 10, 2025                │   │
│  │ 25,000 shillings            │   │
│  │ Missing: 5 deeds            │   │
│  │ [View Report →]             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 12, 2025                │   │
│  │ 25,000 shillings            │   │
│  │ Missing: 5 deeds            │   │
│  │ [View Report →]             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 15, 2025                │   │
│  │ 30,000 shillings            │   │
│  │ Missing: 6 deeds            │   │
│  │ [View Report →]             │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Show More...]                     │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ⚙️ MANUAL BALANCE ADJUSTMENT       │
│                                     │
│  Action Type:                       │
│  ● Clear Penalty                    │
│  ○ Add Penalty                      │
│  ○ Adjust Balance                   │
│                                     │
│  Amount (Shillings):                │
│  ┌───────────────────────────────┐  │
│  │ 50,000                        │  │
│  └───────────────────────────────┘  │
│                                     │
│  Payment Method:                    │
│  [ZAAD ▼]                           │
│                                     │
│  Reason/Notes (required):           │
│  ┌───────────────────────────────┐  │
│  │ Cash payment received in      │  │
│  │ person. Receipt #12345        │  │
│  └───────────────────────────────┘  │
│                                     │
│  Preview:                           │
│  Current: 150,000                   │
│  Adjustment: -50,000                │
│  New Balance: 100,000               │
│                                     │
│  [Cancel] [Confirm Adjustment]      │
│                                     │
└─────────────────────────────────────┘
```

### Adjustment Confirmation Dialog

```
┌─────────────────────────────────────┐
│  Confirm Balance Adjustment         │
├─────────────────────────────────────┤
│                                     │
│  User: Ahmad Mohamed                │
│  Action: Clear Penalty              │
│  Amount: 50,000 Shillings           │
│  Method: ZAAD                       │
│                                     │
│  Current Balance: 150,000           │
│  New Balance: 100,000               │
│                                     │
│  Reason:                            │
│  "Cash payment received in person.  │
│   Receipt #12345"                   │
│                                     │
│  ⚠️ This action will:               │
│  • Apply 50,000 to oldest penalties │
│  • Update user balance immediately  │
│  • Send notification to user        │
│  • Create audit log entry           │
│  • Generate receipt                 │
│                                     │
│  This action cannot be undone.      │
│                                     │
│  [Cancel] [Confirm]                 │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### User Search Section
- **Search Bar**: Type-ahead search
  - Search by name
  - Search by email
  - Search by phone number
- **Recent Searches**: Quick access to previously viewed users
- **High Balance Alert**: Users approaching deactivation threshold
  - Shows users with balance > 300,000
  - Warning icon
  - Quick manage button

#### User Balance Detail
- **User Info Card**:
  - Profile photo
  - Name and membership
  - Contact information
  - Member since date
- **Current Balance Display**:
  - Large prominent number
  - Last updated timestamp
  - Color coded by severity
- **Unpaid Penalties List**:
  - FIFO ordered (oldest first)
  - Date incurred
  - Penalty amount
  - Number of missing deeds
  - Link to related report
  - Paginated (show more button)

#### Manual Adjustment Form
- **Action Type Radio Buttons**:
  - Clear Penalty: Reduce balance (payment received)
  - Add Penalty: Increase balance (manual penalty)
  - Adjust Balance: Direct modification (correction)
- **Amount Input**: Numeric field
  - Validation: Must be > 0
  - For "Clear": Cannot exceed current balance
- **Payment Method Dropdown**: How payment was received
  - ZAAD
  - eDahab
  - Cash
  - Bank Transfer
  - Other
- **Reason Field**: Required text area
  - Minimum 10 characters
  - Explain why adjustment needed
- **Preview Section**: Shows calculation
  - Current balance
  - Adjustment amount (+ or -)
  - Resulting new balance
- **Action Buttons**:
  - Cancel: Discard changes
  - Confirm: Execute adjustment

#### Confirmation Dialog
- **Summary**: All adjustment details
- **Impact Warning**: What will happen
- **Irreversible Notice**: Warning about permanence
- **Confirm Button**: Final approval

---

## Payment Analytics

Overview of payment trends and financial metrics.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Payment Analytics             │
│                                     │
│  [This Week] [This Month] [Custom]  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  💰 OVERVIEW - THIS MONTH           │
│                                     │
│  ┌──────────┬──────────┬────────┐  │
│  │  Total   │ Pending  │  Avg   │  │
│  │Received  │ Review   │ Amount │  │
│  │1,800,000 │ 450,000  │75,000  │  │
│  └──────────┴──────────┴────────┘  │
│                                     │
│  ┌──────────┬──────────────────┐   │
│  │Approved  │    Rejected      │   │
│  │  142     │       8          │   │
│  │  95%     │      5%          │   │
│  └──────────┴──────────────────┘   │
│                                     │
│  📈 PAYMENT TRENDS                  │
│  ┌─────────────────────────────┐   │
│  │   Monthly Payments          │   │
│  │                             │   │
│  │ 2M │           ╱█           │   │
│  │    │         ╱█ █           │   │
│  │ 1M │       ╱█  █  █         │   │
│  │    │     ╱█   █  █  █       │   │
│  │  0 └─────────────────────   │   │
│  │     Jun Jul Aug Sep Oct     │   │
│  └─────────────────────────────┘   │
│                                     │
│  💳 PAYMENT METHOD DISTRIBUTION     │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │    ┌───────┐                │   │
│  │    │ ZAAD  │  65%           │   │
│  │    │ 65%   │                │   │
│  │    └───────┘                │   │
│  │  ┌────┐                     │   │
│  │  │eDa │ 28%                 │   │
│  │  │28% │                     │   │
│  │  └────┘                     │   │
│  │ ┌─┐                         │   │
│  │ │C│ 7%                      │   │
│  │ └─┘                         │   │
│  │                             │   │
│  │ ZAAD: 65% | eDahab: 28%     │   │
│  │ Cash: 7%                    │   │
│  └─────────────────────────────┘   │
│                                     │
│  👥 TOP PAYING USERS                │
│  ┌─────────────────────────────┐   │
│  │ 1. Ahmad Mohamed - 200,000  │   │
│  │ 2. Fatima Ali - 150,000     │   │
│  │ 3. Omar Hassan - 125,000    │   │
│  │ 4. Khadija Nur - 100,000    │   │
│  │ 5. Maryam Abdi - 95,000     │   │
│  └─────────────────────────────┘   │
│                                     │
│  💵 OUTSTANDING BALANCES            │
│  Total: 7,000,000 shillings         │
│  Users with balance: 89/150 (59%)   │
│  Avg balance per user: 78,651       │
│                                     │
│  [Export Report 📥]                 │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [👥] [⚙️]         │
└─────────────────────────────────────┘
```

### UI Elements

#### Time Period Selector
- **Tabs**: This Week, This Month, Custom Range
- **Custom Range Picker**: Start and end date selection

#### Overview Cards
- **Total Received**: Sum of approved payments in period
- **Pending Review**: Sum of payments awaiting approval
- **Average Amount**: Mean payment amount
- **Approval Rate**: Percentage approved vs rejected
  - Approved count and percentage
  - Rejected count and percentage
- **Large Numbers**: Prominent display with labels

#### Payment Trends Chart
- **Line/Bar Graph**: Payments over time
- **X-Axis**: Time period (days/weeks/months)
- **Y-Axis**: Amount in shillings
- **Interactive**: Tap bars for details
- **Trend Indicator**: Up/down arrows

#### Payment Method Distribution
- **Pie Chart**: Visual breakdown
- **Legend**: Method names with percentages
- **Colors**: Distinct per method
  - ZAAD: Blue
  - eDahab: Green
  - Cash: Orange
  - Other: Gray

#### Top Paying Users
- **Ranked List**: Top 5 users by total payments
- **Rank Number**: Position
- **User Name**: Full name
- **Total Amount**: Sum of approved payments
- **Tap Action**: Navigate to user balance detail

#### Outstanding Balances Summary
- **Total Outstanding**: Sum of all user balances
- **User Count**: How many users have balance > 0
- **Average Balance**: Mean balance across users with debt
- **Trend Indicators**: Month-over-month change

#### Export Button
- **PDF**: Visual charts and summary
- **Excel**: Detailed payment records
  - User names
  - Payment amounts
  - Methods
  - Dates
  - Cashier names
  - Status

---

## Bottom Navigation

Cashiers have an extended navigation bar:

```
┌─────────────────────────────────────┐
│  [🏠] [📊] [💰] [👥] [⚙️]         │
│  Home Reports Payment Users Settings
└─────────────────────────────────────┘
```

- **🏠 Home**: Cashier dashboard (same as normal user)
- **📊 Reports**: Personal reports (same as normal user)
- **💰 Payment**: Payment review dashboard
- **👥 Users**: User balance management
- **⚙️ Settings**: Settings (with cashier options)

---

## Workflows

### Payment Approval Workflow

```
1. User submits payment via mobile app
   ↓
2. Payment appears in Cashier's Pending tab
   ↓
3. Cashier reviews payment details
   ↓
4. Cashier verifies payment via payment system
   ↓
5. Cashier approves with optional notes
   ↓
6. System applies payment to user balance (FIFO)
   ↓
7. System generates receipt
   ↓
8. System sends confirmation to user
   ↓
9. Audit log entry created
```

### Payment Rejection Workflow

```
1. Cashier identifies invalid payment
   ↓
2. Cashier clicks Reject button
   ↓
3. Cashier enters required rejection reason
   ↓
4. Cashier confirms rejection
   ↓
5. System sends notification to user with reason
   ↓
6. User can resubmit with corrections
   ↓
7. Audit log entry created
```

### Manual Balance Adjustment Workflow

```
1. Cashier searches for user
   ↓
2. Cashier views user balance details
   ↓
3. Cashier selects adjustment type
   ↓
4. Cashier enters amount and reason
   ↓
5. System shows preview of changes
   ↓
6. Cashier confirms adjustment
   ↓
7. System updates balance
   ↓
8. System generates receipt
   ↓
9. System notifies user
   ↓
10. Audit log entry created
```

---

## Security & Audit

All cashier actions are logged in the audit trail:

- **Payment Approvals**: Who, when, amount, user
- **Payment Rejections**: Who, when, reason, user
- **Balance Adjustments**: Who, when, type, amount, reason, user
- **User Lookups**: Who searched for which users
- **Bulk Operations**: Any batch actions performed

Cashiers cannot:
- Edit their own balance
- Delete payment records
- Modify approved payments
- Access admin-level settings
- Approve/reject without required notes

---

## Related Documentation

- [Normal User Screens](./02-user-screens.md)
- [Supervisor Screens](./03-supervisor-screens.md)
- [Admin Screens](./05-admin-screens.md)
- [Authentication Screens](./01-authentication.md)
- [Payment System](../features/)

---

*Last Updated: 2025-10-22*
