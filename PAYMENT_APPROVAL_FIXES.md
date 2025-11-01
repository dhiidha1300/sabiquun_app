# Payment Approval Error Fixes - Complete Guide

## 🐛 Issues Fixed

### Issue 1: RLS Policy Missing (Original Error)
```
PostgrestException(message: new row violates row-level security policy for table
"penalty_payments", code: 42501, details: Forbidden)
```

**Fix:** Run [fix_cashier_rls_policies.sql](fix_cashier_rls_policies.sql) in Supabase

---

### Issue 2: `updated_at` Column Not Found (Second Error)
```
PostgrestException(message: could not find the 'updated_at' column of 'payments'
in the schema cache, code: PGRST200, details: Bad gateway)
```

**Root Cause:** The `payments`, `penalties`, and `payment_methods` tables don't have an `updated_at` column in the database schema, but the code was trying to set it.

**Fix:** ✅ Removed all `updated_at` references from update queries

---

## ✅ Changes Made

### File Modified: `payment_remote_datasource.dart`

#### 1. **approvePayment() method** (Lines 296-309)
**Before:**
```dart
await _supabaseClient.from('penalties').update({
  'paid_amount': newPaidAmount,
  'status': newStatus,
  'updated_at': DateTime.now().toIso8601String(), // ❌ Column doesn't exist
}).eq('id', penaltyId);

await _supabaseClient.from('payments').update({
  'status': 'approved',
  'reviewed_by': reviewedBy,
  'reviewed_at': DateTime.now().toIso8601String(),
  'updated_at': DateTime.now().toIso8601String(), // ❌ Column doesn't exist
}).eq('id', paymentId);
```

**After:**
```dart
await _supabaseClient.from('penalties').update({
  'paid_amount': newPaidAmount,
  'status': newStatus, // ✅ Removed updated_at
}).eq('id', penaltyId);

await _supabaseClient.from('payments').update({
  'status': 'approved',
  'reviewed_by': reviewedBy,
  'reviewed_at': DateTime.now().toIso8601String(), // ✅ Removed updated_at
}).eq('id', paymentId);
```

#### 2. **rejectPayment() method** (Lines 333-338)
**Before:**
```dart
await _supabaseClient.from('payments').update({
  'status': 'rejected',
  'reviewed_by': reviewedBy,
  'reviewed_at': DateTime.now().toIso8601String(),
  'rejection_reason': reason,
  'updated_at': DateTime.now().toIso8601String(), // ❌ Column doesn't exist
}).eq('id', paymentId);
```

**After:**
```dart
await _supabaseClient.from('payments').update({
  'status': 'rejected',
  'reviewed_by': reviewedBy,
  'reviewed_at': DateTime.now().toIso8601String(),
  'rejection_reason': reason, // ✅ Removed updated_at
}).eq('id', paymentId);
```

#### 3. **manualBalanceClear() method** (Lines 437-440)
**Before:**
```dart
await _supabaseClient.from('penalties').update({
  'paid_amount': newPaidAmount,
  'status': newStatus,
  'updated_at': DateTime.now().toIso8601String(), // ❌ Column doesn't exist
}).eq('id', penaltyId);
```

**After:**
```dart
await _supabaseClient.from('penalties').update({
  'paid_amount': newPaidAmount,
  'status': newStatus, // ✅ Removed updated_at
}).eq('id', penaltyId);
```

#### 4. **updatePaymentMethod() method** (Lines 489-493)
**Before:**
```dart
await _supabaseClient.from('payment_methods').update({
  'display_name': displayName,
  'is_active': isActive,
  'sort_order': sortOrder,
  'updated_at': DateTime.now().toIso8601String(), // ❌ Column doesn't exist
}).eq('id', methodId);
```

**After:**
```dart
await _supabaseClient.from('payment_methods').update({
  'display_name': displayName,
  'is_active': isActive,
  'sort_order': sortOrder, // ✅ Removed updated_at
}).eq('id', methodId);
```

---

## 🚀 Complete Fix Checklist

### Step 1: Fix RLS Policies ⏳
1. Open Supabase SQL Editor
2. Copy contents of [fix_cashier_rls_policies.sql](fix_cashier_rls_policies.sql)
3. Paste and run in SQL Editor
4. Verify policies created successfully

### Step 2: Code Fixes ✅ DONE
- ✅ Removed `updated_at` from `approvePayment()`
- ✅ Removed `updated_at` from `rejectPayment()`
- ✅ Removed `updated_at` from `manualBalanceClear()`
- ✅ Removed `updated_at` from `updatePaymentMethod()`
- ✅ Code compiles with no errors

### Step 3: Test Payment Approval 🧪
1. Restart your Flutter app (hot reload won't be enough)
2. Navigate to Payment Review as cashier
3. Click "Approve" on a pending payment
4. Should succeed without errors!

---

## 🧪 Testing Guide

### Test 1: Create Test Payment

**Option A: Via App** (as regular user)
- Go to payment submission page
- Submit a payment with amount 50,000

**Option B: Via SQL** (in Supabase)
```sql
INSERT INTO payments (user_id, amount, payment_method, status, created_at)
VALUES (
  '<your-test-user-id>',
  50000,
  'ZAAD',
  'pending',
  NOW()
);
```

### Test 2: Approve Payment

1. **Login as cashier** (user with role='cashier' or 'admin')
2. **Navigate to Payment Review**:
   - From cashier home, tap "Pending Payments"
   - OR navigate to `/payment-review`
3. **Verify payment appears**:
   - ✅ Should see the pending payment
   - ✅ Should show user name and email
   - ✅ Should show payment method
   - ✅ Should show amount
4. **Click "Approve" button**
5. **Review details in dialog**:
   - User info displayed
   - Payment details shown
   - Action checklist visible
6. **Add optional notes** (e.g., "Payment verified via ZAAD")
7. **Click "Confirm Approval"**
8. **Verify success**:
   - ✅ Success snackbar appears: "✓ Payment approved successfully"
   - ✅ Payment disappears from pending list
   - ✅ No error message

### Test 3: Verify in Database

```sql
-- Check payment status changed
SELECT id, status, reviewed_by, reviewed_at
FROM payments
WHERE id = '<payment-id>';
-- Should show status='approved', reviewed_by filled, reviewed_at filled

-- Check penalty_payments records created (FIFO)
SELECT
  pp.id,
  pp.payment_id,
  pp.penalty_id,
  pp.amount_applied,
  p.date_incurred,
  p.amount as penalty_amount,
  p.paid_amount as penalty_paid,
  p.status as penalty_status
FROM penalty_payments pp
JOIN penalties p ON pp.penalty_id = p.id
WHERE pp.payment_id = '<payment-id>'
ORDER BY p.date_incurred;
-- Should show records with amounts applied to oldest penalties first

-- Check penalties were updated
SELECT
  id,
  date_incurred,
  amount,
  paid_amount,
  status
FROM penalties
WHERE user_id = '<user-id>'
ORDER BY date_incurred;
-- Should show paid_amount increased and status changed (paid/partially_paid)

-- Check audit log
SELECT *
FROM audit_logs
WHERE action = 'payment_approved'
AND entity_id = '<payment-id>';
-- Should show log entry with cashier id and timestamp
```

### Test 4: Reject Payment

1. **Create another test payment**
2. **Click "Reject" button**
3. **Enter rejection reason** (minimum 10 characters):
   - Example: "Invalid reference number. Payment not found in ZAAD system."
4. **Click "Confirm Rejection"**
5. **Verify success**:
   - ✅ Success snackbar appears: "✗ Payment rejected"
   - ✅ Payment disappears from pending list
   - ✅ No error message

### Test 5: Verify Rejection in Database

```sql
SELECT id, status, rejection_reason, reviewed_by, reviewed_at
FROM payments
WHERE id = '<payment-id>';
-- Should show status='rejected', rejection_reason filled

SELECT *
FROM audit_logs
WHERE action = 'payment_rejected'
AND entity_id = '<payment-id>';
-- Should show log entry
```

---

## 🎯 Expected Behavior After Fixes

### FIFO Payment Application Example

**User's Penalties Before Payment:**
```
Penalty 1: Jan 5  - 10,000 shillings (unpaid)
Penalty 2: Jan 8  - 15,000 shillings (unpaid)
Penalty 3: Jan 12 - 20,000 shillings (unpaid)
─────────────────────────────────────────────
Total Balance: 45,000 shillings
```

**User Submits Payment: 30,000 shillings**

**After Approval (FIFO Applied):**
```
Penalty 1: Jan 5  - 10,000 paid, 0 remaining ✓ PAID
Penalty 2: Jan 8  - 15,000 paid, 0 remaining ✓ PAID
Penalty 3: Jan 12 - 5,000 paid, 15,000 remaining ⏳ PARTIALLY PAID
─────────────────────────────────────────────
New Total Balance: 15,000 shillings
```

**Database Records Created:**
```
penalty_payments table:
┌────────────┬────────────┬────────────┬──────────────┐
│ payment_id │ penalty_id │ amount     │ date_incurred│
├────────────┼────────────┼────────────┼──────────────┤
│ payment-1  │ penalty-1  │ 10,000     │ Jan 5        │
│ payment-1  │ penalty-2  │ 15,000     │ Jan 8        │
│ payment-1  │ penalty-3  │ 5,000      │ Jan 12       │
└────────────┴────────────┴────────────┴──────────────┘
```

---

## 📋 Troubleshooting

### Error: Still getting RLS policy error?
→ Make sure you ran the SQL script in Supabase
→ Verify your user role is 'cashier' or 'admin'
→ Check policies exist: see [CASHIER_RLS_FIX_GUIDE.md](CASHIER_RLS_FIX_GUIDE.md)

### Error: "updated_at column not found"?
→ ✅ Already fixed! Just restart the app.
→ Make sure you're running the latest code

### Payment approved but balance not reduced?
→ Check if user has any penalties in database
→ Verify penalty status is 'unpaid' or 'partially_paid'
→ Check penalty_payments table for records

### No success message after approval?
→ Check console for errors
→ Verify PaymentBloc is handling PaymentApproved state
→ Check BlocListener in payment_review_page.dart

---

## ✅ Success Criteria

After both fixes (RLS + updated_at), you should be able to:

1. ✅ Navigate to Payment Review without errors
2. ✅ See pending payments with full user info
3. ✅ Click "Approve" without RLS errors
4. ✅ Approve payment without "updated_at" errors
5. ✅ See success message
6. ✅ Payment disappears from pending list
7. ✅ Verify penalties updated in database (FIFO)
8. ✅ Verify audit log entries created
9. ✅ Reject payment with reason
10. ✅ See rejection in database

---

## 📊 Files Changed Summary

- ✅ **payment_remote_datasource.dart** - Removed 4 instances of `updated_at`
- ✅ **fix_cashier_rls_policies.sql** - Created RLS policies script
- ✅ **CASHIER_RLS_FIX_GUIDE.md** - Comprehensive RLS guide
- ✅ **PAYMENT_APPROVAL_FIXES.md** - This file

---

## 🎉 Ready to Test!

Both issues are now fixed:
1. ✅ Code no longer tries to update non-existent `updated_at` column
2. ⏳ RLS policies script ready to run in Supabase

**Next Steps:**
1. Run the SQL script in Supabase
2. Restart your Flutter app
3. Test payment approval
4. Celebrate! 🎊

---

**Created:** 2025-11-01
**Status:** Code fixes complete, SQL script ready
**Testing:** Pending (after running SQL script)
