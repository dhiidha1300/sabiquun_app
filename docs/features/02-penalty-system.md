# Penalty System

The penalty system provides financial accountability for missed deeds, calculated automatically and managed by administrators.

## Penalty Calculation

### Base Rate

| Missed Amount | Penalty | Formula |
|---------------|---------|---------|
| 0.1 deed | 500 shillings | 0.1 × 5,000 |
| 0.5 deed | 2,500 shillings | 0.5 × 5,000 |
| 1.0 deed | 5,000 shillings | 1.0 × 5,000 |
| 2.0 deeds | 10,000 shillings | 2.0 × 5,000 |
| 10.0 deeds (no report) | 50,000 shillings | 10.0 × 5,000 |

**Formula:** `Penalty = (Target - Actual) × 5,000`

**Configurable:** Admin can change the penalty per deed (default: 5,000 shillings)

---

## Penalty Trigger Time

### When Penalties Are Calculated

**Time:** 12 PM (noon) after the reporting day
- Grace period ends at 12 PM
- System runs automatic penalty calculation
- Applied to all eligible users

### Exemptions from Penalties

Penalties are **NOT applied** if:

1. ✅ **User is a New Member** (first 30 days)
   - Training period, no financial consequences

2. ✅ **Day is a designated Rest Day**
   - Admin-configured rest days (e.g., Eid)

3. ✅ **User has an approved excuse** for that day
   - Excuse must be submitted and approved before penalty calculation

4. ✅ **User submitted a report meeting/exceeding target**
   - If user achieves ≥ 10.0 deeds (or current target)

---

## Penalty Accumulation

### Cumulative Balance

- **All unpaid penalties accumulate** into a single balance
- **User sees current total balance** on home screen
- **Balance updates in real-time** after payments or new penalties

### Balance Display

**Home Screen:**
```
┌─────────────────────────────────┐
│ Current Penalty Balance         │
│                                  │
│   125,500 shillings             │
│                                  │
│ [Pay Now]                        │
└─────────────────────────────────┘
```

**Color Coding:**
- Green: 0 - 50,000 (low)
- Yellow: 50,001 - 200,000 (medium)
- Orange: 200,001 - 400,000 (high)
- Red: 400,001+ (critical, approaching deactivation)

---

## Auto-Deactivation

### Threshold

**Default:** 500,000 shillings (configurable by admin)

When a user's penalty balance reaches or exceeds this threshold:

### Automatic Actions

1. **Account status** changes to `auto_deactivated`
2. **User cannot** submit new reports or payments
3. **User can** view past data (read-only mode)
4. **Notification sent** to user: "Account Deactivated"
5. **Admin notified** of deactivation

### Reactivation Process

**Manual Reactivation Required:**
- User must contact admin
- Admin reviews account and circumstances
- Admin manually reactivates account
- Even if user pays below threshold, admin approval still needed

**Rationale:** Ensures oversight for high-penalty users and prevents system gaming.

---

## Warning System

### Warning Thresholds

**Default Thresholds:** [400,000, 450,000] shillings (configurable)

Users receive escalating warnings **before** auto-deactivation:

### Warning Notifications

**First Warning (400,000 shillings):**
```
⚠️ Account Deactivation Warning

Your balance is 400,000 shillings.
Account will be deactivated at 500,000.
Please pay immediately to avoid deactivation.

[Pay Now]
```

**Final Warning (450,000 shillings):**
```
🚨 URGENT: Account Deactivation Warning

Your balance is 450,000 shillings.
Only 50,000 away from automatic deactivation!
Pay now to keep your account active.

[Pay Now]
```

**Deactivation Notification:**
```
❌ Account Deactivated

Your account has been deactivated due to penalty balance of 500,000 shillings.
Contact admin for reactivation.

[Contact Admin]
```

---

## Penalty Management (Admin/Cashier)

### Manual Adjustments

Admins and Cashiers can manually adjust penalties:

#### Add Penalty
- **Use Case:** Correcting system errors, special circumstances
- **Required:** Amount, date, reason
- **Logged:** Audit trail

#### Remove Penalty
- **Use Case:** Incorrect penalty applied
- **Required:** Reason
- **Logged:** Audit trail

#### Waive Penalty
- **Use Case:** Grace, forgiveness, special circumstances
- **Required:** Reason
- **Logged:** Audit trail
- **Effect:** Penalty status changes to `waived`, balance reduced

#### Edit Penalty Amount
- **Use Case:** Correcting incorrect calculation
- **Required:** New amount, reason
- **Logged:** Audit trail with old/new values

### Audit Trail

All penalty changes are logged:

```json
{
  "action": "penalty_waived",
  "performed_by": "admin_uuid",
  "user_affected": "user_uuid",
  "entity_type": "penalty",
  "entity_id": "penalty_uuid",
  "old_value": {"status": "unpaid", "amount": 5000},
  "new_value": {"status": "waived", "amount": 0},
  "reason": "User demonstrated consistent improvement, waiving past penalty",
  "timestamp": "2025-10-22T14:30:00Z"
}
```

---

## Penalty Details Stored

### Database Schema

```sql
CREATE TABLE penalties (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  report_id UUID REFERENCES deeds_reports(id), -- Nullable for manual penalties
  amount DECIMAL(10,2) NOT NULL,
  date_incurred DATE NOT NULL,
  status VARCHAR(50) DEFAULT 'unpaid', -- 'unpaid', 'paid', 'waived'
  paid_amount DECIMAL(10,2) DEFAULT 0, -- For tracking partial payments
  waived_by UUID REFERENCES users(id),
  waived_reason TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Penalty Record Fields

| Field | Description |
|-------|-------------|
| **user_id** | User who incurred the penalty |
| **report_id** | Related report (null if manual penalty) |
| **amount** | Penalty amount in shillings |
| **date_incurred** | Date the penalty was incurred |
| **status** | Paid, Unpaid, or Waived |
| **paid_amount** | Amount paid so far (for partial payments) |
| **waived_by** | Admin/Cashier who waived it |
| **waived_reason** | Reason for waiving |
| **created_at** | When penalty was created |
| **updated_at** | Last modification time |

---

## Penalty Calculation Logic

### Automatic Calculation (Daily at 12 PM)

```javascript
async function calculateDailyPenalties() {
  const yesterday = getPreviousDay();
  const users = await getActiveUsers();

  for (const user of users) {
    // Skip if user is exempt
    if (shouldSkipPenalty(user, yesterday)) {
      continue;
    }

    // Get report for yesterday
    const report = await getReport(user.id, yesterday);
    const target = await getActiveDeedCount();
    const actual = report ? report.total_deeds : 0;
    const missed = target - actual;

    if (missed > 0) {
      const penaltyPerDeed = await getSetting('penalty_per_deed'); // 5000
      const penaltyAmount = missed * penaltyPerDeed;

      // Create penalty record
      await createPenalty({
        user_id: user.id,
        report_id: report?.id,
        amount: penaltyAmount,
        date_incurred: yesterday,
        status: 'unpaid'
      });

      // Update user balance
      await updateUserBalance(user.id);

      // Check for auto-deactivation
      const balance = await getUserBalance(user.id);
      await checkAutoDeactivation(user.id, balance);

      // Send notification
      await sendPenaltyNotification(user.id, penaltyAmount, missed, yesterday);
    }
  }
}

function shouldSkipPenalty(user, date) {
  // Skip if new member (first 30 days)
  if (user.membership_status === 'new') return true;

  // Skip if rest day
  if (isRestDay(date)) return true;

  // Skip if approved excuse
  if (hasApprovedExcuse(user.id, date)) return true;

  return false;
}

async function checkAutoDeactivation(userId, balance) {
  const threshold = await getSetting('auto_deactivation_threshold'); // 500000
  const warnings = await getSetting('warning_thresholds'); // [400000, 450000]

  if (balance >= threshold) {
    await deactivateUser(userId);
    await sendNotification(userId, 'account_deactivated', { balance });
  } else if (warnings.includes(balance)) {
    await sendNotification(userId, 'auto_deactivation_warning', { balance, threshold });
  }
}
```

---

## User Balance Calculation

### Calculating Current Balance

```javascript
async function getUserBalance(userId) {
  const penalties = await db.penalties.findMany({
    where: {
      user_id: userId,
      status: { in: ['unpaid', 'paid'] } // Exclude waived
    }
  });

  let balance = 0;
  for (const penalty of penalties) {
    const remaining = penalty.amount - penalty.paid_amount;
    balance += remaining;
  }

  return balance;
}
```

### Real-Time Balance Display

User's balance updates immediately after:
- New penalty applied
- Payment approved
- Penalty waived/removed by admin

---

## Penalty Breakdown View

Users can view detailed breakdown of their penalties:

```
┌──────────────────────────────────────────┐
│ Penalty Breakdown                         │
├──────────────────────────────────────────┤
│ Oct 15, 2025                              │
│ 2.5 deeds missed                          │
│ 12,500 shillings                          │
│ Status: Unpaid                            │
├──────────────────────────────────────────┤
│ Oct 18, 2025                              │
│ 1.0 deed missed                           │
│ 5,000 shillings                           │
│ Status: Paid                              │
├──────────────────────────────────────────┤
│ Oct 20, 2025                              │
│ 0.5 deed missed                           │
│ 2,500 shillings                           │
│ Status: Partially Paid (1,000 paid)      │
└──────────────────────────────────────────┘

Total Outstanding: 14,000 shillings
```

---

## API Endpoints

### Get User Penalties

```
GET /api/users/{userId}/penalties?status=unpaid
```

**Response:**
```json
{
  "penalties": [
    {
      "id": "uuid",
      "amount": 12500,
      "date_incurred": "2025-10-15",
      "status": "unpaid",
      "paid_amount": 0,
      "missed_deeds": 2.5,
      "report_id": "uuid"
    }
  ],
  "total_balance": 125000
}
```

### Get User Balance

```
GET /api/users/{userId}/balance
```

**Response:**
```json
{
  "balance": 125000,
  "unpaid_penalties_count": 5,
  "oldest_penalty_date": "2025-09-10",
  "approaching_deactivation": true,
  "threshold": 500000
}
```

### Manual Penalty Adjustment (Admin/Cashier)

```
POST /api/penalties/{penaltyId}/waive
```

**Request:**
```json
{
  "reason": "User demonstrated consistent improvement over past 30 days"
}
```

**Response:**
```json
{
  "penalty_id": "uuid",
  "status": "waived",
  "waived_by": "admin_uuid",
  "new_balance": 113000
}
```

---

## Edge Cases

### What if penalty calculation fails?
- Retry logic: 3 attempts with exponential backoff
- Alert admin if all retries fail
- Manual penalty creation option

### What if user is deactivated mid-day?
- User sees deactivation message immediately
- Can still view data (read-only)
- Cannot submit today's report

### What if admin changes penalty rate mid-month?
- New rate applies to penalties calculated after change
- Existing penalties retain original amount
- No retroactive recalculation

### What if user pays exactly to threshold?
- Balance of 500,000 triggers deactivation
- Balance of 499,999 does not
- System uses `>=` comparison

---

## Performance Considerations

- **Batch penalty calculation:** Process all users in parallel (chunked)
- **Index on date_incurred:** Fast queries for penalty history
- **Cache user balance:** Refresh only on balance-changing events
- **Async notifications:** Don't block penalty calculation

---

[← Back: Deed System](01-deed-system.md) | [Next: Excuse System →](03-excuse-system.md) | [Database Schema →](../database/01-schema.md)
