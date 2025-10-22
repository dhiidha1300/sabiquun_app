# Payment System

The payment system handles user payment submissions for penalties, admin review and approval, and automatic balance management using FIFO (First In, First Out) payment application.

## Payment Methods

### Default Methods

The system comes with two default mobile money payment methods:

1. **ZAAD** (Mobile Money)
2. **eDahab** (Mobile Money)

### Admin Configuration

Admins have full control over payment methods:

- **Add new payment methods** - Support for additional services
- **Edit method names and display names** - Customize for local preferences
- **Activate/deactivate methods** - Control which methods are available
- **Set sort order** - Define dropdown display order
- **Future-ready** - System stores methods in database for future API integration

## Payment Submission Flow (User)

### Step 1: Navigate to Payment Screen

The user views their payment information:

- Current penalty balance displayed prominently
- Breakdown of penalties (by date/amount)
- **Oldest penalties highlighted** (FIFO payment application)

**Example Display:**
```
┌──────────────────────────────────────────┐
│ Current Balance: 45,000 shillings       │
├──────────────────────────────────────────┤
│ Outstanding Penalties:                   │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
│ 📅 Jan 5  - 10,000 (OLDEST)            │
│ 📅 Jan 8  - 15,000                      │
│ 📅 Jan 12 - 20,000                      │
└──────────────────────────────────────────┘
```

### Step 2: Payment Form

The user fills out the payment form:

1. **Select payment method from dropdown**
   - ZAAD, eDahab, or other admin-configured methods

2. **Choose payment type:**
   - **Full Payment:** Pays entire balance (amount pre-filled, read-only)
   - **Partial Payment:** User enters custom amount

3. **Enter reference number** (optional)
   - Transaction ID from mobile money service
   - Helps with verification

4. **Review payment summary**
   - Amount, method, and which penalties will be covered

### Step 3: Submit Payment

1. User clicks **"Pay"** button
2. Confirmation dialog appears:
   ```
   Are you sure you want to submit payment of [amount]?
   ```
3. On confirmation, payment status changes to **Pending**

### Step 4: Thank You Screen

After successful submission, user sees:

```
✓ Payment is being processed

Proof of payment might be needed

You will be notified once payment is reviewed

[Return to Home]
```

### Step 5: Notification

- **Admin/Cashier** receives notification: "New payment submitted by [User]"
- **User** waits for approval

## Payment Review Flow (Admin/Cashier)

### Payment Dashboard

Admins and cashiers have access to a comprehensive dashboard:

**Features:**
- View all pending payments
- Filter by user, date, amount, status
- Search by reference number
- Sort by submission date

**Dashboard Layout:**
```
┌─────────────────────────────────────────────────────────┐
│ Payment Review Dashboard                                 │
├─────────────────────────────────────────────────────────┤
│ 🔍 Search: [Reference #] | Filter: [Status ▼] [User ▼] │
├─────────────────────────────────────────────────────────┤
│ PENDING PAYMENTS (12)                                    │
│ ───────────────────────────────────────────────────────│
│ John Doe      | 30,000 | ZAAD | Ref: 12345 | [Review]  │
│ Jane Smith    | 50,000 | eDahab | No ref   | [Review]  │
│ Bob Wilson    | 15,000 | ZAAD | Ref: 67890 | [Review]  │
└─────────────────────────────────────────────────────────┘
```

### Review Actions

#### Approve Payment

**Process:**
1. Verify payment externally (check mobile money account)
2. Click **"Approve"** in app
3. Amount deducted from user's penalty balance (FIFO - see below)
4. User receives notification: "Payment of [amount] approved"
5. Payment status: **Approved**

#### Reject Payment

**Process:**
1. Enter rejection reason
2. Click **"Reject"**
3. User receives notification with reason
4. Payment status: **Rejected**
5. Amount remains in user's penalty balance

### Manual Balance Clearing

Admins and cashiers can manually reduce a user's balance:

**Useful for:**
- Cash payments received in person
- Adjustments/corrections
- Forgiveness/grace periods

**Process:**
1. Enter amount to clear
2. Enter reason/notes
3. Confirm action
4. Logged in audit trail
5. User receives notification

## Payment Application (FIFO)

### How FIFO Works

**FIFO = First In, First Out** - Oldest penalties are paid first.

### Example Scenario

**User's Penalty Balance:**
```
Jan 5:  10,000 shillings (unpaid)
Jan 8:  15,000 shillings (unpaid)
Jan 12: 20,000 shillings (unpaid)
─────────────────────────────
Total:  45,000 shillings
```

**User pays: 30,000 shillings**

**Payment Distribution:**

| Date | Original Amount | Payment Applied | Remaining | Status |
|------|----------------|-----------------|-----------|---------|
| Jan 5 | 10,000 | 10,000 | 0 | ✓ Paid |
| Jan 8 | 15,000 | 15,000 | 0 | ✓ Paid |
| Jan 12 | 20,000 | 5,000 | 15,000 | ⏳ Partially Paid |

**Total balance after payment: 15,000 shillings**

### Database Records

When payment is applied:

1. **Create `penalty_payments` entries** linking payment to penalties
2. **Track amount applied** to each penalty
3. **Update penalty status** and `paid_amount` fields
4. **Maintain audit trail** for all transactions

**Schema Example:**
```sql
-- Payment application records
penalty_payments
  - id
  - payment_id (FK → payments)
  - penalty_id (FK → penalties)
  - amount_applied (decimal)
  - created_at

-- Updated penalty record
penalties
  - id
  - amount (decimal)
  - paid_amount (decimal) -- Updated via payment application
  - status (enum: unpaid, partially_paid, paid)
```

## Payment History

### User View

Users can view their complete payment history:

- List of all payments submitted
- Status badges (Pending/Approved/Rejected)
- Amount, date, payment method
- Reference number
- Reviewer name (if reviewed)
- **Download receipt option (PDF)**

**Example:**
```
┌────────────────────────────────────────────────┐
│ My Payment History                             │
├────────────────────────────────────────────────┤
│ Jan 15 | 30,000 | ZAAD | ✓ APPROVED            │
│        | Ref: 12345 | Reviewed by: Admin       │
│        | [Download Receipt]                     │
├────────────────────────────────────────────────┤
│ Jan 10 | 50,000 | eDahab | ✗ REJECTED          │
│        | No ref | Reason: Payment not found    │
├────────────────────────────────────────────────┤
│ Jan 8  | 15,000 | ZAAD | ⏳ PENDING            │
│        | Ref: 67890 | Awaiting review          │
└────────────────────────────────────────────────┘
```

### Admin/Cashier View

Enhanced view with additional features:

- **All users' payment history**
- **Advanced filters and search**
- **Export to Excel/PDF**
- **Analytics:**
  - Total received
  - Pending amount
  - Approval rate
  - Average processing time

**Analytics Dashboard:**
```
┌─────────────────────────────────────────────┐
│ Payment Analytics                           │
├─────────────────────────────────────────────┤
│ Total Received (This Month):  1,250,000    │
│ Pending Review:                  185,000    │
│ Approval Rate:                      94%     │
│ Avg. Processing Time:            2.3 hrs   │
└─────────────────────────────────────────────┘
```

## Payment Workflow Diagram

```
┌─────────────┐
│    User     │
│  Submits    │
│  Payment    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Pending    │
│   Status    │
└──────┬──────┘
       │
       ├──────────────┬──────────────┐
       ▼              ▼              ▼
┌──────────┐   ┌──────────┐   ┌──────────┐
│ Approved │   │ Rejected │   │ Awaiting │
│          │   │          │   │  Review  │
└────┬─────┘   └────┬─────┘   └──────────┘
     │              │
     ▼              ▼
┌──────────┐   ┌──────────┐
│ Balance  │   │ Balance  │
│ Reduced  │   │Unchanged │
│ (FIFO)   │   │          │
└──────────┘   └──────────┘
```

## API Endpoints Reference

```
POST   /api/payments              - Submit new payment
GET    /api/payments              - Get payment history
GET    /api/payments/:id          - Get payment details
PUT    /api/payments/:id/approve  - Approve payment (admin)
PUT    /api/payments/:id/reject   - Reject payment (admin)
POST   /api/payments/manual-clear - Manual balance clearing (admin)
GET    /api/payment-methods       - Get available payment methods
POST   /api/payment-methods       - Create payment method (admin)
PUT    /api/payment-methods/:id   - Update payment method (admin)
DELETE /api/payment-methods/:id   - Delete payment method (admin)
```

## Database Schema Reference

```sql
-- Payments table
payments
  - id
  - user_id (FK → users)
  - amount (decimal)
  - payment_method_id (FK → payment_methods)
  - reference_number (string, nullable)
  - status (enum: pending, approved, rejected)
  - reviewed_by (FK → users, nullable)
  - reviewed_at (timestamp, nullable)
  - rejection_reason (text, nullable)
  - created_at
  - updated_at

-- Payment methods table
payment_methods
  - id
  - name (string)
  - display_name (string)
  - is_active (boolean)
  - sort_order (integer)
  - created_at
  - updated_at

-- Penalty payments (junction table for FIFO)
penalty_payments
  - id
  - payment_id (FK → payments)
  - penalty_id (FK → penalties)
  - amount_applied (decimal)
  - created_at
```

## Security Considerations

- **Authorization:** Only admins/cashiers can approve/reject payments
- **Audit Trail:** All payment actions logged with timestamp and user
- **Validation:** Amount validation to prevent negative or zero payments
- **Idempotency:** Prevent duplicate payment submissions
- **Data Integrity:** FIFO application maintains accurate penalty tracking

---

[← Back: Excuse System](03-excuse-system.md) | [Next: Notification System →](05-notification-system.md) | [Main README](../../README.md)
