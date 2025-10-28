# Home Page UI/UX Enhancement Plan

**Date Created:** October 27, 2025
**Status:** Ready for Implementation
**Target Feature:** Home Page (screen) Enhancement

---

## Current State Analysis

### Strengths
- Clean BLoC architecture with proper state management
- Role-based content rendering using `PermissionService`
- Consistent Material Design 3 theming
- Well-organized navigation structure with GoRouter
- Existing penalty and payment systems fully implemented

### Areas for Improvement
- Basic 2-column grid layout lacks visual hierarchy
- No key metrics/statistics visible at a glance
- Missing quick actions and shortcuts
- No grace period timer or today's progress indicator
- Static welcome message without contextual information
- Empty feature card callbacks (Excuses, User Management, Analytics, Payment Review)
- No recent activity display
- Missing floating action button for primary actions

---

## Proposed Enhancement Plan

### **Phase 1: Information Architecture & Visual Hierarchy** ⭐

#### 1.1 **Header Enhancement**
**Current State:**
```dart
// Simple welcome message
Text('Welcome back,'),
Text(user.fullName),
```

**Enhanced Version:**
- Add dynamic greeting based on time of day:
  - "Good morning, [Name]" (5 AM - 12 PM)
  - "Good afternoon, [Name]" (12 PM - 5 PM)
  - "Good evening, [Name]" (5 PM - 5 AM)
- Display current date in both Gregorian and Islamic (Hijri) calendars
- Show membership badge with icon:
  - 🆕 New Member (0-30 days) - Orange badge
  - ⭐ Exclusive Member (1 month - 3 years) - Green badge
  - 👑 Legacy Member (3+ years) - Gold badge
- Add account status indicator with color coding:
  - 🟢 Active (green)
  - 🟡 Pending (yellow/orange)
  - 🔴 Suspended (red)
  - ⚫ Auto-deactivated (grey)

#### 1.2 **Statistics Dashboard Card** (NEW WIDGET)
**Purpose:** Give users immediate visibility into their current status

**Widget:** `HomeStatisticsCard`

**Content:**
1. **Today's Deed Progress**
   - Circular progress indicator showing X/10 deeds completed
   - Color: Green if complete, Orange if in progress, Red if deadline approaching
   - Tap to navigate to Today's Deeds page

2. **Grace Period Timer**
   - Countdown timer to 12 PM next day deadline
   - Format: "XX hours XX minutes remaining"
   - Show only if deeds not submitted today
   - Red warning when < 3 hours remaining

3. **Current Penalty Balance**
   - Reuse existing `PenaltyBalanceCard` widget (already built!)
   - Color-coded based on thresholds:
     - 🟢 Green: 0-100,000 shillings
     - 🟡 Yellow: 100,000-300,000 shillings
     - 🔴 Red: 300,000+ shillings
   - Display warning badges:
     - "First Warning" at 400K
     - "Final Warning" at 450K
     - "Deactivation Risk" at 500K
   - Tap to navigate to Penalty History

4. **This Month's Score**
   - Total deeds completed this month
   - Percentage completion (total deeds / (days × 10))
   - Small trend indicator (↗️ improving, ↘️ declining)

**Layout:** Full-width card at top of screen (below header)

#### 1.3 **Recent Activity Section** (NEW WIDGET)
**Widget:** `RecentActivityCard`

**Content:**
- Horizontal scrollable list of recent activities
- Show last 5 items from:
  - ✅ Deed reports submitted (with status: approved/pending/rejected)
  - 💰 Payments made (with status: pending/approved/rejected)
  - 📋 Excuses submitted (with status: pending/approved/rejected)
  - ⚠️ Penalties incurred (with date and amount)

**Card Design:**
- Compact horizontal cards (width: 280px)
- Icon + Title + Status badge + Timestamp
- Swipeable carousel
- "View All" button at end

**Layout:** Full-width section below statistics card

---

### **Phase 2: Enhanced Feature Cards**

#### 2.1 **Feature Card Redesign**
**Current:** Simple icon + title in 2-column grid

**Enhanced Design:**
- **Badge Indicators:** Show counts in top-right corner
  - "3 pending" on Payments card
  - "2 awaiting approval" on Excuses card
  - "5 new reports" on My Reports card (Supervisor)
- **Status Dot:** Red dot for items requiring urgent attention
- **Contextual Subtitle:** Brief description below title
  - "Submit today's deeds" → "Track your daily progress"
  - "My Reports" → "View your submission history"
  - "Payments" → "Manage penalty payments"
- **Micro-interactions:**
  - Scale animation on press (0.95x)
  - Ripple effect with card color
  - Subtle elevation change (2dp → 4dp on hover)

#### 2.2 **Priority-Based Layout**
**Current:** Uniform 2-column grid

**Enhanced Layout:**

```
┌─────────────────────────────────┐
│     Statistics Dashboard        │ ← Full width
└─────────────────────────────────┘

┌─────────────────────────────────┐
│     Recent Activity             │ ← Full width, horizontal scroll
└─────────────────────────────────┘

┌───────────────┬─────────────────┐
│ Today's Deeds │   My Reports    │ ← 2 columns (if not submitted)
└───────────────┴─────────────────┘

┌───────────────┬─────────────────┐
│   Payments    │    Excuses      │ ← 2 columns
└───────────────┴─────────────────┘

┌───────────────┬─────────────────┐
│ User Mgmt     │   Analytics     │ ← 2 columns (role-specific)
│  (Admin)      │  (Supervisor)   │
└───────────────┴─────────────────┘

┌───────────────┐
│ Payment Review│                  ← 1 column (Cashier)
│  (Cashier)    │
└───────────────┘
```

**Special Case - Today's Deeds:**
- If NOT submitted today AND deadline approaching → Full-width hero card
- If already submitted → Regular 2-column card

#### 2.3 **Smart Card Ordering**
**Dynamic Reordering Rules:**
1. **Urgent actions first:** Deeds due today, grace period expiring
2. **Pending items:** Awaiting user action (payments pending review, excuses to submit)
3. **Role-specific:** Admin/Supervisor/Cashier cards after user cards
4. **Frequently used:** Track usage and prioritize most-used features

---

### **Phase 3: Quick Actions & Shortcuts**

#### 3.1 **Floating Action Button (FAB)**
**Widget:** Extended FAB with speed dial

**Primary Action:**
- Icon: `Icons.add_task`
- Label: "Submit Deeds" (if not submitted today)
- Action: Navigate to `/today-deeds`
- Hide if already submitted today

**Secondary Actions (Mini FAB Menu):**
- 📋 Submit Excuse → `/submit-excuse`
- 💰 Make Payment → `/submit-payment`
- 📊 View Penalties → `/penalty-history`

**Behavior:**
- Expands on tap (speed dial pattern)
- Collapses on scroll down, expands on scroll up
- Animate rotation on open/close

#### 3.2 **Quick Stats Bar**
**Widget:** `QuickStatsBar`

**Content:** Horizontal scrollable chips showing:
1. **Completion Streak**
   - Icon: 🔥
   - Text: "7 days streak"
   - Tap: Show streak calendar

2. **Current Rank**
   - Icon: 🏆
   - Text: "Rank #12 of 150"
   - Tap: Navigate to leaderboard

3. **Monthly Total**
   - Icon: 📈
   - Text: "245/270 deeds"
   - Tap: Show monthly breakdown

4. **Pending Approvals** (Admin/Supervisor/Cashier)
   - Icon: ⏰
   - Text: "5 pending reviews"
   - Tap: Navigate to review dashboard

**Layout:**
- Below welcome header, above statistics card
- Horizontal scroll with snap-to-item
- Small, compact chips (height: 40dp)

#### 3.3 **Profile Menu Enhancement**
**Current:** Basic user info + logout

**Enhanced Menu:**
```
┌────────────────────────────────┐
│ [Avatar] John Doe              │
│ john@email.com                 │
│ [Admin Badge]                  │
│ Profile 80% complete ──────────│ ← NEW: Progress bar
├────────────────────────────────┤
│ 🔔 Notifications (3 new)       │ ← NEW
│ 💰 Penalty Balance: 45,000     │ ← NEW
│ 📊 View Penalty History        │ ← NEW
├────────────────────────────────┤
│ 👤 Profile                     │
│ ⚙️ Settings                    │
├────────────────────────────────┤
│ 🚪 Logout                      │
└────────────────────────────────┘
```

---

### **Phase 4: Empty States & Onboarding**

#### 4.1 **First-Time User Experience**
**For New Members (Training Period):**

**Welcome Tour:**
- Step 1: "Welcome to Sabiquun! Track your daily Islamic deeds"
- Step 2: "Submit 10 daily deeds by 12 PM next day"
- Step 3: "No penalties during 30-day training period"
- Step 4: "View your progress and statistics anytime"

**New Member Badge:**
- Prominent orange badge on home screen
- Text: "🆕 Training Period (X days remaining)"
- Explanation tooltip: "No penalties during first 30 days"

**Getting Started Checklist:**
```
✅ Complete your profile
✅ Submit your first deed report
✅ Learn about penalties
✅ Explore excuse system
✅ Set up notifications
```

**Layout:** Collapsible card at top (can be dismissed)

#### 4.2 **Contextual Empty States**
**When User Has No Data:**

**No Reports Yet:**
- Illustration: Person with checklist
- Text: "No reports submitted yet"
- CTA: "Submit Your First Deed Report"
- Tip: "Track your daily Islamic deeds and build consistency"

**No Payments:**
- Illustration: Wallet
- Text: "No payment history"
- CTA: "View Your Penalty Balance"
- Tip: "Keep your balance clear by submitting deeds daily"

**No Excuses:**
- Illustration: Calendar
- Text: "No excuses submitted"
- CTA: "Learn About Excuse System"
- Tip: "Submit excuses for sickness, travel, or rain"

---

### **Phase 5: Visual Enhancements**

#### 5.1 **Color & Typography**
**Elevation System:**
- Level 0: 0dp (flat surfaces like background)
- Level 1: 2dp (cards at rest)
- Level 2: 4dp (cards on hover, raised elements)
- Level 3: 8dp (floating action button, dialogs)
- Level 4: 16dp (navigation drawer, bottom sheets)

**Gradient Backgrounds:**
- Hero sections: Use `AppColors.primaryGradient`
- Statistics card: Subtle gradient overlay
- Role badges: Gradient based on role color

**Text Hierarchy:**
- Page title: `displayMedium` (28px, bold)
- Section headers: `headlineMedium` (20px, w600)
- Card titles: `titleLarge` (16px, w600)
- Body text: `bodyMedium` (14px, normal)
- Helper text: `bodySmall` (12px, secondary)

**Shadows:**
- Subtle shadows using `AppColors.shadow` (10% opacity)
- Directional light from top-left (offset: 0, 2)

#### 5.2 **Iconography**
**Custom Deed Category Icons:**
- Fajr: 🌅 Moon to sun transition
- Tahajjud: 🌙 Crescent moon
- Quran: 📖 Open book
- Dhikr: 📿 Prayer beads
- Dhuha: ☀️ Sun
- Use Material Icons as fallback

**Animated Status Indicators:**
- Pending: Pulsing yellow dot
- Approved: Green checkmark with scale animation
- Rejected: Red X with shake animation
- Loading: Circular progress indicator

**Role Badges:**
- Admin: 👑 Crown icon + purple gradient
- Supervisor: 👁️ Eye icon + blue gradient
- Cashier: 💰 Money icon + orange gradient
- User: 👤 Person icon + green gradient

#### 5.3 **Micro-Animations**
**Card Entrance Animations:**
- Staggered fade-in from bottom
- Delay: 50ms between each card
- Duration: 300ms per card
- Easing: Ease-out curve

**Progress Bar Animations:**
- Animated fill from 0 to current value
- Duration: 800ms
- Easing: Ease-in-out curve

**Pull-to-Refresh:**
- Custom refresh indicator with app logo
- Rotation animation during loading
- Success bounce on complete

**Shimmer Loading States:**
- Skeleton screens while data loads
- Shimmer animation (left to right sweep)
- Duration: 1500ms loop
- Applied to: Statistics card, recent activity, feature cards

---

### **Phase 6: Responsive & Adaptive Design**

#### 6.1 **Tablet Layout**
**Breakpoints:**
- Mobile: < 600px width (2-column grid)
- Tablet: 600-900px width (3-column grid)
- Desktop: > 900px width (4-column grid + sidebar)

**Tablet-Specific Layout:**
```
┌──────────┬────────────────────────────┐
│          │   Statistics Dashboard     │
│  Side    │                            │
│  Nav     ├────────────────────────────┤
│  Panel   │   Recent Activity          │
│          │                            │
│          ├────────┬────────┬──────────┤
│          │  Card  │  Card  │  Card    │ ← 3 columns
│          ├────────┼────────┼──────────┤
│          │  Card  │  Card  │  Card    │
└──────────┴────────┴────────┴──────────┘
```

**Side Navigation Panel:**
- Always visible on tablet/desktop
- Contains: Profile, Quick Stats, Notifications
- Collapsible on mobile

#### 6.2 **Accessibility**
**Screen Reader Support:**
- Semantic labels for all interactive elements
- `semanticsLabel` for icons and images
- Announce status changes (e.g., "Payment approved")
- Logical focus order

**Touch Targets:**
- Minimum size: 48×48 dp (Material guidelines)
- Spacing between targets: 8dp minimum
- Adequate padding around interactive elements

**High Contrast Mode:**
- Support system high contrast settings
- Increase border width in high contrast
- Remove reliance on color alone for information

**Font Scaling:**
- Support system font size settings (1.0x to 2.0x)
- Test layouts at different scales
- Use responsive text sizing (MediaQuery.textScaleFactor)

**Keyboard Navigation:**
- Tab order follows logical reading flow
- Enter/Space to activate buttons
- Escape to close dialogs/menus

---

### **Phase 7: Integration with Existing Features**

#### 7.1 **Connect Empty Callbacks**
**Routes to Implement:**

1. **Excuses Feature:**
   ```dart
   // Routes
   '/submit-excuse' → SubmitExcusePage
   '/excuse-history' → ExcuseHistoryPage
   '/excuse-review' → ExcuseReviewPage (Supervisor)
   ```

2. **User Management (Admin):**
   ```dart
   // Routes
   '/user-management' → UserManagementPage
   '/user-detail/:id' → UserDetailPage
   '/pending-approvals' → PendingApprovalsPage
   ```

3. **Analytics (Supervisor):**
   ```dart
   // Routes
   '/analytics' → AnalyticsDashboardPage
   '/user-reports/:id' → UserReportsPage
   '/leaderboard' → LeaderboardPage
   ```

4. **Payment Review (Cashier):**
   ```dart
   // Routes
   '/payment-review' → PaymentReviewPage (already exists as /payment-history)
   '/payment-detail/:id' → PaymentDetailPage
   ```

**Update home_page.dart:**
```dart
// Line 174
_FeatureCard(
  icon: Icons.payment,
  title: 'Payments',
  color: AppColors.info,
  onTap: () => context.push('/submit-payment'), // ✅ Already implemented
),

// Line 178
_FeatureCard(
  icon: Icons.medical_services,
  title: 'Excuses',
  color: AppColors.warning,
  onTap: () => context.push('/submit-excuse'), // ⚠️ Need to implement
),

// Line 189 (Admin)
_FeatureCard(
  icon: Icons.people,
  title: 'User Management',
  color: AppColors.adminColor,
  onTap: () => context.push('/user-management'), // ⚠️ Need to implement
),

// Line 198 (Supervisor)
_FeatureCard(
  icon: Icons.assessment,
  title: 'Analytics',
  color: AppColors.supervisorColor,
  onTap: () => context.push('/analytics'), // ⚠️ Need to implement
),

// Line 207 (Cashier)
_FeatureCard(
  icon: Icons.account_balance_wallet,
  title: 'Payment Review',
  color: AppColors.cashierColor,
  onTap: () => context.push('/payment-history'), // ✅ Use existing route
),
```

#### 7.2 **BLoC Integration**
**Listen to Multiple BLoCs:**

```dart
// home_page.dart
MultiBlocListener(
  listeners: [
    // Listen to DeedBloc for today's progress
    BlocListener<DeedBloc, DeedState>(
      listener: (context, state) {
        if (state is DeedSubmitted) {
          // Update statistics card
          // Show success message
          // Refresh recent activity
        }
      },
    ),

    // Listen to PenaltyBloc for balance updates
    BlocListener<PenaltyBloc, PenaltyState>(
      listener: (context, state) {
        if (state is PenaltyBalanceLoaded) {
          // Update balance display
          // Show warning if threshold exceeded
        }
      },
    ),

    // Listen to PaymentBloc for pending payments
    BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSubmitted) {
          // Show badge on Payments card
          // Update balance after approval
        }
      },
    ),
  ],
  child: HomePageContent(),
)
```

**Load Data on Page Init:**
```dart
@override
void initState() {
  super.initState();
  final userId = context.read<AuthBloc>().state.user.id;

  // Load today's deeds
  context.read<DeedBloc>().add(LoadTodayDeedsRequested(userId));

  // Load penalty balance
  context.read<PenaltyBloc>().add(LoadPenaltyBalanceRequested(userId));

  // Load pending payments
  context.read<PaymentBloc>().add(LoadPendingPaymentsRequested(userId));

  // Load recent reports
  context.read<DeedBloc>().add(LoadRecentReportsRequested(userId, limit: 5));
}
```

**Real-Time Updates:**
- Use Supabase real-time subscriptions for:
  - Penalty balance changes
  - Payment approvals
  - New notifications
- Update UI reactively via BLoC events

---

## Implementation Priority

### **Must Have (P0)** - Core Enhancements ⭐⭐⭐
**Timeline: 2-3 days**

1. ✅ **Statistics Dashboard Card**
   - Today's deed progress indicator
   - Current penalty balance (reuse `PenaltyBalanceCard`)
   - Grace period timer
   - Monthly score

2. ✅ **Enhanced Feature Cards**
   - Add badge indicators (pending counts)
   - Add contextual subtitles
   - Add status dots for urgent items
   - Basic micro-interactions (press animation)

3. ✅ **Floating Action Button**
   - Primary: Submit Today's Deeds
   - Show only if not submitted
   - Navigate to `/today-deeds`

4. ✅ **Recent Activity Section**
   - Horizontal scrollable cards
   - Show last 5 activities (reports, payments, penalties)
   - Status badges and timestamps

5. ✅ **Connect Empty Navigation Callbacks**
   - Payments → `/submit-payment` ✅ (already exists)
   - Payment Review (Cashier) → `/payment-history` ✅ (already exists)
   - Other routes → Create placeholder pages or TODO markers

---

### **Should Have (P1)** - Significant Improvements ⭐⭐
**Timeline: 2-3 days**

6. ✅ **Priority-Based Card Layout**
   - Hero card for urgent deeds
   - Medium cards for regular features
   - Role-specific cards at bottom
   - Dynamic reordering logic

7. ✅ **Quick Stats Bar**
   - Completion streak counter
   - Current leaderboard rank
   - Monthly deed total
   - Pending approvals count (role-specific)

8. ✅ **Profile Menu Enhancements**
   - Profile completion progress bar
   - Quick penalty balance display
   - Recent notifications preview (3 latest)
   - Quick link to penalty history

9. ✅ **First-Time User Onboarding**
   - Welcome tour (4-step)
   - New member badge with training period countdown
   - Getting started checklist
   - Collapsible/dismissible card

---

### **Nice to Have (P2)** - Polish & Delight ⭐
**Timeline: 2-3 days**

10. ✅ **Micro-Animations**
    - Staggered card entrance (fade-in from bottom)
    - Progress bar animated fill
    - Scale animation on card press
    - Custom pull-to-refresh indicator

11. ✅ **Custom Iconography**
    - Deed category icons
    - Animated status indicators
    - Role badge gradients

12. ✅ **Empty State Illustrations**
    - "No reports yet" illustration
    - "No payments" illustration
    - "No excuses" illustration
    - Educational tips and CTAs

13. ✅ **Tablet Responsive Layout**
    - 3-column grid for tablets
    - Side navigation panel
    - Desktop support (4-column + sidebar)

14. ✅ **Shimmer Loading States**
    - Skeleton screens during data load
    - Shimmer animation effect
    - Apply to all cards

---

## Technical Implementation Details

### New File Structure

```
lib/features/home/
├── pages/
│   └── home_page.dart                    ✏️ ENHANCE (existing)
│
├── widgets/
│   ├── home_statistics_card.dart         🆕 NEW (P0)
│   ├── today_progress_indicator.dart     🆕 NEW (P0)
│   ├── grace_period_timer.dart           🆕 NEW (P0)
│   ├── monthly_score_widget.dart         🆕 NEW (P0)
│   ├── recent_activity_card.dart         🆕 NEW (P0)
│   ├── activity_item_card.dart           🆕 NEW (P0)
│   ├── enhanced_feature_card.dart        🆕 NEW (P0)
│   ├── quick_stats_bar.dart              🆕 NEW (P1)
│   ├── quick_stat_chip.dart              🆕 NEW (P1)
│   ├── enhanced_profile_menu.dart        🆕 NEW (P1)
│   ├── onboarding_overlay.dart           🆕 NEW (P1)
│   ├── getting_started_checklist.dart    🆕 NEW (P1)
│   └── empty_state_widget.dart           🆕 NEW (P2)
│
├── blocs/
│   ├── home_bloc.dart                    🆕 NEW (Optional)
│   ├── home_event.dart                   🆕 NEW (Optional)
│   └── home_state.dart                   🆕 NEW (Optional)
│
└── utils/
    ├── time_helper.dart                  🆕 NEW (greeting logic)
    └── membership_helper.dart            🆕 NEW (badge logic)
```

**Note:** `home_bloc` is optional. Can use existing BLoCs directly via `context.read<>()`.

---

### Files to Modify

1. **lib/features/home/pages/home_page.dart** ✏️
   - Restructure layout (statistics card + activity + cards)
   - Add FAB
   - Integrate multiple BLoCs
   - Implement priority-based ordering

2. **lib/core/navigation/app_router.dart** ✏️
   - Add routes: `/submit-excuse`, `/excuse-history`
   - Add routes: `/user-management`, `/pending-approvals`
   - Add routes: `/analytics`, `/leaderboard`
   - Ensure `/payment-history` is accessible for cashiers

3. **lib/core/di/injection.dart** ✏️
   - Register `HomeBloc` if created (optional)
   - Ensure all required BLoCs are initialized

4. **lib/main.dart** ✏️
   - Add `HomeBloc` to BlocProvider if created

---

### Data Sources & BLoC Integration

#### Data Flow

```
┌──────────────┐
│   AuthBloc   │──┐
└──────────────┘  │
                  │
┌──────────────┐  │    ┌──────────────┐
│   DeedBloc   │──┼───▶│   HomePage   │
└──────────────┘  │    │  (Stateless) │
                  │    └──────────────┘
┌──────────────┐  │           │
│ PenaltyBloc  │──┤           │
└──────────────┘  │           ▼
                  │    ┌──────────────────┐
┌──────────────┐  │    │ Home Widgets     │
│ PaymentBloc  │──┘    │ - Statistics     │
└──────────────┘       │ - Activity       │
                       │ - Feature Cards  │
                       └──────────────────┘
```

#### Required BLoC Events

**DeedBloc:**
```dart
// Load today's deeds
LoadTodayDeedsRequested(String userId)

// Load recent reports
LoadRecentReportsRequested(String userId, {int limit = 5})

// Load monthly stats
LoadMonthlyStatsRequested(String userId, int month, int year)
```

**PenaltyBloc:**
```dart
// Load balance (already exists)
LoadPenaltyBalanceRequested(String userId)

// Load recent penalties
LoadRecentPenaltiesRequested(String userId, {int limit = 5})
```

**PaymentBloc:**
```dart
// Load pending payments (already exists)
LoadPendingPaymentsRequested(String userId)

// Load recent payments
LoadRecentPaymentsRequested(String userId, {int limit = 5})
```

#### Required BLoC States

**DeedBloc:**
```dart
// Today's deeds state
class TodayDeedsLoaded extends DeedState {
  final List<DeedEntity> deeds;
  final int completedCount;
  final int totalCount;
  final bool isSubmitted;
  final DateTime? submittedAt;
}

// Monthly stats state
class MonthlyStatsLoaded extends DeedState {
  final int totalDeeds;
  final int completedDeeds;
  final double completionRate;
  final int streak;
}
```

**PenaltyBloc:**
```dart
// Balance state (already exists)
class PenaltyBalanceLoaded extends PenaltyState {
  final PenaltyBalanceEntity balance;
}
```

**PaymentBloc:**
```dart
// Pending payments state
class PendingPaymentsLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  final int count;
}
```

---

### Helper Classes to Create

#### 1. TimeHelper (lib/features/home/utils/time_helper.dart)
```dart
class TimeHelper {
  /// Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Calculate remaining time until deadline (12 PM next day)
  static Duration getRemainingTime() {
    final now = DateTime.now();
    final deadline = DateTime(
      now.day >= 12 ? now.day + 1 : now.day,
      12, // 12 PM
      0,
      0,
    );
    return deadline.difference(now);
  }

  /// Format duration as "Xh Ym"
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  /// Check if deadline is approaching (< 3 hours)
  static bool isDeadlineApproaching() {
    return getRemainingTime().inHours < 3;
  }
}
```

#### 2. MembershipHelper (lib/features/home/utils/membership_helper.dart)
```dart
class MembershipHelper {
  /// Get membership type based on account age
  static MembershipType getMembershipType(DateTime createdAt) {
    final duration = DateTime.now().difference(createdAt);

    if (duration.inDays < 30) {
      return MembershipType.newMember;
    } else if (duration.inDays < 1095) { // 3 years
      return MembershipType.exclusive;
    } else {
      return MembershipType.legacy;
    }
  }

  /// Get membership badge data
  static MembershipBadge getBadge(DateTime createdAt) {
    final type = getMembershipType(createdAt);

    switch (type) {
      case MembershipType.newMember:
        final daysRemaining = 30 - DateTime.now().difference(createdAt).inDays;
        return MembershipBadge(
          icon: '🆕',
          label: 'New Member',
          subtitle: '$daysRemaining days remaining',
          color: AppColors.warning,
        );

      case MembershipType.exclusive:
        return MembershipBadge(
          icon: '⭐',
          label: 'Exclusive Member',
          subtitle: 'Full accountability',
          color: AppColors.success,
        );

      case MembershipType.legacy:
        return MembershipBadge(
          icon: '👑',
          label: 'Legacy Member',
          subtitle: '3+ years member',
          color: AppColors.accent,
        );
    }
  }

  /// Check if user is in training period (no penalties)
  static bool isInTrainingPeriod(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays < 30;
  }
}

enum MembershipType { newMember, exclusive, legacy }

class MembershipBadge {
  final String icon;
  final String label;
  final String subtitle;
  final Color color;

  MembershipBadge({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });
}
```

---

### Performance Considerations

#### Optimization Strategies

1. **Lazy Loading:**
   - Load recent activity only when visible
   - Use `ListView.builder` for scrollable lists
   - Implement pagination for long lists

2. **Caching:**
   - Cache statistics for 5 minutes
   - Use `flutter_cache_manager` for images
   - Store last refresh timestamp

3. **Optimized Re-renders:**
   - Use `const` constructors wherever possible
   - Wrap BlocBuilder around specific widgets only
   - Use `select` in BlocBuilder to listen to specific state fields:
     ```dart
     BlocBuilder<DeedBloc, DeedState>(
       buildWhen: (previous, current) =>
         previous.todayDeeds != current.todayDeeds,
       builder: (context, state) { ... },
     )
     ```

4. **Image Asset Preloading:**
   - Preload illustrations in `main.dart`
   - Use `precacheImage()` for frequently used images

5. **Debouncing:**
   - Debounce pull-to-refresh (prevent rapid refreshes)
   - Debounce search/filter inputs

6. **Background Processing:**
   - Calculate statistics in background isolate
   - Use `compute()` for heavy calculations

---

### Animation Implementation

#### Staggered Card Entrance

```dart
class StaggeredCardList extends StatefulWidget {
  final List<Widget> cards;

  @override
  _StaggeredCardListState createState() => _StaggeredCardListState();
}

class _StaggeredCardListState extends State<StaggeredCardList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.cards.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      );
    }).toList();

    // Start animations with stagger
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.cards.length, (index) {
        return FadeTransition(
          opacity: _animations[index],
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_animations[index]),
            child: widget.cards[index],
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
```

#### Shimmer Loading Effect

```dart
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## Design System Compliance

### Color Usage

All enhancements will strictly use colors from **app_colors.dart**:

- **Primary Actions:** `AppColors.primary` (#2E7D32)
- **Secondary Actions:** `AppColors.accent` (#FF9800)
- **Success States:** `AppColors.success` (#4CAF50)
- **Error States:** `AppColors.error` (#E53935)
- **Warning States:** `AppColors.warning` (#FFA726)
- **Info States:** `AppColors.info` (#2196F3)

**Role Colors:**
- Admin: `AppColors.adminColor` (#9C27B0)
- Supervisor: `AppColors.supervisorColor` (#2196F3)
- Cashier: `AppColors.cashierColor` (#FF9800)
- User: `AppColors.userColor` (#4CAF50)

**Account Status:**
- Pending: `AppColors.pendingColor` (#FFA726)
- Active: `AppColors.activeColor` (#4CAF50)
- Suspended: `AppColors.suspendedColor` (#E53935)
- Deactivated: `AppColors.deactivatedColor` (#9E9E9E)

### Typography

Use text styles from **app_theme.dart**:

```dart
// Page titles
Theme.of(context).textTheme.displayMedium // 28px, bold

// Section headers
Theme.of(context).textTheme.headlineMedium // 20px, w600

// Card titles
Theme.of(context).textTheme.titleLarge // 16px, w600

// Body text
Theme.of(context).textTheme.bodyMedium // 14px, normal

// Helper text
Theme.of(context).textTheme.bodySmall // 12px, secondary color
```

### Spacing & Sizing

**Padding & Margins:**
- Extra small: 4dp
- Small: 8dp
- Medium: 16dp
- Large: 24dp
- Extra large: 32dp

**Border Radius:**
- Consistent: 12px (per app_theme.dart)
- Small elements: 8px
- Large cards: 16px

**Icon Sizes:**
- Small: 16px
- Medium: 24px
- Large: 32px
- Extra large: 48px

---

## Testing Strategy

### Unit Tests

**Test Coverage:**
1. TimeHelper utility tests
   - Greeting generation at different hours
   - Remaining time calculation
   - Duration formatting

2. MembershipHelper utility tests
   - Membership type determination
   - Badge data generation
   - Training period check

3. Widget tests for new components
   - HomeStatisticsCard rendering
   - RecentActivityCard scrolling
   - EnhancedFeatureCard interactions

### Integration Tests

**Test Scenarios:**
1. Home page loads with all sections
2. Statistics update when data changes
3. Navigation from feature cards
4. FAB behavior (show/hide based on submission status)
5. Pull-to-refresh updates data

### E2E Tests

**User Flows:**
1. New user sees onboarding and completes checklist
2. User submits deeds and sees progress update
3. User with high balance sees warnings
4. Admin/Supervisor/Cashier see role-specific cards

---

## Estimated Timeline

### Phase-by-Phase Breakdown

**Phase 1 (P0): Core Enhancements**
- Days 1-2: Statistics dashboard card + Grace timer
- Day 2: Recent activity section
- Day 3: Enhanced feature cards + FAB
- **Total: 2-3 days**

**Phase 2 (P1): Improvements**
- Day 4: Priority-based layout + Smart ordering
- Day 5: Quick stats bar + Profile menu enhancement
- Day 6: Onboarding flow + Getting started checklist
- **Total: 2-3 days**

**Phase 3 (P2): Polish**
- Day 7: Micro-animations + Staggered entrance
- Day 8: Empty states + Illustrations
- Day 9: Shimmer loading + Tablet layout
- **Total: 2-3 days**

**Testing & Bug Fixes:**
- Days 10-11: Unit + Integration tests
- Days 12-13: E2E tests + Bug fixes
- **Total: 2-4 days**

**Grand Total: 8-13 days**

---

## Questions for Review

Before implementation begins, please clarify:

### 1. Priority Level
**Question:** Should I implement all P0 (Must Have) items first, or would you like to adjust priorities?
**Answer:** I prefer Full implementation P0 + P1 + P2 (within this conversation)


### 2. Custom Assets
**Question:** Do you have custom icons/illustrations, or should I use Material Icons and placeholder graphics?
**Answer:**  I don't have custom icons yet therefore use the material icons and placeholder graphics. 


### 3. Grace Period Timer
**Question:** Should the timer show countdown for current day's submission or next day's deadline?

**Answer:**  The timer should show the the next day's deadline. eg. if the user submits report in 28 oct 2025
**Clarification:**
- User submits deeds today → Grace period until 12 PM tomorrow
- Should timer show: "Submit by 12 PM today" or "15 hours remaining"?

### 4. Islamic Calendar
**Question:** Do you want Hijri calendar integration, or just Gregorian date?

**Options:**
- A) Gregorian only (simpler)
- B) Both Gregorian + Hijri (need package like `hijri`)
- C) User preference toggle in settings

### 5. Leaderboard Rank
**Question:** Is the leaderboard feature already implemented, or should I prepare for future integration?

**Context:**
- Quick stats bar wants to show "Rank #12 of 150"
- Need to know if data source exists

**Options:**
- A) Leaderboard exists → integrate now
- B) Not implemented → show placeholder
- C) Create basic leaderboard system

### 6. Analytics Data
**Question:** Should the home page show preview charts/graphs, or just summary numbers?

**Options:**
- A) Summary numbers only (simpler)
- B) Small preview chart (last 7 days)
- C) Link to full analytics page

### 7. Route Implementation
**Question:** Should I create placeholder pages for missing routes (Excuses, User Management, Analytics) or just connect existing ones?

**Current Status:**
- ✅ Payments: `/submit-payment` exists
- ✅ Payment Review: `/payment-history` exists
- ❌ Excuses: No routes yet
- ❌ User Management: No routes yet
- ❌ Analytics: No routes yet

**Options:**
- A) Create simple placeholder pages ("Coming Soon")
- B) Build full features for missing routes (more time)
- C) Leave empty callbacks with TODO comments

### 8. Notification System
**Question:** Is the notification system implemented? (For profile menu preview)

**Context:**
- Enhanced profile menu wants to show "🔔 Notifications (3 new)"
- Need to know if notification data source exists

### 9. Onboarding Persistence
**Question:** How should onboarding state be stored?

**Options:**
- A) Local storage (SharedPreferences)
- B) Database (Supabase user settings)
- C) Don't persist (show every time)

### 10. Real-Time Updates
**Question:** Should home page data update in real-time via Supabase subscriptions?

**Options:**
- A) Real-time updates (more complex, better UX)
- B) Pull-to-refresh only (simpler)
- C) Periodic auto-refresh (e.g., every 5 minutes)

---

## Next Steps

Once questions are answered, implementation will proceed in this order:

### Step 1: Setup (30 minutes)
- Create new widget files
- Create helper utility files
- Update import statements

### Step 2: P0 Implementation (2-3 days)
- Build statistics dashboard card
- Build grace period timer
- Build recent activity section
- Enhance feature cards
- Add FAB
- Connect navigation callbacks

### Step 3: Testing (ongoing)
- Unit tests for helpers
- Widget tests for new components
- Integration tests for data flow

### Step 4: P1 Implementation (if approved, 2-3 days)
- Priority-based layout
- Quick stats bar
- Profile menu enhancement
- Onboarding flow

### Step 5: P2 Polish (if approved, 2-3 days)
- Animations
- Empty states
- Shimmer loading
- Tablet layout

---

## Success Criteria

Implementation will be considered complete when:

✅ **Functionality:**
- All P0 features working correctly
- No broken navigation links
- Data loads from BLoCs successfully
- Responsive to state changes

✅ **UI/UX:**
- Consistent with Material Design 3
- Follows app_colors.dart palette
- Uses app_theme.dart typography
- Smooth animations (60fps)

✅ **Code Quality:**
- Clean architecture maintained
- BLoC pattern followed
- Reusable widgets extracted
- Proper error handling

✅ **Testing:**
- Unit tests pass
- Widget tests pass
- Integration tests pass
- No console errors

✅ **Performance:**
- Initial load < 2 seconds
- Smooth scrolling (no jank)
- Animations don't block UI
- Memory usage reasonable

---

## Resources & References

### Documentation Files
- [README.md](a:\sabiquun_app\README.md) - Project overview
- [IMPLEMENTATION_SUMMARY.md](a:\sabiquun_app\IMPLEMENTATION_SUMMARY.md) - Penalty & payment systems
- [docs/planning/01-project-overview.md](a:\sabiquun_app\docs\planning\01-project-overview.md) - Core concepts
- [docs/planning/02-user-roles.md](a:\sabiquun_app\docs\planning\02-user-roles.md) - Permissions
- [docs/planning/03-user-status.md](a:\sabiquun_app\docs\planning\03-user-status.md) - Membership tiers

### Code Files
- [home_page.dart](a:\sabiquun_app\sabiquun_app\lib\features\home\pages\home_page.dart) - Current implementation
- [app_colors.dart](a:\sabiquun_app\sabiquun_app\lib\core\theme\app_colors.dart) - Color system
- [app_theme.dart](a:\sabiquun_app\sabiquun_app\lib\core\theme\app_theme.dart) - Theme config
- [app_router.dart](a:\sabiquun_app\sabiquun_app\lib\core\navigation\app_router.dart) - Navigation
- [injection.dart](a:\sabiquun_app\sabiquun_app\lib\core\di\injection.dart) - Dependency injection

### Existing Widgets to Reuse
- `PenaltyBalanceCard` - Already built, shows color-coded balance
- `PenaltyCard` - Shows individual penalty details
- `PermissionService` - Check user permissions
- All Material Design 3 components from theme

### Flutter Packages
- `flutter_bloc` - State management ✅ (already installed)
- `go_router` - Navigation ✅ (already installed)
- `freezed` - Code generation ✅ (already installed)
- `intl` - Date/time formatting ✅ (likely installed)
- `hijri` - Islamic calendar (if needed) ❓
- `flutter_staggered_animations` - Animations (optional) ❓

---

**End of Enhancement Plan**

**Status:** ✅ Ready for Review & Approval
**Created:** October 27, 2025
**Last Updated:** October 27, 2025

Please review this plan and answer the questions so we can begin implementation tomorrow!
