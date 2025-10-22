# Edge Cases & Error Handling

## Overview

This document comprehensively covers edge cases, error scenarios, boundary conditions, and special situations that the Good Deeds Tracking App must handle gracefully. Proper handling of edge cases is critical for providing a robust and reliable user experience.

## Table of Contents

1. [Report Submission Edge Cases](#report-submission-edge-cases)
2. [Payment Processing Edge Cases](#payment-processing-edge-cases)
3. [Penalty Calculation Edge Cases](#penalty-calculation-edge-cases)
4. [Grace Period Boundary Conditions](#grace-period-boundary-conditions)
5. [User Status Transitions](#user-status-transitions)
6. [Network Failures and Retry Logic](#network-failures-and-retry-logic)
7. [Timezone and Date Handling](#timezone-and-date-handling)
8. [Race Conditions and Concurrency](#race-conditions-and-concurrency)
9. [Data Validation and Sanitization](#data-validation-and-sanitization)
10. [Draft Management Edge Cases](#draft-management-edge-cases)
11. [Excuse Mode Edge Cases](#excuse-mode-edge-cases)
12. [Error Messages and User Feedback](#error-messages-and-user-feedback)

## Report Submission Edge Cases

### 1. Submission After Grace Period

**Scenario**: User tries to submit report after grace period has ended.

**Error Handling:**
```javascript
async function validateReportSubmission(userId, reportDate) {
  const gracePeriodHours = await getSetting('grace_period_hours');
  const gracePeriodEnd = moment(reportDate)
    .add(1, 'day')
    .add(gracePeriodHours, 'hours');

  if (moment().isAfter(gracePeriodEnd)) {
    throw new ValidationError({
      code: 'GRACE_PERIOD_EXPIRED',
      message: 'Grace period has ended for this date. Contact admin to enable submission.',
      details: {
        reportDate,
        gracePeriodEnd: gracePeriodEnd.format('YYYY-MM-DD HH:mm:ss')
      }
    });
  }
}
```

**User Experience:**
- Show error message with clear explanation
- Disable submit button for past dates
- Provide "Contact Admin" button for special cases
- Offer to save as draft (though it won't sync)

**Recovery Options:**
- Admin can manually enable past date submission
- Admin can create report on user's behalf
- Admin can adjust grace period setting

### 2. Duplicate Report Submission

**Scenario**: User tries to submit multiple reports for the same date.

**Database Constraint:**
```sql
-- Unique constraint prevents duplicates
ALTER TABLE reports
ADD CONSTRAINT unique_user_date
UNIQUE (user_id, date);
```

**Error Handling:**
```javascript
try {
  await createReport({ userId, date, deedValues });
} catch (error) {
  if (error.code === '23505') { // PostgreSQL unique violation
    throw new ValidationError({
      code: 'DUPLICATE_REPORT',
      message: 'You have already submitted a report for this date.',
      existingReportId: await getReportId(userId, date)
    });
  }
}
```

**User Experience:**
- Show error message with link to existing report
- Redirect to view existing report
- Allow admin to delete if truly needed (logged in audit trail)

### 3. Submitting for Rest Day

**Scenario**: User attempts to submit report for a configured rest day.

**Validation:**
```javascript
async function validateNotRestDay(date) {
  const restDays = await getRestDays();
  const isRestDay = restDays.some(rd =>
    moment(rd.date).isSame(date, 'day')
  );

  if (isRestDay) {
    throw new ValidationError({
      code: 'REST_DAY_SUBMISSION',
      message: 'This date is marked as a rest day. No submissions needed.',
      date
    });
  }
}
```

**User Experience:**
- Gray out rest days in calendar
- Show "Rest Day" badge
- Disable report submission entirely
- Display rest day message in form

### 4. Admin Edits Deed Template While Users Are Reporting

**Scenario**: Admin changes deed configuration while users have active drafts.

**Handling Strategy:**
```javascript
// Store template snapshot with each report
async function createReport(data) {
  const deedTemplate = await getCurrentDeedTemplate();

  return await db.reports.create({
    ...data,
    deed_template_version: deedTemplate.version,
    deed_template_snapshot: deedTemplate.deeds
  });
}

// Use template snapshot for display/validation
async function validateReportDeeds(report) {
  const template = report.deed_template_snapshot;
  // Validate against snapshot, not current template
}
```

**Impact Analysis:**
- **New reports**: Use updated template automatically
- **Existing reports**: Unchanged, display with original template
- **Active drafts**: Continue with template version when created
- **Recalculation**: Admin can trigger if needed (with caution)

### 5. Fractional Deed Value Precision

**Scenario**: Floating-point arithmetic errors in fractional deed calculations.

**Solution:**
```javascript
// Use decimal library for precise calculations
const Decimal = require('decimal.js');

function calculateDeedTotal(deedValues) {
  let total = new Decimal(0);

  for (const [deed, value] of Object.entries(deedValues)) {
    total = total.plus(new Decimal(value));
  }

  return total.toNumber();
}

// Validation
function validateFractionalValue(value) {
  const decimal = new Decimal(value);

  // Must be between 0 and 1
  if (decimal.lt(0) || decimal.gt(1)) {
    throw new ValidationError('Value must be between 0 and 1');
  }

  // Must be multiple of 0.1
  const remainder = decimal.mod(0.1);
  if (!remainder.equals(0)) {
    throw new ValidationError('Value must be a multiple of 0.1');
  }
}
```

## Payment Processing Edge Cases

### 1. Payment Exceeds Balance

**Scenario**: User submits payment amount greater than their penalty balance.

**Validation:**
```javascript
async function validatePaymentAmount(userId, amount) {
  const balance = await getUserPenaltyBalance(userId);

  if (amount > balance) {
    throw new ValidationError({
      code: 'PAYMENT_EXCEEDS_BALANCE',
      message: 'Payment amount exceeds your penalty balance.',
      currentBalance: balance,
      suggestedAmount: balance
    });
  }
}
```

**User Experience:**
- Show current balance prominently
- Auto-adjust amount field to max balance
- Display warning before submission
- Suggest correct amount

### 2. Concurrent Payment Approvals

**Scenario**: Two cashiers approve the same payment simultaneously.

**Solution - Optimistic Locking:**
```javascript
async function approvePayment(paymentId, cashierId) {
  const payment = await db.payments.findOne({
    where: { id: paymentId }
  });

  // Check if already processed
  if (payment.status !== 'pending') {
    throw new ConcurrencyError({
      code: 'PAYMENT_ALREADY_PROCESSED',
      message: 'This payment has already been processed.',
      currentStatus: payment.status,
      processedBy: payment.approved_by,
      processedAt: payment.approved_at
    });
  }

  // Use database transaction with row locking
  await db.transaction(async (trx) => {
    const locked = await trx('payments')
      .where({ id: paymentId, status: 'pending' })
      .forUpdate()
      .first();

    if (!locked) {
      throw new ConcurrencyError('Payment no longer available');
    }

    await trx('payments')
      .where({ id: paymentId })
      .update({
        status: 'approved',
        approved_by: cashierId,
        approved_at: new Date()
      });

    // Apply payment FIFO
    await applyPaymentTopenalties(paymentId, locked.amount, trx);
  });
}
```

**User Experience:**
- Show error: "This payment has already been processed"
- Refresh payment list automatically
- Display current status and approver
- Admin can check audit log for details

### 3. FIFO Application with Partial Payments

**Scenario**: Payment partially covers oldest penalty, with remainder going to next.

**Implementation:**
```javascript
async function applyPaymentFIFO(paymentId, amount) {
  const penalties = await getPenaltiesOrderedByDate(userId, 'unpaid');
  let remaining = new Decimal(amount);
  const transactions = [];

  for (const penalty of penalties) {
    if (remaining.lte(0)) break;

    const penaltyAmount = new Decimal(penalty.amount);
    const penaltyRemaining = new Decimal(penalty.remaining_amount || penalty.amount);

    if (remaining.gte(penaltyRemaining)) {
      // Full payment of this penalty
      transactions.push({
        penalty_id: penalty.id,
        amount: penaltyRemaining.toNumber(),
        status: 'paid'
      });
      remaining = remaining.minus(penaltyRemaining);
    } else {
      // Partial payment
      transactions.push({
        penalty_id: penalty.id,
        amount: remaining.toNumber(),
        status: 'partial'
      });
      remaining = new Decimal(0);
    }
  }

  // Record transactions
  await recordPaymentTransactions(paymentId, transactions);

  return {
    paid: transactions,
    remaining: remaining.toNumber()
  };
}
```

**Edge Case - Exact Payment:**
```javascript
// User pays exactly the remaining amount of multiple penalties
// Example: Balance = 10,000 + 5,000 + 3,000
// Payment = 18,000 (exact match)
// Result: All three penalties marked as 'paid'
```

### 4. Payment While Auto-Deactivated

**Scenario**: User reaches 500K threshold and gets auto-deactivated, then submits payment.

**Handling:**
```javascript
async function handleAutoDeactivatedPayment(userId, paymentAmount) {
  const balance = await getUserPenaltyBalance(userId);
  const threshold = await getSetting('auto_deactivation_threshold');

  // Allow payment submission even if deactivated
  await processPayment(userId, paymentAmount);

  // Check if payment brings balance below threshold
  const newBalance = balance - paymentAmount;

  if (newBalance < threshold) {
    // Don't auto-reactivate - requires manual admin action
    await notifyAdmin({
      type: 'REACTIVATION_ELIGIBLE',
      userId,
      oldBalance: balance,
      newBalance,
      message: `User ${userId} paid ${paymentAmount} and is now below deactivation threshold. Manual reactivation needed.`
    });

    await notifyUser(userId, {
      type: 'REACTIVATION_PENDING',
      message: 'Your payment has been received. Admin will review your account for reactivation.'
    });
  }
}
```

**User Experience:**
- Deactivated users can still submit payments
- Cannot submit new reports until reactivated
- Clear message about reactivation process
- Admin receives notification when balance drops below threshold

## Penalty Calculation Edge Cases

### 1. Penalty Calculation Error

**Scenario**: System error occurs during automated penalty calculation.

**Error Handling:**
```javascript
async function calculateDailyPenalties() {
  const users = await getUsersRequiringPenalty();
  const errors = [];

  for (const user of users) {
    try {
      await calculateUserPenalty(user.id);
    } catch (error) {
      // Log error but continue processing other users
      await logError({
        type: 'PENALTY_CALCULATION_ERROR',
        userId: user.id,
        error: error.message,
        stackTrace: error.stack
      });

      errors.push({ userId: user.id, error });

      // Send notification to admin
      await notifyAdmin({
        type: 'PENALTY_ERROR',
        userId: user.id,
        error: error.message
      });

      // Skip this user's penalty (admin will handle manually)
      continue;
    }
  }

  if (errors.length > 0) {
    await sendErrorSummaryToAdmin(errors);
  }
}
```

**Recovery:**
- Admin receives notification of failed calculations
- Admin can manually calculate and add penalty
- System logs error for debugging
- User is not penalized on error (better than double-penalizing)

### 2. Auto-Deactivation at Exactly 500,000

**Scenario**: User's balance reaches exactly the threshold amount.

**Implementation:**
```javascript
async function checkAutoDeactivation(userId, newBalance) {
  const threshold = await getSetting('auto_deactivation_threshold');

  // Use >= for threshold check (includes exact match)
  if (newBalance >= threshold) {
    await deactivateUser(userId);

    await sendNotification(userId, {
      type: 'account_deactivated',
      message: `Your penalty balance has reached ${threshold}. Your account has been automatically deactivated.`
    });

    await notifyAdmin({
      type: 'USER_AUTO_DEACTIVATED',
      userId,
      balance: newBalance,
      threshold
    });

    return true;
  }

  return false;
}
```

**Edge Case Examples:**
- Balance = 499,500, Penalty = 500 → New Balance = 500,000 → **Deactivated**
- Balance = 500,000, Payment = 10,000 → New Balance = 490,000 → **Not auto-reactivated**
- Balance = 495,000 → Warning notification sent

### 3. New Member Penalty Exemption

**Scenario**: User transitions from 'new' to 'exclusive' membership mid-day.

**Handling:**
```javascript
async function shouldCalculatePenalty(user, date) {
  // Check membership status at the time of the report date
  const accountAge = moment(date).diff(moment(user.created_at), 'days');

  if (accountAge <= 30) {
    // Was still a new member on that date
    return false;
  }

  // Other penalty checks...
  return true;
}
```

**Rule**: Membership status is determined based on account age **at the date of the report**, not current status.

### 4. Penalty for Fractional Deed Miss

**Scenario**: User submits 0.7 for Sunnah prayers (target is 1.0).

**Calculation:**
```javascript
function calculatePenalty(missed) {
  const penaltyPerDeed = 5000;
  const penaltyPerFraction = 500; // per 0.1

  // missed = 0.3 (target 1.0 - actual 0.7)
  const penalty = missed * penaltyPerDeed;
  // penalty = 0.3 * 5000 = 1500

  return penalty;
}
```

**Validation:**
- 1 deed missed = 5,000 shillings
- 0.1 deed missed = 500 shillings
- 0.5 deed missed = 2,500 shillings
- Always use Decimal library to avoid floating-point errors

## Grace Period Boundary Conditions

### 1. Submission at Exact Grace Period End Time

**Scenario**: User submits report at exactly 12:00:00 PM (grace period end).

**Implementation:**
```javascript
function isWithinGracePeriod(reportDate, submissionTime) {
  const gracePeriodHours = 12; // configurable
  const gracePeriodEnd = moment(reportDate)
    .add(1, 'day')
    .add(gracePeriodHours, 'hours');

  // Use isSameOrBefore to include exact boundary
  return moment(submissionTime).isSameOrBefore(gracePeriodEnd);
}

// Example:
// Report date: 2025-10-21
// Grace period ends: 2025-10-22 12:00:00
// Submission at: 2025-10-22 12:00:00 → ACCEPTED
// Submission at: 2025-10-22 12:00:01 → REJECTED
```

### 2. Midnight Boundary Handling

**Scenario**: User submits report at 11:59:59 PM vs 12:00:00 AM.

**Implementation:**
```javascript
function getReportDate(submissionTime) {
  // Reports before midnight belong to that day
  // Reports at/after midnight belong to next day

  const time = moment(submissionTime);

  if (time.hour() === 0 && time.minute() === 0 && time.second() === 0) {
    // Exactly midnight - belongs to new day
    return time.format('YYYY-MM-DD');
  }

  // Before midnight - belongs to current day
  return time.format('YYYY-MM-DD');
}

// 2025-10-21 23:59:59 → Report date: 2025-10-21
// 2025-10-22 00:00:00 → Report date: 2025-10-22
```

### 3. Grace Period Configuration Change

**Scenario**: Admin changes grace period from 12 hours to 6 hours mid-day.

**Handling:**
```javascript
// Store grace period value with each penalty calculation
async function calculatePenalty(user, date) {
  const gracePeriodHours = await getSetting('grace_period_hours');

  const penalty = {
    user_id: user.id,
    date_incurred: date,
    amount: calculatedAmount,
    grace_period_applied: gracePeriodHours, // snapshot
    calculated_at: new Date()
  };

  await savePenalty(penalty);
}

// When validating submissions, use current setting
// When viewing historical penalties, show setting that was active
```

## User Status Transitions

### 1. Pending to Active Approval

**Scenario**: User is approved while actively using the app.

**Implementation:**
```dart
// Listen to user status changes
void listenToUserStatus() {
  supabase
    .from('users')
    .stream(primaryKey: ['id'])
    .eq('id', currentUserId)
    .listen((data) {
      final newStatus = data[0]['account_status'];

      if (newStatus == 'active' && currentStatus == 'pending') {
        // User was just approved
        showApprovalDialog();
        refreshAppData();
        navigateToHome();
      }

      currentStatus = newStatus;
    });
}
```

### 2. Active to Suspended Transition

**Scenario**: Admin suspends user who has active draft or pending submission.

**Handling:**
```javascript
async function suspendUser(userId, reason) {
  await db.transaction(async (trx) => {
    // Update user status
    await trx('users')
      .where({ id: userId })
      .update({
        account_status: 'suspended',
        suspended_at: new Date(),
        suspension_reason: reason
      });

    // Handle active drafts - mark as abandoned
    await trx('reports')
      .where({ user_id: userId, status: 'draft' })
      .update({
        status: 'abandoned',
        abandoned_at: new Date()
      });

    // Notify user
    await sendNotification(userId, {
      type: 'account_suspended',
      reason
    });
  });
}
```

**User Experience:**
- User sees suspension message on next action
- Cannot submit new reports or payments
- Can view historical data (read-only)
- Cannot log in until reactivated

### 3. Membership Status Auto-Upgrade

**Scenario**: User crosses 30-day or 3-year threshold.

**Cron Job:**
```javascript
async function updateMembershipStatuses() {
  await db.raw(`
    UPDATE users
    SET membership_status = CASE
      WHEN CURRENT_DATE - created_at::date <= 30 THEN 'new'
      WHEN CURRENT_DATE - created_at::date <= 1095 THEN 'exclusive'
      ELSE 'legacy'
    END
    WHERE account_status = 'active'
  `);

  // Send congratulations to newly upgraded members
  const newlyExclusive = await getNewlyUpgradedUsers('exclusive');
  for (const user of newlyExclusive) {
    await sendNotification(user.id, {
      type: 'membership_upgraded',
      newStatus: 'exclusive'
    });
  }
}
```

**Impact:**
- New → Exclusive: Penalties now applied
- Exclusive → Legacy: No functional change, just recognition
- Notification sent on upgrade

## Network Failures and Retry Logic

### 1. Submission During Network Outage

**Scenario**: User submits report but network fails mid-request.

**Handling:**
```dart
class ReportSubmissionService {
  Future<void> submitReport(Report report) async {
    try {
      await api.submitReport(report);
    } on SocketException {
      // Network error - save as draft and queue
      await saveDraftLocally(report);
      await queueForSync(report);

      throw NetworkException(
        'Connection lost. Your report has been saved as draft.',
        canRetry: true
      );
    } on TimeoutException {
      // Timeout - might have been submitted
      await verifySubmissionStatus(report);
    }
  }

  Future<void> verifySubmissionStatus(Report report) async {
    try {
      final exists = await api.checkReportExists(report.userId, report.date);

      if (exists) {
        // Was actually submitted
        await markReportAsSubmitted(report);
      } else {
        // Not submitted - queue for retry
        await queueForSync(report);
      }
    } catch (e) {
      // Can't verify - assume not submitted
      await queueForSync(report);
    }
  }
}
```

### 2. Retry Logic with Exponential Backoff

**Implementation:**
```javascript
async function submitWithRetry(operation, maxRetries = 3) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      return await operation();
    } catch (error) {
      attempt++;

      if (attempt >= maxRetries) {
        throw new Error(`Failed after ${maxRetries} attempts: ${error.message}`);
      }

      if (!isRetryableError(error)) {
        throw error; // Don't retry client errors
      }

      // Exponential backoff: 1s, 2s, 4s
      const delay = Math.pow(2, attempt) * 1000;
      await sleep(delay);
    }
  }
}

function isRetryableError(error) {
  const retryableCodes = [
    'ECONNRESET',
    'ETIMEDOUT',
    'ENOTFOUND',
    'ENETUNREACH',
    408, // Request Timeout
    429, // Too Many Requests
    500, // Internal Server Error
    502, // Bad Gateway
    503, // Service Unavailable
    504  // Gateway Timeout
  ];

  return retryableCodes.includes(error.code) ||
         retryableCodes.includes(error.statusCode);
}
```

### 3. Offline Queue Management

**Queue Processing:**
```javascript
class SyncQueue {
  async processQueue() {
    const operations = await getQueuedOperations();

    for (const op of operations) {
      if (!(await hasConnection())) {
        break; // Stop if connection lost
      }

      try {
        await this.executeOperation(op);
        await this.removeFromQueue(op.id);
      } catch (error) {
        op.retryCount++;

        if (op.retryCount >= op.maxRetries) {
          await this.moveToFailedQueue(op);
        } else {
          await this.updateRetryCount(op.id, op.retryCount);
        }
      }
    }
  }
}
```

## Timezone and Date Handling

### 1. Single Timezone System

**Implementation:**
```javascript
// All dates stored in East Africa Time (EAT) UTC+3
const SYSTEM_TIMEZONE = 'Africa/Nairobi';

function getSystemDate(date = new Date()) {
  return moment.tz(date, SYSTEM_TIMEZONE);
}

function getCurrentSystemDate() {
  return getSystemDate().format('YYYY-MM-DD');
}

// User's local timezone doesn't matter
// All deadline calculations use system timezone
function getGracePeriodEnd(reportDate) {
  return moment.tz(reportDate, SYSTEM_TIMEZONE)
    .add(1, 'day')
    .add(12, 'hours'); // 12 PM EAT
}
```

**User Experience:**
- Display all times with timezone indicator
- "Grace period ends at 12:00 PM EAT"
- Convert to user's local time for display (optional)
- All server calculations use system timezone

### 2. Daylight Saving Time (DST)

**Note**: East Africa Time (EAT) does **not** observe DST.

**If Supporting Multiple Timezones:**
```javascript
// Handle DST transitions
function getGracePeriodEnd(reportDate, timezone) {
  return moment.tz(reportDate, timezone)
    .add(1, 'day')
    .hour(12)
    .minute(0)
    .second(0);
  // moment.js handles DST automatically
}
```

### 3. Report Date vs Submission Date

**Distinction:**
```javascript
class Report {
  date: Date;           // The day being reported (e.g., 2025-10-21)
  submitted_at: Date;   // When report was submitted (e.g., 2025-10-22 11:45 AM)
  created_at: Date;     // When draft was created
}

// Penalty calculation uses report.date
// Grace period check uses report.submitted_at
```

## Race Conditions and Concurrency

### 1. Concurrent Report Updates

**Scenario**: User updates draft from multiple devices simultaneously.

**Solution - Last Write Wins with Version:**
```javascript
class Report {
  id: string;
  version: number;  // Incremented on each update
  updated_at: Date;
}

async function updateReport(reportId, changes, expectedVersion) {
  const updated = await db('reports')
    .where({
      id: reportId,
      version: expectedVersion
    })
    .update({
      ...changes,
      version: expectedVersion + 1,
      updated_at: new Date()
    });

  if (updated === 0) {
    throw new ConcurrencyError({
      code: 'VERSION_CONFLICT',
      message: 'Report was updated by another device. Please refresh and try again.'
    });
  }
}
```

### 2. Statistics Recalculation Conflicts

**Scenario**: Multiple operations trigger statistics recalculation simultaneously.

**Solution - Advisory Locks:**
```javascript
async function recalculateUserStatistics(userId) {
  // Acquire advisory lock
  const lockId = generateLockId(userId);

  await db.raw('SELECT pg_advisory_lock(?)', [lockId]);

  try {
    // Perform recalculation
    const stats = await calculateStatistics(userId);
    await saveStatistics(userId, stats);
  } finally {
    // Release lock
    await db.raw('SELECT pg_advisory_unlock(?)', [lockId]);
  }
}
```

### 3. Leaderboard Caching

**Scenario**: Multiple users request leaderboard simultaneously during peak time.

**Solution - Materialized View with Periodic Refresh:**
```sql
-- Create materialized view
CREATE MATERIALIZED VIEW leaderboard_cache AS
SELECT
  u.id,
  u.full_name,
  COALESCE(s.total_deeds_submitted, 0) as total_deeds,
  COALESCE(s.current_streak_days, 0) as current_streak,
  ROW_NUMBER() OVER (ORDER BY total_deeds DESC, current_streak DESC) as rank
FROM users u
LEFT JOIN user_statistics s ON u.id = s.user_id
WHERE u.account_status = 'active';

-- Create index
CREATE INDEX idx_leaderboard_cache_rank ON leaderboard_cache(rank);

-- Refresh every 5 minutes (cron job)
REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_cache;
```

## Data Validation and Sanitization

### 1. Email Validation

**Implementation:**
```javascript
function validateEmail(email) {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!emailRegex.test(email)) {
    throw new ValidationError('Invalid email format');
  }

  // Normalize
  return email.toLowerCase().trim();
}
```

### 2. Password Strength Requirements

**Validation:**
```javascript
function validatePassword(password) {
  const errors = [];

  if (password.length < 8) {
    errors.push('Password must be at least 8 characters');
  }

  if (!/[A-Z]/.test(password)) {
    errors.push('Password must contain at least one uppercase letter');
  }

  if (!/[a-z]/.test(password)) {
    errors.push('Password must contain at least one lowercase letter');
  }

  if (!/[0-9]/.test(password)) {
    errors.push('Password must contain at least one number');
  }

  if (errors.length > 0) {
    throw new ValidationError({
      code: 'WEAK_PASSWORD',
      message: 'Password does not meet requirements',
      details: errors
    });
  }
}
```

### 3. SQL Injection Prevention

**Always Use Parameterized Queries:**
```javascript
// ❌ BAD - Vulnerable to SQL injection
const query = `SELECT * FROM users WHERE email = '${userInput}'`;

// ✅ GOOD - Parameterized query
const query = 'SELECT * FROM users WHERE email = ?';
const result = await db.raw(query, [userInput]);

// ✅ GOOD - Query builder (Supabase/Knex)
const result = await supabase
  .from('users')
  .select('*')
  .eq('email', userInput);
```

### 4. XSS Prevention

**Input Sanitization:**
```javascript
const sanitizeHtml = require('sanitize-html');

function sanitizeUserInput(input) {
  return sanitizeHtml(input, {
    allowedTags: [], // No HTML tags allowed
    allowedAttributes: {}
  });
}

// Use for all user-generated content
const cleanName = sanitizeUserInput(userInput.name);
const cleanReason = sanitizeUserInput(excuseInput.reason);
```

### 5. Amount Validation

**Implementation:**
```javascript
function validateAmount(amount) {
  // Must be positive number
  if (typeof amount !== 'number' || amount <= 0) {
    throw new ValidationError('Amount must be a positive number');
  }

  // No more than 2 decimal places
  if (!/^\d+(\.\d{1,2})?$/.test(amount.toString())) {
    throw new ValidationError('Amount cannot have more than 2 decimal places');
  }

  // Reasonable maximum (1 million)
  if (amount > 1000000) {
    throw new ValidationError('Amount exceeds maximum allowed value');
  }

  return amount;
}
```

## Draft Management Edge Cases

### 1. Draft Expiration During Editing

**Scenario**: User is editing draft when grace period expires.

**Handling:**
```dart
class DraftEditScreen extends StatefulWidget {
  Timer? _gracePeriodChecker;

  @override
  void initState() {
    super.initState();

    // Check grace period every minute
    _gracePeriodChecker = Timer.periodic(
      Duration(minutes: 1),
      (_) => _checkGracePeriod()
    );
  }

  void _checkGracePeriod() {
    if (isGracePeriodExpired(widget.draft.date)) {
      _showGracePeriodExpiredDialog();
      _disableSubmitButton();
    }
  }

  void _showGracePeriodExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Grace Period Expired'),
        content: Text(
          'The grace period for this date has ended. '
          'Your draft has been saved but cannot be submitted. '
          'Contact admin if you need to submit for this date.'
        ),
        actions: [
          TextButton(
            child: Text('Contact Admin'),
            onPressed: () => contactAdminForPastDate(),
          ),
          TextButton(
            child: Text('Discard Draft'),
            onPressed: () => discardDraft(),
          ),
        ],
      ),
    );
  }
}
```

### 2. Multiple Drafts for Same Date

**Prevention:**
```javascript
async function createOrUpdateDraft(userId, date, deedValues) {
  // Check for existing draft
  const existing = await db('reports')
    .where({
      user_id: userId,
      date: date,
      status: 'draft'
    })
    .first();

  if (existing) {
    // Update existing draft
    return await db('reports')
      .where({ id: existing.id })
      .update({
        deed_values: deedValues,
        updated_at: new Date()
      });
  }

  // Create new draft
  return await db('reports').insert({
    user_id: userId,
    date: date,
    deed_values: deedValues,
    status: 'draft'
  });
}
```

### 3. Draft Auto-Save Conflicts

**Scenario**: Auto-save triggers while user is manually saving.

**Solution - Debouncing:**
```dart
class DraftAutoSave {
  Timer? _debounceTimer;

  void onDeedValueChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new timer (save after 2 seconds of inactivity)
    _debounceTimer = Timer(Duration(seconds: 2), () {
      _saveDraft();
    });
  }

  Future<void> _saveDraft() async {
    if (_isSaving) return; // Skip if already saving

    _isSaving = true;
    try {
      await draftService.saveDraft(currentDraft);
    } finally {
      _isSaving = false;
    }
  }
}
```

## Excuse Mode Edge Cases

### 1. Excuse Submitted After Penalty Applied

**Scenario**: User enables excuse mode and submits excuse after penalty was already calculated.

**Handling:**
```javascript
async function approveExcuse(excuseId) {
  const excuse = await getExcuse(excuseId);

  await db.transaction(async (trx) => {
    // Mark excuse as approved
    await trx('excuses')
      .where({ id: excuseId })
      .update({ status: 'approved' });

    // Check if penalty exists for this date
    const penalty = await trx('penalties')
      .where({
        user_id: excuse.user_id,
        date_incurred: excuse.date,
        status: 'unpaid'
      })
      .first();

    if (penalty) {
      // Retroactively waive penalty
      await trx('penalties')
        .where({ id: penalty.id })
        .update({
          status: 'waived',
          waived_at: new Date(),
          waived_reason: `Excuse approved: ${excuse.reason}`
        });

      // Recalculate user balance
      await recalculateUserBalance(excuse.user_id, trx);

      // Notify user
      await sendNotification(excuse.user_id, {
        type: 'penalty_waived',
        amount: penalty.amount,
        date: excuse.date
      });
    }
  });
}
```

### 2. Excuse Mode Enabled But No Excuse Submitted

**Scenario**: User enables excuse mode but forgets to submit excuse before deadline.

**Handling:**
```javascript
// Grace period for excuse submission: same as report grace period
async function checkMissingExcuses() {
  const yesterday = moment().subtract(1, 'day').format('YYYY-MM-DD');

  // Find users with excuse mode enabled but no excuse submitted
  const users = await db('users')
    .where({ excuse_mode_enabled: true })
    .whereNotExists(function() {
      this.select('*')
        .from('excuses')
        .whereRaw('excuses.user_id = users.id')
        .where('date', yesterday);
    })
    .whereNotExists(function() {
      this.select('*')
        .from('reports')
        .whereRaw('reports.user_id = users.id')
        .where('date', yesterday)
        .where('status', 'submitted');
    });

  for (const user of users) {
    // Apply penalty (no excuse submitted)
    await calculateUserPenalty(user.id, yesterday);

    // Send reminder notification
    await sendNotification(user.id, {
      type: 'excuse_mode_reminder',
      message: 'Excuse mode is enabled but no excuse was submitted. Penalty applied.'
    });
  }
}
```

### 3. Partial Excuse for Specific Deeds

**Scenario**: User submits excuse for only 2 out of 10 deeds.

**Calculation:**
```javascript
async function calculatePenaltyWithExcuse(user, date) {
  const excuse = await getApprovedExcuse(user.id, date);

  if (!excuse) {
    // No excuse - calculate full penalty
    return await calculateFullPenalty(user, date);
  }

  // Calculate penalty only for non-excused deeds
  const totalTarget = 10;
  const excusedDeeds = excuse.excused_deeds.length; // e.g., 2 deeds
  const effectiveTarget = totalTarget - excusedDeeds; // 8 deeds

  const report = await getReport(user.id, date);
  const actual = report ? report.deed_total : 0;

  // Only penalize for non-excused missed deeds
  const missed = Math.max(0, effectiveTarget - actual);
  const penalty = missed * 5000;

  return penalty;
}
```

## Error Messages and User Feedback

### Error Message Best Practices

**1. Be Specific and Actionable**
```javascript
// ❌ BAD
"An error occurred"

// ✅ GOOD
"Connection lost. Your report has been saved as draft and will be submitted automatically when connection is restored."
```

**2. Provide Context**
```javascript
// ❌ BAD
"Invalid input"

// ✅ GOOD
"Value must be between 0 and 1. You entered: 1.5"
```

**3. Offer Solutions**
```javascript
// ❌ BAD
"Payment failed"

// ✅ GOOD
"Payment amount (15,000) exceeds your balance (10,000). Please enter an amount up to 10,000."
```

### User-Friendly Error Messages

```dart
class ErrorMessages {
  static String getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'GRACE_PERIOD_EXPIRED':
        return 'Grace period has ended for this date. Contact admin to enable submission.';

      case 'DUPLICATE_REPORT':
        return 'You have already submitted a report for this date.';

      case 'PAYMENT_EXCEEDS_BALANCE':
        return 'Payment amount exceeds your penalty balance. Please adjust the amount.';

      case 'EXCUSE_NOT_FOUND':
        return 'No excuse found for this date. Please submit an excuse first.';

      case 'NETWORK_ERROR':
        return 'Connection lost. Your changes have been saved locally and will sync when connection is restored.';

      case 'UNAUTHORIZED':
        return 'Your session has expired. Please log in again.';

      case 'PERMISSION_DENIED':
        return 'You do not have permission to perform this action.';

      default:
        return 'An unexpected error occurred. Please try again or contact support.';
    }
  }
}
```

### Error Logging for Debugging

```javascript
async function logError(error, context) {
  const errorLog = {
    timestamp: new Date(),
    level: 'error',
    user_id: context.userId,
    endpoint: context.endpoint,
    method: context.method,
    error_message: error.message,
    stack_trace: error.stack,
    request_body: context.requestBody,
    response_code: context.responseCode,
    user_agent: context.userAgent,
    ip_address: context.ipAddress
  };

  await db('error_logs').insert(errorLog);

  // Send to error monitoring service
  Sentry.captureException(error, {
    contexts: { custom: context }
  });
}
```

---

## Testing Edge Cases

### Test Cases Checklist

**Report Submission:**
- [ ] Submit after grace period
- [ ] Duplicate submission for same date
- [ ] Submit for rest day
- [ ] Fractional deed with invalid value
- [ ] Network failure during submission
- [ ] Draft expiration during editing

**Payment Processing:**
- [ ] Payment exceeds balance
- [ ] Concurrent payment approvals
- [ ] Payment while auto-deactivated
- [ ] Zero or negative payment amount
- [ ] FIFO application with partial payments

**Penalty Calculation:**
- [ ] New member exemption
- [ ] Approved excuse waives penalty
- [ ] Penalty calculation error handling
- [ ] Auto-deactivation at exact threshold
- [ ] Fractional deed penalty accuracy

**User Status:**
- [ ] Membership status transitions
- [ ] Suspension with active drafts
- [ ] Approval while user is active
- [ ] Status changes affecting permissions

**Concurrency:**
- [ ] Concurrent draft updates
- [ ] Simultaneous payment approvals
- [ ] Race condition in statistics calculation
- [ ] Multiple excuse approvals

---

## Related Documentation

- [04-offline-support.md](./04-offline-support.md) - Offline and network error handling
- [05-testing.md](./05-testing.md) - Testing strategies for edge cases
- [03-database-schema.md](./03-database-schema.md) - Database constraints and validation
- [02-api-specification.md](./02-api-specification.md) - API error responses

---

**Last Updated**: 2025-10-22
**Version**: 1.0
