# Web Admin Payment Approval - FIFO Implementation

## Overview
Updated the Next.js web admin payment approval process to match the Flutter mobile app's FIFO (First In, First Out) implementation exactly.

## Changes Made

### File: `sabiquun-web/src/app/dashboard/payments/page.tsx`

### 1. Payment Approval Process (handleApprove)

The approval process now follows these steps:

#### Step 1: Get Payment Details
```typescript
const paymentId = selectedPayment.id
const userId = selectedPayment.user_id
let remainingAmount = selectedPayment.amount
```

#### Step 2: Fetch Unpaid/Partially Paid Penalties (FIFO Order)
```typescript
const { data: penalties } = await supabase
  .from('penalties')
  .select('id, amount, paid_amount, status, date_incurred')
  .eq('user_id', userId)
  .in('status', ['unpaid', 'partially_paid'])
  .order('date_incurred', { ascending: true }) // FIFO: Oldest first
```

#### Step 3: Apply Payment to Penalties Using FIFO
For each penalty (oldest first):
- Calculate remaining penalty amount: `penaltyRemaining = penaltyAmount - paidAmount`
- Calculate amount to apply: `amountToApply = Math.min(remainingAmount, penaltyRemaining)`
- Create `penalty_payments` junction record linking payment to penalty
- Update penalty with:
  - New `paid_amount` = `paidAmount + amountToApply`
  - New `status`:
    - `'paid'` if fully paid
    - `'partially_paid'` if partially paid
    - `'unpaid'` otherwise
- Subtract from remaining payment amount

#### Step 4: Update Payment Status
```typescript
await supabase
  .from('payments')
  .update({
    status: 'approved',
    reviewed_by: profile.id,
    reviewed_at: new Date().toISOString(),
  })
  .eq('id', paymentId)
```

#### Step 5: Recalculate User Statistics
```typescript
// Get all user penalties
const totalIncurred = allPenalties.reduce((sum, p) => sum + p.amount, 0)
const totalPaid = allPenalties.reduce((sum, p) => sum + p.paid_amount, 0)
const currentBalance = totalIncurred - totalPaid

// Update user_statistics
await supabase
  .from('user_statistics')
  .update({
    total_penalties_paid: totalPaid,
    current_penalty_balance: currentBalance,
  })
  .eq('user_id', userId)
```

#### Step 6: Log Audit Trail
```typescript
await supabase.from('audit_logs').insert({
  action_type: 'payment_approved',
  performed_by: profile.id,
  user_id: userId,
  entity_type: 'payment',
  entity_id: paymentId,
  reason: 'Payment approved and applied to penalties using FIFO',
  description: `Payment of ${amount} SOS approved and applied to penalties`,
})
```

### 2. Payment Rejection Process (handleReject)

#### Updated to include:
- Proper error handling with try-catch
- Validation of rejection reason (trim whitespace)
- Audit trail logging:
```typescript
await supabase.from('audit_logs').insert({
  action_type: 'payment_rejected',
  performed_by: profile.id,
  user_id: userId,
  entity_type: 'payment',
  entity_id: paymentId,
  reason: rejectionReason.trim(),
  description: `Payment of ${amount} SOS rejected`,
})
```

## FIFO Example

**User has penalties:**
- Jan 5: 10,000 SOS (unpaid)
- Jan 8: 15,000 SOS (unpaid)
- Jan 12: 20,000 SOS (unpaid)
- **Total: 45,000 SOS**

**User pays: 30,000 SOS**

**FIFO Application:**
1. Jan 5 penalty: Apply 10,000 → Status: `paid` (remaining: 20,000)
2. Jan 8 penalty: Apply 15,000 → Status: `paid` (remaining: 5,000)
3. Jan 12 penalty: Apply 5,000 → Status: `partially_paid` (remaining: 0)

**Final user balance: 15,000 SOS**

## Database Tables Involved

1. **payments** - Payment record with status, reviewed_by, reviewed_at
2. **penalties** - Penalty records with paid_amount and status updates
3. **penalty_payments** - Junction table linking payments to penalties (FIFO tracking)
4. **user_statistics** - Updated current_penalty_balance and total_penalties_paid
5. **audit_logs** - Complete audit trail of approval/rejection actions

## Consistency with Flutter App

The web implementation now matches the Flutter mobile app exactly:
- ✅ Same FIFO algorithm
- ✅ Same penalty status logic (unpaid → partially_paid → paid)
- ✅ Same database operations sequence
- ✅ Same audit logging
- ✅ Same user_statistics recalculation

## References

- Flutter Implementation: `sabiquun_app/lib/features/payments/data/datasources/payment_remote_datasource.dart` (lines 344-431)
- Documentation: `docs/features/04-payment-system.md`
- Database Schema: `docs/database/01-schema.md`
- Business Logic: `docs/database/02-business-logic.md`

## Future Enhancements

- [ ] Send notification to user after approval/rejection (TODO in both Flutter and web)
- [ ] Add email notification support
- [ ] Add WhatsApp notification integration (if available)

---

**Date:** 2026-02-03  
**Status:** ✅ Implemented
