# Normal User Screens

This document outlines all screens and interfaces available to normal users (non-admin roles) in the Sabiquun application.

---

## Home Screen

The main dashboard that users see after login. Provides at-a-glance view of their deed tracking progress.

### UI Layout

```
┌─────────────────────────────────────┐
│  [👤]  Ahmad Mohamed       [🔔 3]   │
│        Exclusive Member             │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │    Penalty Balance          │   │
│  │                             │   │
│  │     150,000 Shillings       │   │
│  │     ───────────────         │   │
│  │                             │   │
│  │  [💰 Pay Now]               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │    Today's Progress         │   │
│  │                             │   │
│  │        ╭───────╮            │   │
│  │        │  7.5  │            │   │
│  │        │  /10  │            │   │
│  │        ╰───────╯            │   │
│  │                             │   │
│  │  5/5 Fara'id | 2.5/5 Sunnah│   │
│  │                             │   │
│  │  ⏰ Grace period ends in 3h │   │
│  │                             │   │
│  │  [📝 Submit Report]         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 Recent Reports                  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 21  8.5/10  ✓ Submitted │   │
│  │         Penalty: 7,500       │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Oct 20  10/10   ✓ Submitted │   │
│  │         No Penalty           │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Oct 19  6/10    ✓ Submitted │   │
│  │         Penalty: 20,000      │   │
│  └─────────────────────────────┘   │
│                                     │
│  [View All Reports →]               │
│                                     │
│  🏆 Special Achievements            │
│  ┌─────────────────────────────┐   │
│  │  🌅 Fajr Champion           │   │
│  │  30-day streak!             │   │
│  └─────────────────────────────┘   │
│                                     │
│                        [➕]         │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### UI Elements

#### Header Section
- **Profile Photo**: Circular avatar (tap to view profile)
- **User Name**: Display name with membership badge
- **Membership Badge**: Visual indicator (New/Exclusive/Legacy)
- **Notification Bell**: Icon with unread count badge
  - Tap to view notification list

#### Penalty Balance Card
- **Balance Display**: Large, prominent number
- **Color Coding**:
  - Green: 0 - 100,000 shillings
  - Yellow: 100,001 - 300,000 shillings
  - Red: 300,000+ shillings
- **Pay Now Button**: Quick access to payment screen
  - Shows only if balance > 0

#### Today's Progress Card
- **Circular Progress Indicator**: Visual representation of deed completion
  - Shows current/target (e.g., "7.5/10")
  - Animated fill
- **Category Breakdown**:
  - Fara'id count: "5/5" with checkmark/cross
  - Sunnah count: "2.5/5" with checkmark/cross
- **Grace Period Timer**: Countdown if applicable
  - Shows only if report not submitted and within grace period
  - Updates in real-time
- **Action Button**:
  - "Submit Report" if not submitted today
  - "View Report" if already submitted (non-editable)

#### Recent Reports Section
- **Section Title**: "Last 5 Reports"
- **Report Cards**: List of 5 most recent submissions
  - Date
  - Total deeds with ratio (e.g., "8.5/10")
  - Status badge: "Submitted" or "Draft"
  - Penalty amount (if any)
  - Tap card to view full details
- **View All Button**: Navigate to complete reports list

#### Special Achievements Section
- **Achievement Badges**: Display earned tags
  - "Fajr Champion" (90%+ Fajr completion for 30 days)
  - Other custom achievements
- **Description**: Brief explanation of achievement
- **Conditional Display**: Shows only if user has achievements

#### Floating Action Button (FAB)
- **Large Plus Button**: Primary action
- **Position**: Bottom-right corner
- **Action**: Opens Report Submission screen

#### Bottom Navigation Bar
- **Home**: Current screen
- **Reports**: Navigate to reports list
- **Payment**: Navigate to payment screen
- **Settings**: Navigate to settings

---

## Report Submission Screen

Allows users to submit daily deed reports with real-time feedback.

### UI Layout

```
┌─────────────────────────────────────┐
│  [✕]  Submit Report    [Save Draft] │
│                                     │
│  📅 Date: Oct 22, 2025       [▼]   │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🕌 FARA'ID (Required)              │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Fajr                      │   │
│  │ 🌅 Dawn Prayer              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Dhuhr                     │   │
│  │ ☀️ Noon Prayer               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Asr                       │   │
│  │ 🌤️ Afternoon Prayer         │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☑ Maghrib                   │   │
│  │ 🌅 Sunset Prayer            │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☐ Isha                      │   │
│  │ 🌙 Night Prayer             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📖 SUNNAH (Recommended)            │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Night Prayer (Qiyam)        │   │
│  │ ━━━━━━━━━━━━━━━━○─ 0.8     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Duha Prayer                 │   │
│  │ ━━━━○━━━━━━━━━━━ 0.3       │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Fasting                     │   │
│  │ ━━━━━━━━━━━━━━━━━━ 1.0     │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │    📊 Summary               │   │
│  │                             │   │
│  │  Total: 7.5/10 deeds        │   │
│  │  Fara'id: 4/5 ❌            │   │
│  │  Sunnah: 2.1/5 ❌           │   │
│  │                             │   │
│  │  Missing: 2.5 deeds         │   │
│  │  Penalty: 12,500 shillings  │   │
│  │                             │   │
│  │  [███████░░░] 75%           │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Save as Draft] [Submit Report]   │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Header
- **Close Button**: Exit without saving (with confirmation if changes made)
- **Date Selector**: Dropdown calendar picker
  - Default: Today
  - Can select past dates (if enabled by settings)
  - Cannot select future dates
- **Save Draft Button**: Persist progress without submitting

#### Deed List Section

**Fara'id Deeds (Binary - Complete/Incomplete)**
- Checkbox toggle for each deed
- Deed name with icon
- Description text
- Visual grouping under "FARA'ID" header

**Sunnah Deeds (Fractional - 0.0 to 1.0)**
- Deed name
- Horizontal slider
  - Range: 0.0 to 1.0
  - Step: 0.1
  - Numeric display shows current value
  - Draggable handle
- Real-time value update

#### Real-Time Summary Card (Bottom Sheet)
- **Total Deeds**: Current/Target with ratio
- **Category Breakdown**:
  - Fara'id: Count with checkmark (green) or cross (red)
  - Sunnah: Count with checkmark (green) or cross (red)
- **Missing Deeds**: Calculated difference from target
- **Penalty Preview**: Calculated amount if submitted now
  - Formula: Missing deeds × Penalty per deed
  - Only shown if penalty would apply
- **Progress Bar**: Visual completion percentage
  - Color-coded by completion level

#### Action Buttons
- **Save as Draft**: Secondary button (outline style)
  - Saves current state
  - Can be resumed later
  - Shows toast confirmation
- **Submit Report**: Primary button (filled style)
  - Opens confirmation dialog
  - Dialog message: "Submit report for {date}? You cannot edit after submission."
  - Dialog actions: Cancel, Confirm

### Validation Rules

- At least one deed must have a value
- Date cannot be in the future
- Cannot submit duplicate report for same date
- Grace period check applies after deadline

### User Flow

1. User taps FAB or "Submit Report" button
2. Screen opens with today's date pre-selected
3. User toggles/adjusts deed values
4. Summary updates in real-time
5. User clicks "Submit Report"
6. Confirmation dialog appears
7. On confirm: Report saved, navigate to Home
8. Show success toast with summary

---

## Reports Screen

View and manage all submitted reports with filtering and export options.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  My Reports        [🔍] [📥]  │
├─────────────────────────────────────┤
│                                     │
│  [Filters ▼]                        │
│                                     │
│  ━━━━━━ OCTOBER 2025 ━━━━━━        │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 22, 2025                │   │
│  │ [███████░░░] 7.5/10         │   │
│  │ 4/5 Fara'id | 2.5/5 Sunnah  │   │
│  │ Penalty: 12,500 shillings   │   │
│  │ ✓ Submitted                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 21, 2025                │   │
│  │ [████████░░] 8.5/10         │   │
│  │ 5/5 Fara'id | 3.5/5 Sunnah  │   │
│  │ Penalty: 7,500 shillings    │   │
│  │ ✓ Submitted                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 20, 2025                │   │
│  │ [██████████] 10/10          │   │
│  │ 5/5 Fara'id | 5/5 Sunnah    │   │
│  │ No Penalty ✓                │   │
│  │ ✓ Submitted                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━ SEPTEMBER 2025 ━━━━━━      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Sep 30, 2025                │   │
│  │ [██████░░░░] 6/10           │   │
│  │ 3/5 Fara'id | 3/5 Sunnah    │   │
│  │ Penalty: 20,000 shillings   │   │
│  │ ✓ Submitted                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Load More...]                     │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### Filter Drawer

```
┌─────────────────────────────────────┐
│  Filters                      [✕]   │
├─────────────────────────────────────┤
│                                     │
│  Date Range                         │
│  ┌─────────────┬─────────────┐     │
│  │ Start Date  │  End Date   │     │
│  │ [Select...] │ [Select...] │     │
│  └─────────────┴─────────────┘     │
│                                     │
│  Status                             │
│  ○ All                              │
│  ○ Submitted                        │
│  ○ Draft                            │
│                                     │
│  Penalty                            │
│  ○ All                              │
│  ○ With Penalty                     │
│  ○ No Penalty                       │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  [Clear Filters] [Apply]            │
│                                     │
└─────────────────────────────────────┘
```

### Report Details Sheet

```
┌─────────────────────────────────────┐
│  Oct 22, 2025              [✕]      │
│  Submitted at 11:45 PM              │
├─────────────────────────────────────┤
│                                     │
│  🕌 FARA'ID                         │
│  ✓ Fajr              1.0            │
│  ✓ Dhuhr             1.0            │
│  ✓ Asr               1.0            │
│  ✓ Maghrib           1.0            │
│  ✗ Isha              0.0            │
│  ─────────────────────────          │
│  Total: 4/5                         │
│                                     │
│  📖 SUNNAH                          │
│  Night Prayer         0.8           │
│  Duha Prayer          0.3           │
│  Fasting              1.0           │
│  Rawatib              0.0           │
│  Witr                 0.0           │
│  ─────────────────────────          │
│  Total: 2.1/5                       │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 SUMMARY                         │
│  Total Deeds: 6.1/10                │
│  Missing: 3.9 deeds                 │
│                                     │
│  💰 PENALTY CALCULATION             │
│  Missing deeds: 3.9                 │
│  × Rate: 5,000 shillings            │
│  = 19,500 shillings                 │
│                                     │
│  [Close]                            │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Header
- **Back Button**: Return to home
- **Title**: "My Reports"
- **Search Icon**: Quick search by date
- **Export Icon**: Download reports as PDF/Excel

#### Filter Section
- **Filter Dropdown**: Opens filter drawer
- **Active Filters**: Shows chips for applied filters
- **Clear All**: Quick reset

#### Reports List
- **Month Groupings**: Reports grouped by month header
- **Report Cards**: Each card displays:
  - Date
  - Progress bar with ratio
  - Category breakdown
  - Penalty amount or "No Penalty"
  - Status badge
- **Tap Action**: Opens detailed bottom sheet
- **Load More**: Pagination for older reports

#### Report Details Bottom Sheet
- **Header**: Date and submission timestamp
- **Deed Breakdown**: Complete list with values
  - Fara'id section with totals
  - Sunnah section with totals
- **Summary Section**: Overall statistics
- **Penalty Calculation**: Detailed breakdown
  - Formula shown
  - Per-deed rate displayed
- **Admin Actions**: (Only visible to admins)
  - Edit button
  - Delete button

### Export Options

When user taps export icon:
- **Format Selection**: PDF or Excel
- **Date Range**: Custom or predefined (This Month, Last Month, All Time)
- **Include**: Penalty details checkbox
- **Generate Button**: Creates and downloads file

---

## Deed Breakdown Screen

Analytics view showing individual deed performance over time.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Deed Analytics                │
│                                     │
│  Date Range: [This Month ▼]        │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  🕌 FARA'ID DEEDS                   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌅 Fajr                     │   │
│  │ 28/30 days - 93%            │   │
│  │ [█████████░] ↗ Improving   │   │
│  │                             │   │
│  │ [View Calendar →]           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ☀️ Dhuhr                     │   │
│  │ 30/30 days - 100%           │   │
│  │ [██████████] ✓ Perfect!     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌤️ Asr                      │   │
│  │ 27/30 days - 90%            │   │
│  │ [█████████░] ─ Stable       │   │
│  └─────────────────────────────┘   │
│                                     │
│  📖 SUNNAH DEEDS                    │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌙 Night Prayer (Qiyam)     │   │
│  │ Average: 0.72/1.0           │   │
│  │ [███████░░░] ↗ Improving    │   │
│  │ Best: 0.9 | Worst: 0.4      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌅 Duha Prayer              │   │
│  │ Average: 0.45/1.0           │   │
│  │ [████░░░░░░] ↘ Declining    │   │
│  │ Best: 0.8 | Worst: 0.1      │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📊 CATEGORY SUMMARY                │
│                                     │
│  Fara'id Compliance: 92%            │
│  [█████████░] 138/150 deeds         │
│                                     │
│  Sunnah Compliance: 78%             │
│  [███████░░░] 117/150 deeds         │
│                                     │
│  [View Charts →]                    │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### Heatmap Calendar View

```
┌─────────────────────────────────────┐
│  [←]  Fajr Prayer - October 2025   │
├─────────────────────────────────────┤
│                                     │
│  S  M  T  W  T  F  S                │
│           1  2  3  4  5             │
│  🟢 🟢 🟢 🟢 🟢 🟢 🟢              │
│                                     │
│  6  7  8  9  10 11 12               │
│  🟢 🟢 🔴 🟢 🟢 🟢 🟢              │
│                                     │
│  13 14 15 16 17 18 19               │
│  🟢 🟢 🟢 🟢 🔴 🟢 🟢              │
│                                     │
│  20 21 22 23 24 25 26               │
│  🟢 🟢 🟢 🟡 🟡 🟡 🟢              │
│                                     │
│  27 28 29 30 31                     │
│  🟢 🟢 🟢 🟢 🟢                    │
│                                     │
│  🟢 Completed  🔴 Missed            │
│  🟡 No data    ⚪ Rest day          │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

#### Header
- **Back Button**: Return to previous screen
- **Title**: "Deed Analytics"
- **Date Range Selector**: Dropdown with options
  - This Week
  - This Month
  - Last Month
  - Last 3 Months
  - All Time

#### Individual Deed Cards

**Binary Deeds (Fara'id)**
- Deed name with icon
- Completion ratio: "28/30 days"
- Percentage: "93%"
- Progress bar
- Trend indicator:
  - ↗ Improving (green)
  - ─ Stable (blue)
  - ↘ Declining (red)
- "View Calendar" link: Opens heatmap

**Fractional Deeds (Sunnah)**
- Deed name with icon
- Average value: "0.72/1.0"
- Progress bar
- Trend indicator
- Best and worst values in period

#### Category Summary Section
- **Fara'id Compliance**: Percentage and count
- **Sunnah Compliance**: Percentage and count
- **Progress Bars**: Visual representation
- **View Charts Link**: Opens detailed analytics

#### Heatmap Calendar
- Monthly grid layout
- Color-coded dates:
  - Green: Deed completed
  - Red: Deed missed
  - Yellow: No data/not submitted
  - White: Rest day (no penalty)
- Legend at bottom
- Swipe to change months

---

## Payment Screen

Manage penalty balance and submit payment records.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Payments                      │
├─────────────────────────────────────┤
│  [Submit Payment] [Payment History] │
├─────────────────────────────────────┤
│                                     │
│  💰 CURRENT BALANCE                 │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │    150,000 Shillings        │   │
│  │                             │   │
│  │ Last updated: 2 hours ago   │   │
│  └─────────────────────────────┘   │
│                                     │
│  📋 PENALTY BREAKDOWN               │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 15, 2025                │   │
│  │ 25,000 shillings            │   │
│  │ [View Report →]             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 18, 2025                │   │
│  │ 30,000 shillings            │   │
│  │ [View Report →]             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ⚠️ Oldest penalties paid first    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  💳 PAYMENT SUBMISSION              │
│                                     │
│  Payment Method                     │
│  [ZAAD ▼]                           │
│                                     │
│  Payment Type                       │
│  ● Full Payment (150,000)           │
│  ○ Partial Payment                  │
│                                     │
│  Amount (optional)                  │
│  ┌─────────────────────────────┐   │
│  │ 150,000                     │   │
│  └─────────────────────────────┘   │
│                                     │
│  Reference Number (optional)        │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Submit Payment]                   │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### Payment History Tab

```
┌─────────────────────────────────────┐
│  [←]  Payments                      │
├─────────────────────────────────────┤
│  [Submit Payment] [Payment History] │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 20, 2025  11:30 AM      │   │
│  │ 50,000 shillings            │   │
│  │ ZAAD                        │   │
│  │ Ref: ZD1234567890           │   │
│  │ ⏳ Pending Review           │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 10, 2025  3:15 PM       │   │
│  │ 100,000 shillings           │   │
│  │ eDahab                      │   │
│  │ Ref: ED9876543210           │   │
│  │ ✓ Approved                  │   │
│  │ [Download Receipt]          │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Sep 25, 2025  8:00 PM       │   │
│  │ 75,000 shillings            │   │
│  │ ZAAD                        │   │
│  │ Ref: ZD1122334455           │   │
│  │ ✗ Rejected                  │   │
│  │ Reason: Invalid reference   │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### UI Elements

#### Current Balance Card
- **Large Balance Display**: Prominent amount
- **Last Updated**: Timestamp of last calculation
- **Color Coding**: Matches home screen logic

#### Penalty Breakdown Section
- **List of Unpaid Penalties**: Ordered by date (FIFO)
  - Date incurred
  - Amount
  - Link to related report
- **FIFO Notice**: Information about payment application order

#### Payment Form
- **Payment Method Dropdown**: List of available methods
  - ZAAD
  - eDahab
  - Other configured methods
- **Payment Type Radio Buttons**:
  - Full Payment: Pre-filled with total balance
  - Partial Payment: User enters custom amount
- **Amount Input**:
  - Automatically filled for full payment
  - Editable for partial payment
  - Validation: Must be > 0 and ≤ balance
- **Reference Number**: Optional text input
- **Submit Button**: Primary action

#### Payment History Tab
- **Payment Cards**: List of all submissions
  - Date and time
  - Amount
  - Payment method
  - Reference number
  - Status badge:
    - ⏳ Pending (yellow)
    - ✓ Approved (green)
    - ✗ Rejected (red)
  - Rejection reason (if applicable)
  - Download receipt button (if approved)

### User Flow

1. User views current balance
2. User reviews penalty breakdown
3. User selects payment method
4. User chooses full or partial payment
5. User enters reference number (optional)
6. User clicks "Submit Payment"
7. Confirmation dialog appears
8. System creates pending payment record
9. Cashier reviews and approves/rejects
10. User receives notification of status

---

## Excuse Screen

Submit and manage excuse requests to waive penalties.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Excuse Management             │
├─────────────────────────────────────┤
│  [Submit Excuse] [Excuse History]   │
├─────────────────────────────────────┤
│                                     │
│  🛡️ EXCUSE MODE                    │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │  Currently: OFF      [⚪→]  │   │
│  │                             │   │
│  │  When enabled, automatic    │   │
│  │  penalties will be waived   │   │
│  │  until you turn it off or   │   │
│  │  submit an excuse request   │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📝 SUBMIT EXCUSE REQUEST           │
│                                     │
│  Date                               │
│  [Oct 22, 2025 ▼]                   │
│                                     │
│  Excuse Type                        │
│  [Sickness ▼]                       │
│  • Sickness                         │
│  • Travel                           │
│  • Raining                          │
│  • Other                            │
│                                     │
│  Affected Deeds                     │
│  ☑ All deeds                        │
│  ────────────────────                │
│  ☐ Fajr                             │
│  ☐ Dhuhr                            │
│  ☐ Asr                              │
│  ☐ Maghrib                          │
│  ☐ Isha                             │
│  ☐ Night Prayer                     │
│  [Show more...]                     │
│                                     │
│  Description (optional)             │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │                             │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  [Submit Excuse Request]            │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### Excuse History Tab

```
┌─────────────────────────────────────┐
│  [←]  Excuse Management             │
├─────────────────────────────────────┤
│  [Submit Excuse] [Excuse History]   │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 20, 2025                │   │
│  │ Type: Sickness              │   │
│  │ Deeds: All deeds            │   │
│  │ ⏳ Pending                  │   │
│  │ Submitted: Oct 20, 9:30 AM  │   │
│  │                             │   │
│  │ [View Details →]            │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 15, 2025                │   │
│  │ Type: Travel                │   │
│  │ Deeds: Fajr, Dhuhr          │   │
│  │ ✓ Approved                  │   │
│  │ Reviewed by: Ahmad (Admin)  │   │
│  │ Reviewed: Oct 15, 11:00 AM  │   │
│  │                             │   │
│  │ Note: Approved for business │   │
│  │ travel. Safe journey!       │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Oct 8, 2025                 │   │
│  │ Type: Raining               │   │
│  │ Deeds: Fajr                 │   │
│  │ ✗ Rejected                  │   │
│  │ Reviewed by: Fatima (Supvr) │   │
│  │ Reviewed: Oct 8, 2:00 PM    │   │
│  │                             │   │
│  │ Note: Weather records show  │   │
│  │ no rain on this date        │   │
│  └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### UI Elements

#### Excuse Mode Toggle
- **Large Toggle Switch**: Enable/disable excuse mode
- **Status Indicator**: "Currently: ON/OFF"
- **Explanation Text**: Clear description of functionality
- **Behavior**:
  - When ON: Prevents automatic penalty calculation
  - User must still submit formal excuse request
  - Supervisor approves/rejects excuse
  - If rejected, penalties retroactively applied

#### Submit Excuse Form
- **Date Selector**: Calendar picker
  - Can select past dates
  - Cannot select dates already excused
- **Excuse Type Dropdown**: Predefined categories
  - Sickness
  - Travel
  - Raining
  - Other
- **Deed Selector**: Multi-select with "All" option
  - Checkbox for "All deeds"
  - Individual checkboxes for each deed
  - "All" checkbox toggles others
- **Description Text Area**: Optional additional context
- **Submit Button**: Primary action

#### Excuse History List
- **Excuse Cards**: Display all past excuses
  - Date
  - Excuse type
  - Affected deeds (or "All deeds")
  - Status badge:
    - ⏳ Pending (yellow)
    - ✓ Approved (green)
    - ✗ Rejected (red)
  - Reviewer name and role
  - Review timestamp
  - Reviewer notes/comments
- **Tap Action**: Expand for full details

### Validation Rules

- Date cannot be in future
- Must select at least one deed (or "All")
- Excuse type required
- Cannot submit duplicate excuse for same date

### User Flow

1. User encounters situation requiring excuse
2. User enables Excuse Mode (optional, for prevention)
3. User submits formal excuse request with details
4. Supervisor receives notification
5. Supervisor approves or rejects with notes
6. User receives notification of decision
7. If approved: Penalties waived for specified deeds
8. If rejected: Penalties applied (if not already paid)

---

## Settings Screen

User profile and application configuration.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Settings                      │
├─────────────────────────────────────┤
│                                     │
│  👤 PROFILE                         │
│                                     │
│  ┌─────────────────────────────┐   │
│  │     [Profile Photo]         │   │
│  │     Tap to change           │   │
│  │                             │   │
│  │  Ahmad Mohamed              │   │
│  │  ahmad@example.com ✓        │   │
│  │  +252 61 123 4567           │   │
│  │  🏅 Exclusive Member        │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🔐 SECURITY                        │
│                                     │
│  Change Password            [→]    │
│  Active Sessions            [→]    │
│  Logout from All Devices    [→]    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🔔 NOTIFICATIONS                   │
│                                     │
│  Push Notifications      [●─→]     │
│  Email Notifications     [─○→]     │
│  Notification Sound         [→]    │
│  Quiet Hours               [→]     │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  🎨 DISPLAY                         │
│                                     │
│  Language                   [→]    │
│  Theme: System Default      [→]    │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  📚 SUPPORT                         │
│                                     │
│  Rules & Policies           [→]    │
│  Contact Admin              [→]    │
│  About App                  [→]    │
│  Version: 1.0.2 ✓ Up to date      │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  ⚠️ ACCOUNT                        │
│                                     │
│  Delete Account             [→]    │
│                                     │
├─────────────────────────────────────┤
│  [🏠] [📊] [💰] [⚙️]               │
└─────────────────────────────────────┘
```

### UI Elements

#### Profile Section
- **Profile Photo**: Circular avatar
  - Tap to open image picker (camera/gallery)
  - Upload and crop functionality
- **Name**: Editable (tap to edit inline)
- **Email**: Display only with verified badge
- **Phone**: Editable (tap to edit inline)
- **Membership Badge**: Display only, color-coded

#### Security Settings
- **Change Password**: Navigate to password change form
  - Current password
  - New password
  - Confirm new password
- **Active Sessions**: List of logged-in devices
  - Device name/type
  - Last active timestamp
  - IP address
  - "Logout" button per session
- **Logout from All Devices**: Confirmation dialog
  - Invalidates all sessions except current
  - Requires re-login on other devices

#### Notification Settings
- **Push Notifications**: Toggle switch
  - Requires device permission
- **Email Notifications**: Toggle switch
- **Notification Sound**: Dropdown selector
  - Default
  - Silent
  - Custom sounds
- **Quiet Hours**: Time range picker
  - Start time
  - End time
  - Days selector (weekdays/weekends/all)

#### Display Settings
- **Language Selector**: Dropdown (future enhancement)
  - English
  - Somali
  - Arabic
- **Theme Selector**: Radio buttons
  - Light
  - Dark
  - System Default

#### Support Section
- **Rules & Policies**: Navigate to content viewer
- **Contact Admin**: Opens message composer
  - Subject field
  - Message text area
  - Send button
- **About App**: Information screen
  - App version
  - Terms of Service link
  - Privacy Policy link
  - Open source licenses
- **Version**: Display with update status
  - If update available: "Update Available" button

#### Account Section
- **Delete Account**: Destructive action
  - Confirmation dialog with warning
  - Requires password re-entry
  - Explains data deletion
  - Cannot be undone

---

## Rules & Policies Screen

Accessible to all users including those pending approval.

### UI Layout

```
┌─────────────────────────────────────┐
│  [←]  Rules & Policies              │
├─────────────────────────────────────┤
│                                     │
│  📖 Table of Contents               │
│                                     │
│  1. Introduction                    │
│  2. Membership Tiers                │
│  3. Daily Deed Requirements         │
│  4. Penalty System                  │
│  5. Grace Period                    │
│  6. Excuse Policy                   │
│  7. Payment Guidelines              │
│  8. Auto-Deactivation               │
│  9. User Responsibilities           │
│  10. Contact & Support              │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  1. INTRODUCTION                    │
│                                     │
│  Welcome to Sabiquun! This app      │
│  helps you track your daily Islamic │
│  deeds and maintain consistency...  │
│                                     │
│  [Full content continues...]        │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │
│                                     │
│  2. MEMBERSHIP TIERS                │
│                                     │
│  🌱 New Member (Training)           │
│  • First 30 days after approval     │
│  • No penalties applied             │
│  • Full access to tracking          │
│                                     │
│  💎 Exclusive Member                │
│  • After training period            │
│  • Penalties apply after grace      │
│  • Full accountability              │
│                                     │
│  [Content continues...]             │
│                                     │
└─────────────────────────────────────┘
```

### UI Elements

- **Table of Contents**: Quick navigation links
  - Scroll to section on tap
- **Rich Text Content**: Formatted text with:
  - Headings and subheadings
  - Bullet points
  - Bold/italic emphasis
  - Color-coded sections
- **Sections**: Organized content blocks
  - Introduction
  - Membership tiers explained
  - Deed categories
  - Penalty calculation
  - Grace period details
  - Excuse submission process
  - Payment procedures
  - Auto-deactivation thresholds
  - User responsibilities
  - Contact information

### Content Sections

1. **Introduction**: Overview of app purpose
2. **Membership Tiers**: Detailed tier explanations
3. **Daily Deed Requirements**: 10 deeds breakdown
4. **Penalty System**: 5,000 per deed calculation
5. **Grace Period**: 12-hour window after deadline
6. **Excuse Policy**: Valid excuse types and process
7. **Payment Guidelines**: FIFO application, methods
8. **Auto-Deactivation**: 500,000 threshold warning
9. **User Responsibilities**: Expectations and conduct
10. **Contact & Support**: How to reach admin team

---

## Related Documentation

- [Authentication Screens](./01-authentication.md)
- [Supervisor Screens](./03-supervisor-screens.md)
- [Cashier Screens](./04-cashier-screens.md)
- [Admin Screens](./05-admin-screens.md)
- [Database Schema](../database/)
- [Feature Specifications](../features/)

---

*Last Updated: 2025-10-22*
