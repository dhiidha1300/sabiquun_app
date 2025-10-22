# Key Business Logic & Calculations

This document details the core business logic, algorithms, and calculations that power the Sabiquun application's penalty system, payment processing, statistics tracking, and gamification features.

## Table of Contents

- [Overview](#overview)
- [Membership Status Auto-Calculation](#membership-status-auto-calculation)
- [Penalty Calculation](#penalty-calculation)
- [Payment Application (FIFO)](#payment-application-fifo)
- [Report Submission & Deed Calculation](#report-submission--deed-calculation)
- [User Statistics Recalculation](#user-statistics-recalculation)
- [Fajr Champion Tag Assignment](#fajr-champion-tag-assignment)
- [Leaderboard Calculation](#leaderboard-calculation)
- [Excuse Approval Impact](#excuse-approval-impact)
- [Draft Expiration](#draft-expiration)

---

## Overview

The Sabiquun application implements sophisticated business logic to handle:

- **Automatic membership tier progression** based on account age
- **Penalty calculation** with grace periods and exemptions
- **FIFO payment distribution** across multiple penalties
- **Real-time statistics** tracking and recalculation
- **Gamification** through tags and leaderboards
- **Excuse handling** with automatic penalty waivers

All calculations are designed to be **idempotent** and **transaction-safe** to ensure data consistency.

---

## Membership Status Auto-Calculation

**Trigger:** Daily cron job at 12:01 AM or on-demand calculation

**Purpose:** Automatically upgrade users through membership tiers based on account age

### Business Rules

| Membership Status | Account Age | Penalties Applied |
|------------------|-------------|-------------------|
| `new` | 0-30 days | No |
| `exclusive` | 31 days - 3 years | Yes |
| `legacy` | 3+ years | Yes |

### SQL Implementation

```sql
-- Calculate membership status based on account age
UPDATE users
SET membership_status = CASE
  WHEN CURRENT_DATE - created_at::date <= 30 THEN 'new'
  WHEN CURRENT_DATE - created_at::date <= 1095 THEN 'exclusive' -- 3 years
  ELSE 'legacy'
END
WHERE account_status = 'active';
```

### Key Points

- Only applies to `active` accounts
- Silent update (no notifications)
- Training period (`new` status) exempts users from penalties
- Cannot be manually overridden (system-controlled)

---

## Penalty Calculation

**Trigger:** Daily at 12:00 PM (after grace period ends)

**Purpose:** Apply penalties to users who failed to submit complete deed reports

### Business Rules

1. **Grace Period**: Reports due by 12 PM the following day
2. **Exemptions**:
   - New members (training period)
   - Rest days
   - Approved excuses
   - Already submitted reports
3. **Penalty Rate**: 5,000 shillings per missed full deed (500 per 0.1 fraction)
4. **Auto-Deactivation**: Account suspended when balance reaches threshold (default: 500,000 shillings)

### Complete Algorithm

```javascript
// For each user with no submitted report for yesterday
const yesterday = new Date();
yesterday.setDate(yesterday.getDate() - 1);

// Check if user should be penalized
const shouldPenalize = (
  user.membership_status !== 'new' && // Not in training period
  !isRestDay(yesterday) && // Not a rest day
  !hasApprovedExcuse(user.id, yesterday) && // No approved excuse
  !hasSubmittedReport(user.id, yesterday) // No report submitted
);

if (shouldPenalize) {
  // Calculate target (sum of active deeds)
  const target = await getActiveDeedsCount();

  // Get actual deeds submitted (or 0 if no report)
  const actual = await getUserDeedsForDate(user.id, yesterday) || 0;

  // Calculate missed deeds
  const missed = target - actual;

  if (missed > 0) {
    // Calculate penalty (5000 per deed, 500 per 0.1)
    const penaltyAmount = missed * 5000;

    // Create penalty record
    await createPenalty({
      user_id: user.id,
      amount: penaltyAmount,
      date_incurred: yesterday,
      status: 'unpaid'
    });

    // Update user statistics
    await updateUserBalance(user.id, penaltyAmount);

    // Check auto-deactivation threshold
    const balance = await getUserPenaltyBalance(user.id);
    const threshold = await getSetting('auto_deactivation_threshold');

    if (balance >= threshold) {
      await deactivateUser(user.id);
      await sendNotification(user.id, 'account_deactivated');
    } else {
      // Check warning thresholds
      const warnings = await getSetting('warning_thresholds');
      if (warnings.includes(balance)) {
        await sendNotification(user.id, 'auto_deactivation_warning');
      }
    }

    // Send penalty notification
    await sendNotification(user.id, 'penalty_incurred', {
      amount: penaltyAmount,
      missed_deeds: missed,
      date: yesterday,
      balance: balance
    });
  }
}
```

### Penalty Calculation Examples

| Scenario | Target | Actual | Missed | Penalty |
|----------|--------|--------|--------|---------|
| No report submitted | 10.0 | 0.0 | 10.0 | 50,000 |
| Partial completion | 10.0 | 7.5 | 2.5 | 12,500 |
| Fractional miss | 10.0 | 9.6 | 0.4 | 2,000 |
| Perfect completion | 10.0 | 10.0 | 0.0 | 0 |

### Warning Thresholds

```javascript
// Default configuration
const warningThresholds = [400000, 450000];

// When balance reaches 400,000 or 450,000, send warning
if (warningThresholds.includes(newBalance)) {
  await sendNotification(user.id, 'auto_deactivation_warning', {
    balance: newBalance,
    threshold: 500000,
    remaining: 500000 - newBalance
  });
}
```

---

## Payment Application (FIFO)

**Trigger:** When admin/cashier approves a payment

**Purpose:** Distribute payment amount across unpaid penalties using First-In-First-Out (oldest first)

### Algorithm

```javascript
async function applyPayment(paymentId) {
  const payment = await getPayment(paymentId);
  let remainingAmount = payment.amount;

  // Get unpaid penalties ordered by date (oldest first)
  const penalties = await getUnpaidPenalties(payment.user_id, 'date_incurred ASC');

  for (const penalty of penalties) {
    if (remainingAmount <= 0) break;

    const unpaidAmount = penalty.amount - penalty.paid_amount;
    const amountToApply = Math.min(remainingAmount, unpaidAmount);

    // Create penalty_payment record
    await createPenaltyPayment({
      penalty_id: penalty.id,
      payment_id: payment.id,
      amount_applied: amountToApply
    });

    // Update penalty
    await updatePenalty(penalty.id, {
      paid_amount: penalty.paid_amount + amountToApply,
      status: (penalty.paid_amount + amountToApply >= penalty.amount) ? 'paid' : 'unpaid'
    });

    remainingAmount -= amountToApply;
  }

  // Update payment status
  await updatePayment(paymentId, {
    status: 'approved',
    reviewed_by: currentAdminId,
    reviewed_at: new Date()
  });

  // Update user statistics
  await recalculateUserBalance(payment.user_id);

  // Send notification to user
  await sendNotification(payment.user_id, 'payment_approved', {
    amount: payment.amount,
    balance: await getUserPenaltyBalance(payment.user_id)
  });

  // Check if user can be reactivated
  const balance = await getUserPenaltyBalance(payment.user_id);
  const user = await getUser(payment.user_id);

  if (user.account_status === 'auto_deactivated' && balance < threshold) {
    // User must still be manually reactivated by admin
    // Just notify admin that balance is now under threshold
    await notifyAdmins('user_eligible_for_reactivation', {
      user_id: payment.user_id,
      new_balance: balance
    });
  }
}
```

### Payment Application Example

**Scenario:**
- User has 3 unpaid penalties:
  - Penalty A: 15,000 (date: Jan 1)
  - Penalty B: 20,000 (date: Jan 2)
  - Penalty C: 25,000 (date: Jan 3)
- User submits payment: 30,000

**Distribution (FIFO):**
1. Apply 15,000 to Penalty A → Fully paid
2. Apply 15,000 to Penalty B → Partially paid (5,000 remaining)
3. Penalty C remains unpaid

**Result:**
- Total balance: 30,000 (5,000 + 25,000)
- Payment fully consumed

### Key Features

- **Partial payment support**: Penalties can be partially paid
- **Audit trail**: Every payment-penalty link recorded in `penalty_payments`
- **Automatic status updates**: Penalties marked 'paid' when fully settled
- **Balance recalculation**: User statistics updated after payment
- **Reactivation eligibility**: Admin notified when deactivated user eligible for reactivation

---

## Report Submission & Deed Calculation

**Trigger:** When user submits a deed report

**Purpose:** Calculate totals, update statistics, check achievements

### Algorithm

```javascript
async function submitReport(reportId) {
  const report = await getReport(reportId);
  const deedEntries = await getDeedEntries(reportId);

  let totalDeeds = 0;
  let sunnahCount = 0;
  let faraidCount = 0;

  // Calculate totals
  for (const entry of deedEntries) {
    const template = await getDeedTemplate(entry.deed_template_id);
    totalDeeds += entry.deed_value;

    if (template.category === 'sunnah') {
      sunnahCount += entry.deed_value;
    } else if (template.category === 'faraid') {
      faraidCount += entry.deed_value;
    }
  }

  // Update report
  await updateReport(reportId, {
    total_deeds: totalDeeds,
    sunnah_count: sunnahCount,
    faraid_count: faraidCount,
    status: 'submitted',
    submitted_at: new Date()
  });

  // Update user statistics
  await updateUserStatistics(report.user_id);

  // Check for special tags (e.g., Fajr Champion)
  await checkAndAwardTags(report.user_id);

  // Update leaderboard
  await updateLeaderboard(report.user_id);

  return {
    success: true,
    total_deeds: totalDeeds,
    sunnah_count: sunnahCount,
    faraid_count: faraidCount
  };
}
```

### Calculation Rules

1. **Binary Deeds**: Value must be 0 or 1
2. **Fractional Deeds**: Value can be 0.0, 0.1, 0.2, ... 1.0
3. **Category Totals**: Sum by `sunnah` or `faraid` category
4. **Overall Total**: Sum of all deed values

### Example Calculation

**Deed Entries:**
```javascript
[
  { deed: 'Fajr Prayer (faraid)', value: 1.0 },
  { deed: 'Duha Prayer (sunnah)', value: 1.0 },
  { deed: 'Sunnah Prayers (sunnah)', value: 0.6 },
  { deed: 'Dhuhr Prayer (faraid)', value: 1.0 },
  { deed: 'Asr Prayer (faraid)', value: 0.0 },
  // ... more entries
]
```

**Result:**
- `total_deeds`: 9.2
- `faraid_count`: 4.0
- `sunnah_count`: 5.2

---

## User Statistics Recalculation

**Trigger:** After report submission, payment approval, penalty incurred, or daily cron (1:00 AM)

**Purpose:** Keep aggregated user statistics up-to-date

### Complete Algorithm

```javascript
async function recalculateUserStatistics(userId) {
  // Get all submitted reports
  const reports = await getSubmittedReports(userId);

  // Calculate totals
  const totalDeeds = reports.reduce((sum, r) => sum + r.total_deeds, 0);
  const totalReports = reports.length;
  const avgDeeds = totalReports > 0 ? (totalDeeds / totalReports) : 0;

  // Calculate streaks
  const streaks = calculateStreaks(reports);

  // Calculate Fajr completion rate
  const fajrTemplate = await getDeedTemplateByKey('fajr_prayer');
  const fajrEntries = await getDeedEntriesForUser(userId, fajrTemplate.id);
  const fajrRate = (fajrEntries.filter(e => e.deed_value === 1).length / totalReports) * 100;

  // Calculate category rates
  const faraidRate = await calculateCategoryRate(userId, 'faraid');
  const sunnahRate = await calculateCategoryRate(userId, 'sunnah');

  // Get financial data
  const penalties = await getUserPenalties(userId);
  const totalIncurred = penalties.reduce((sum, p) => sum + p.amount, 0);
  const totalPaid = penalties.reduce((sum, p) => sum + p.paid_amount, 0);
  const currentBalance = totalIncurred - totalPaid;

  // Update statistics table
  await updateOrCreateStatistics(userId, {
    total_deeds: totalDeeds,
    total_reports_submitted: totalReports,
    total_penalties_incurred: totalIncurred,
    total_penalties_paid: totalPaid,
    current_penalty_balance: currentBalance,
    average_daily_deeds: avgDeeds,
    best_streak_days: streaks.best,
    current_streak_days: streaks.current,
    fajr_completion_rate: fajrRate,
    faraid_completion_rate: faraidRate,
    sunnah_completion_rate: sunnahRate,
    last_report_date: reports[reports.length - 1]?.report_date,
    last_calculated_at: new Date()
  });
}
```

### Streak Calculation

```javascript
function calculateStreaks(reports) {
  // Sort reports by date
  const sortedReports = reports.sort((a, b) =>
    new Date(a.report_date) - new Date(b.report_date)
  );

  let currentStreak = 0;
  let bestStreak = 0;
  let lastDate = null;

  for (const report of sortedReports) {
    const reportDate = new Date(report.report_date);

    // Check if report meets target (10 deeds)
    if (report.total_deeds >= 10) {
      if (lastDate && isConsecutiveDay(lastDate, reportDate)) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      bestStreak = Math.max(bestStreak, currentStreak);
      lastDate = reportDate;
    } else {
      currentStreak = 0;
    }
  }

  return { current: currentStreak, best: bestStreak };
}

function isConsecutiveDay(date1, date2) {
  const diff = Math.abs(date2 - date1);
  const daysDiff = diff / (1000 * 60 * 60 * 24);
  return daysDiff === 1;
}
```

### Category Completion Rate

```javascript
async function calculateCategoryRate(userId, category) {
  const reports = await getSubmittedReports(userId);
  const templates = await getDeedTemplatesByCategory(category);

  let totalExpected = 0;
  let totalAchieved = 0;

  for (const report of reports) {
    const entries = await getDeedEntriesForReport(report.id);

    for (const template of templates) {
      totalExpected += 1.0; // Each deed worth 1 point

      const entry = entries.find(e => e.deed_template_id === template.id);
      if (entry) {
        totalAchieved += entry.deed_value;
      }
    }
  }

  return totalExpected > 0 ? (totalAchieved / totalExpected) * 100 : 0;
}
```

---

## Fajr Champion Tag Assignment

**Trigger:** Daily calculation at 2:30 AM or after report submission

**Purpose:** Award/remove gamification tags based on performance criteria

### Algorithm

```javascript
async function checkFajrChampionTag(userId) {
  const tag = await getTagByKey('fajr_champion');
  const criteria = tag.criteria; // {deed_key: "fajr_prayer", completion_rate: 90, days: 30}

  // Get last 30 days of reports
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - criteria.days);

  const reports = await getUserReportsInDateRange(userId, startDate, new Date());

  // Get Fajr deed entries for these reports
  const fajrTemplate = await getDeedTemplateByKey(criteria.deed_key);
  const fajrEntries = await getDeedEntriesForReports(
    reports.map(r => r.id),
    fajrTemplate.id
  );

  // Calculate completion rate
  const completedCount = fajrEntries.filter(e => e.deed_value === 1).length;
  const totalDays = reports.length;
  const completionRate = (completedCount / totalDays) * 100;

  // Check if user meets criteria
  if (completionRate >= criteria.completion_rate) {
    // Award tag if not already awarded
    const existingTag = await getUserTag(userId, tag.id);
    if (!existingTag) {
      await awardTag(userId, tag.id);
      await sendNotification(userId, 'tag_awarded', {
        tag_name: tag.display_name
      });
    }
  } else {
    // Remove tag if criteria no longer met
    await removeUserTag(userId, tag.id);
  }
}
```

### Tag Criteria Examples

```javascript
// Fajr Champion: 90% Fajr completion over 30 days
{
  "deed_key": "fajr_prayer",
  "completion_rate": 90,
  "days": 30
}

// Perfect Week: 100% completion for 7 consecutive days
{
  "target_deeds": 10,
  "completion_rate": 100,
  "days": 7,
  "consecutive": true
}

// Quran Lover: Read Quran 25+ times in 30 days
{
  "deed_key": "juz_quran",
  "minimum_count": 25,
  "days": 30
}
```

---

## Leaderboard Calculation

**Trigger:** Daily calculation at 2:00 AM or on-demand

**Purpose:** Rank users by performance for various time periods

### Complete Algorithm

```javascript
async function updateLeaderboards() {
  const periodTypes = ['daily', 'weekly', 'monthly', 'all_time'];

  for (const periodType of periodTypes) {
    const {startDate, endDate} = getPeriodDates(periodType);

    // Get all active users
    const users = await getActiveUsers();
    const leaderboardData = [];

    for (const user of users) {
      // Get reports in period
      const reports = await getUserReportsInDateRange(user.id, startDate, endDate);

      if (reports.length === 0) continue;

      const totalDeeds = reports.reduce((sum, r) => sum + r.total_deeds, 0);
      const avgDeeds = totalDeeds / reports.length;

      // Get special tags
      const tags = await getUserActiveTags(user.id);

      leaderboardData.push({
        user_id: user.id,
        total_deeds: totalDeeds,
        average_deeds: avgDeeds,
        special_tags: tags.map(t => t.tag_key)
      });
    }

    // Sort by average deeds (descending)
    leaderboardData.sort((a, b) => b.average_deeds - a.average_deeds);

    // Assign ranks
    leaderboardData.forEach((data, index) => {
      data.rank = index + 1;
      data.period_type = periodType;
      data.period_start = startDate;
      data.period_end = endDate;
    });

    // Delete old leaderboard for this period
    await deleteLeaderboard(periodType, startDate, endDate);

    // Insert new leaderboard
    await insertLeaderboard(leaderboardData);
  }
}

function getPeriodDates(periodType) {
  const today = new Date();
  let startDate, endDate;

  switch (periodType) {
    case 'daily':
      startDate = endDate = today;
      break;

    case 'weekly':
      // Current week (Monday to Sunday)
      const dayOfWeek = today.getDay();
      const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
      startDate = new Date(today);
      startDate.setDate(today.getDate() + mondayOffset);
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6);
      break;

    case 'monthly':
      startDate = new Date(today.getFullYear(), today.getMonth(), 1);
      endDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
      break;

    case 'all_time':
      startDate = new Date('2000-01-01'); // Far past date
      endDate = today;
      break;
  }

  return { startDate, endDate };
}
```

### Ranking Rules

1. **Primary Sort**: Average deeds per day (descending)
2. **Tie-breaker**: Total deeds (descending)
3. **Minimum Reports**: Users must have at least 1 report in period
4. **Active Only**: Only active accounts included

### Leaderboard Example

| Rank | User | Total Deeds | Avg Deeds | Special Tags |
|------|------|-------------|-----------|--------------|
| 1 | Ahmed | 300.0 | 10.0 | [fajr_champion, perfect_week] |
| 2 | Fatima | 285.5 | 9.5 | [fajr_champion] |
| 3 | Mohammed | 270.0 | 9.0 | [] |

---

## Excuse Approval Impact

**Trigger:** When supervisor/admin approves an excuse

**Purpose:** Waive penalties that were applied before excuse approval

### Algorithm

```javascript
async function approveExcuse(excuseId, reviewerId) {
  const excuse = await getExcuse(excuseId);

  // Update excuse status
  await updateExcuse(excuseId, {
    status: 'approved',
    reviewed_by: reviewerId,
    reviewed_at: new Date()
  });

  // Check if penalty already applied for this date
  const penalty = await getPenaltyForUserAndDate(excuse.user_id, excuse.report_date);

  if (penalty) {
    // Waive the penalty
    await updatePenalty(penalty.id, {
      status: 'waived',
      waived_by: reviewerId,
      waived_reason: `Excuse approved: ${excuse.excuse_type}`
    });

    // Recalculate user balance
    await recalculateUserBalance(excuse.user_id);
  }

  // Send notification to user
  await sendNotification(excuse.user_id, 'excuse_approved', {
    deeds: getAffectedDeedsText(excuse.affected_deeds),
    date: excuse.report_date
  });

  // Recalculate statistics
  await recalculateUserStatistics(excuse.user_id);
}
```

### Excuse Impact Scenarios

| Scenario | Penalty Status | Balance Impact | Account Status |
|----------|---------------|----------------|----------------|
| Excuse approved before penalty | N/A | No penalty created | No change |
| Excuse approved after penalty | Waived | Balance reduced | May be reactivated |
| Excuse rejected | Unpaid | No change | No change |
| Excuse pending | Unpaid | No change | No change |

### Affected Deeds Format

```javascript
// All deeds excused
{
  "all": true
}

// Specific deeds excused
["uuid-of-fajr", "uuid-of-duha", "uuid-of-asr"]

function getAffectedDeedsText(affectedDeeds) {
  if (affectedDeeds.all) {
    return "All deeds";
  }

  const deedNames = affectedDeeds.map(id => getDeedName(id));
  return deedNames.join(", ");
}
```

---

## Draft Expiration

**Trigger:** Daily cleanup job at 12:30 PM (after grace period ends)

**Purpose:** Remove expired draft reports to maintain data hygiene

### Algorithm

```javascript
async function cleanupExpiredDrafts() {
  // Get yesterday's date
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);

  // Grace period ends at 12 PM today
  const gracePeriodEnd = new Date();
  gracePeriodEnd.setHours(12, 0, 0, 0);

  // If current time is past grace period end
  if (new Date() > gracePeriodEnd) {
    // Delete all draft reports for yesterday or earlier
    const deletedCount = await deleteDrafts({
      report_date: { lte: yesterday },
      status: 'draft'
    });

    console.log(`Deleted ${deletedCount} expired draft reports`);
  }
}
```

### Draft Lifecycle

```
Day 1 (Report Date)
├── 00:00 - Report period begins
├── 23:59 - Report period ends
│
Day 2 (Grace Period)
├── 00:00 - Grace period begins
├── 11:59 - Last chance to submit
├── 12:00 - Grace period ends, penalties applied
├── 12:30 - Draft cleanup job runs
└── Drafts deleted if not submitted
```

### Business Rules

1. **Draft Creation**: Any time before submission
2. **Draft Editing**: Only possible before grace period ends
3. **Draft Deletion**: Automatic after grace period
4. **Submitted Reports**: Never deleted automatically

---

## Performance Optimization

### Caching Strategies

```javascript
// Cache frequently accessed settings
const settingsCache = new Map();

async function getSetting(key) {
  if (settingsCache.has(key)) {
    return settingsCache.get(key);
  }

  const value = await fetchSettingFromDB(key);
  settingsCache.set(key, value);

  // Cache for 1 hour
  setTimeout(() => settingsCache.delete(key), 3600000);

  return value;
}

// Cache deed templates
const deedTemplatesCache = {
  data: null,
  lastUpdated: null,
  ttl: 3600000 // 1 hour
};

async function getActiveDeedTemplates() {
  const now = Date.now();

  if (deedTemplatesCache.data &&
      (now - deedTemplatesCache.lastUpdated) < deedTemplatesCache.ttl) {
    return deedTemplatesCache.data;
  }

  const templates = await fetchDeedTemplatesFromDB();
  deedTemplatesCache.data = templates;
  deedTemplatesCache.lastUpdated = now;

  return templates;
}
```

### Batch Processing

```javascript
// Process penalties in batches
async function processPenaltiesInBatches() {
  const batchSize = 100;
  const users = await getEligibleUsersForPenalties();

  for (let i = 0; i < users.length; i += batchSize) {
    const batch = users.slice(i, i + batchSize);

    await Promise.all(
      batch.map(user => calculateAndApplyPenalty(user))
    );

    console.log(`Processed batch ${i / batchSize + 1} of ${Math.ceil(users.length / batchSize)}`);
  }
}
```

---

## Error Handling

### Transaction Safety

```javascript
async function submitReportWithTransaction(reportId) {
  const transaction = await db.beginTransaction();

  try {
    // Update report
    await updateReport(reportId, { status: 'submitted' }, { transaction });

    // Update statistics
    await updateUserStatistics(userId, { transaction });

    // Update leaderboard
    await updateLeaderboard(userId, { transaction });

    // Commit transaction
    await transaction.commit();

    return { success: true };
  } catch (error) {
    // Rollback on error
    await transaction.rollback();

    console.error('Report submission failed:', error);
    return { success: false, error: error.message };
  }
}
```

### Idempotency

```javascript
// Ensure penalty calculation is idempotent
async function calculatePenaltyIdempotent(userId, date) {
  // Check if penalty already exists
  const existing = await getPenaltyForUserAndDate(userId, date);

  if (existing) {
    console.log(`Penalty already exists for user ${userId} on ${date}`);
    return existing;
  }

  // Calculate and create new penalty
  return await calculateAndCreatePenalty(userId, date);
}
```

---

## Navigation

- [Back to Database Schema](/docs/database/01-schema.md)
- [Next: API Endpoints](/docs/database/03-api-endpoints.md)
- [Documentation Index](/docs/README.md)
