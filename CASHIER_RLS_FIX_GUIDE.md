# Cashier RLS Permissions Fix Guide

## 🐛 Problem

When cashiers try to approve a payment, they get this error:

```
Error: Failed to approve payment: Exception: Failed to approve payment:
PostgrestException(message: new row violates row-level security policy for table
"penalty_payments", code: 42501, details: Forbidden, hint: null)
```

**Root Cause:** The cashier role doesn't have permission to INSERT into the `penalty_payments` table, which is required during the FIFO payment application process.

---

## 🔧 Solution

Run the SQL script to add the necessary RLS policies.

### Step 1: Open Supabase SQL Editor

1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**

### Step 2: Run the SQL Script

Copy the contents of **[fix_cashier_rls_policies.sql](fix_cashier_rls_policies.sql)** and paste it into the SQL Editor, then click **Run**.

The script will:
- ✅ Allow admins/cashiers to INSERT into `penalty_payments`
- ✅ Allow admins/cashiers to UPDATE `penalties` table
- ✅ Allow admins/cashiers to UPDATE `payments` table
- ✅ Allow admins/cashiers/supervisors to INSERT into `audit_logs`
- ✅ Allow users to view their own penalty payments

### Step 3: Verify Policies Were Created

The script includes a verification query at the end. You should see output showing the newly created policies:

```
penalty_payments | Admins and cashiers can insert penalty_payments | INSERT
penalty_payments | Admins and cashiers can view penalty_payments   | SELECT
penalty_payments | Users can view their own penalty_payments       | SELECT
penalties        | Admins and cashiers can update penalties        | UPDATE
payments         | Admins and cashiers can update payments         | UPDATE
audit_logs       | Admins and cashiers can insert audit logs       | INSERT
audit_logs       | Admins can view all audit logs                  | SELECT
```

---

## 📋 What the Script Does

### 1. **penalty_payments Table**

This table tracks which payment paid which penalty (FIFO junction table).

**Policies Created:**
- ✅ `Admins and cashiers can insert penalty_payments`
  - Allows INSERT when approving payments
  - Required for FIFO payment application

- ✅ `Admins and cashiers can view penalty_payments`
  - Allows SELECT for all records
  - Needed for payment history and analytics

- ✅ `Users can view their own penalty_payments`
  - Allows users to see which payments paid which penalties
  - Only shows records for payments they submitted

### 2. **penalties Table**

This table stores penalty records for missed deeds.

**Policy Created:**
- ✅ `Admins and cashiers can update penalties`
  - Allows UPDATE to mark penalties as paid/partially_paid
  - Updates `paid_amount` and `status` fields during payment approval

### 3. **payments Table**

This table stores all payment submissions.

**Policy Created:**
- ✅ `Admins and cashiers can update payments`
  - Allows UPDATE to approve or reject payments
  - Sets `status`, `reviewed_by`, `reviewed_at`, and `rejection_reason`

### 4. **audit_logs Table**

This table tracks all important actions.

**Policies Created:**
- ✅ `Admins and cashiers can insert audit logs`
  - Allows logging payment approvals/rejections
  - Includes supervisors for excuse approvals

- ✅ `Admins can view all audit logs`
  - Allows admins to review all actions
  - For compliance and auditing

---

## 🧪 Testing After Fix

### Test 1: Approve a Payment

1. **Create a test payment** (as a user):
   ```sql
   INSERT INTO payments (user_id, amount, payment_method, status)
   VALUES (
     '<your-user-id>',
     50000,
     'ZAAD',
     'pending'
   );
   ```

2. **Navigate to Payment Review** (as cashier):
   - Open the app as a cashier
   - Go to Payment Management
   - You should see the pending payment

3. **Approve the payment**:
   - Click "Approve" button
   - Add optional notes
   - Click "Confirm Approval"

4. **Verify success**:
   - ✅ Payment status changes to 'approved'
   - ✅ No error message appears
   - ✅ Success snackbar shows
   - ✅ Payment disappears from pending list

5. **Check database** (in Supabase):
   ```sql
   -- Check payment was approved
   SELECT * FROM payments WHERE id = '<payment-id>';

   -- Check penalty_payments records were created (FIFO)
   SELECT pp.*, p.date_incurred, p.amount, pp.amount_applied
   FROM penalty_payments pp
   JOIN penalties p ON pp.penalty_id = p.id
   WHERE pp.payment_id = '<payment-id>'
   ORDER BY p.date_incurred;

   -- Check penalties were updated
   SELECT * FROM penalties
   WHERE user_id = '<user-id>'
   ORDER BY date_incurred;

   -- Check audit log entry
   SELECT * FROM audit_logs
   WHERE entity_id = '<payment-id>'
   AND action = 'payment_approved';
   ```

### Test 2: Reject a Payment

1. **Create another test payment**

2. **Reject the payment**:
   - Click "Reject" button
   - Enter rejection reason (minimum 10 characters)
   - Click "Confirm Rejection"

3. **Verify success**:
   - ✅ Payment status changes to 'rejected'
   - ✅ Rejection reason is stored
   - ✅ Success snackbar shows
   - ✅ Payment disappears from pending list

4. **Check database**:
   ```sql
   SELECT * FROM payments WHERE id = '<payment-id>';
   -- Should show status='rejected' and rejection_reason filled

   SELECT * FROM audit_logs
   WHERE entity_id = '<payment-id>'
   AND action = 'payment_rejected';
   ```

---

## 🔍 Troubleshooting

### Still Getting Permission Errors?

1. **Check user role in database**:
   ```sql
   SELECT id, email, role FROM users WHERE email = 'your-cashier-email@example.com';
   ```
   - Role should be 'cashier' or 'admin'

2. **Verify policies exist**:
   ```sql
   SELECT policyname, tablename, cmd
   FROM pg_policies
   WHERE tablename IN ('penalty_payments', 'penalties', 'payments', 'audit_logs')
   ORDER BY tablename, policyname;
   ```

3. **Check RLS is enabled**:
   ```sql
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE schemaname = 'public'
   AND tablename IN ('penalty_payments', 'penalties', 'payments', 'audit_logs');
   ```
   - `rowsecurity` should be `true` for all tables

4. **Test policy manually**:
   ```sql
   -- As cashier user, try to insert
   SET LOCAL ROLE authenticated;
   SET LOCAL request.jwt.claims TO '{"sub": "<cashier-user-id>"}';

   INSERT INTO penalty_payments (payment_id, penalty_id, amount_applied)
   VALUES ('<test-payment-id>', '<test-penalty-id>', 10000);
   ```

### Error: "could not find a relationship"?

This was the previous error - already fixed by updating the query to not join `payment_methods` table.

### Error: "null value in column violates not-null constraint"?

Check that all required fields are being set during INSERT/UPDATE operations.

---

## 📊 FIFO Payment Application Flow

Understanding what happens when a payment is approved:

```
1. Cashier clicks "Approve"
   ↓
2. approvePayment() is called
   ↓
3. Get payment details (amount, user_id)
   ↓
4. Get user's unpaid penalties (ordered by date_incurred ASC)
   ↓
5. For each penalty (oldest first):
   a. Calculate amount_to_apply
   b. INSERT into penalty_payments ← NEEDS PERMISSION
   c. UPDATE penalty (paid_amount, status) ← NEEDS PERMISSION
   d. Subtract from remaining payment amount
   e. If payment fully distributed, break loop
   ↓
6. UPDATE payment (status='approved', reviewed_by, reviewed_at) ← NEEDS PERMISSION
   ↓
7. INSERT audit log entry ← NEEDS PERMISSION
   ↓
8. Success! Payment approved and applied to penalties
```

---

## 🎯 Security Considerations

### What Cashiers CAN Do:
- ✅ View all pending payments
- ✅ View all payment history
- ✅ Approve pending payments
- ✅ Reject pending payments with reason
- ✅ Update penalties (only via payment approval)
- ✅ Insert penalty_payment records (only via payment approval)
- ✅ Log actions in audit trail

### What Cashiers CANNOT Do:
- ❌ Delete payments
- ❌ Modify approved payments
- ❌ Delete penalties
- ❌ Create penalties manually
- ❌ Delete penalty_payment records
- ❌ Delete audit logs
- ❌ Access admin-only features
- ❌ Change user roles

### Audit Trail

All cashier actions are logged:
```sql
SELECT
  al.action,
  al.performed_by,
  u.name as cashier_name,
  al.entity_type,
  al.entity_id,
  al.timestamp,
  al.reason
FROM audit_logs al
JOIN users u ON u.id = al.performed_by
WHERE al.action IN ('payment_approved', 'payment_rejected')
ORDER BY al.timestamp DESC;
```

---

## ✅ Success Criteria

After running the SQL script, you should be able to:

1. ✅ Navigate to Payment Review page without errors
2. ✅ See pending payments with user info
3. ✅ Click "Approve" and successfully approve payments
4. ✅ Click "Reject" and successfully reject payments
5. ✅ See success messages after approval/rejection
6. ✅ Verify payments disappear from pending list
7. ✅ Check database shows correct status changes
8. ✅ See penalty_payments records created (FIFO)
9. ✅ See penalties updated with paid amounts
10. ✅ See audit log entries for all actions

---

## 📝 Next Steps

After fixing RLS policies:

1. ✅ **Test payment approval thoroughly**
2. ✅ **Test payment rejection thoroughly**
3. **Implement Payment Detail Modal** (Phase 1 continuation)
   - Show FIFO breakdown preview
   - Show user balance before/after
4. **Implement Payment History Tab** (Phase 1 continuation)
   - Show approved/rejected payments
   - Filter by date, status, cashier
5. **Move to Phase 2: User Balance Management**
   - User search functionality
   - Manual balance adjustments

---

## 🆘 Need Help?

If you encounter any issues:

1. Check the error message carefully
2. Verify the SQL script ran successfully
3. Check that your user has 'cashier' or 'admin' role
4. Review the verification queries output
5. Test with a simple INSERT/UPDATE manually

---

**Created:** 2025-11-01
**Status:** Ready to deploy
**File:** [fix_cashier_rls_policies.sql](fix_cashier_rls_policies.sql)
