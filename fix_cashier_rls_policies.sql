-- Fix RLS Policies for Cashier Payment Approval
-- This script adds the necessary permissions for cashiers/admins to approve payments
-- which involves inserting into penalty_payments and updating penalties

-- ============================================================================
-- PENALTY_PAYMENTS TABLE POLICIES
-- ============================================================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins and cashiers can insert penalty_payments" ON penalty_payments;
DROP POLICY IF EXISTS "Admins and cashiers can view penalty_payments" ON penalty_payments;
DROP POLICY IF EXISTS "Users can view their own penalty_payments" ON penalty_payments;

-- Allow admins and cashiers to insert penalty payment records during approval
CREATE POLICY "Admins and cashiers can insert penalty_payments"
ON penalty_payments
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
);

-- Allow admins and cashiers to view all penalty payment records
CREATE POLICY "Admins and cashiers can view penalty_payments"
ON penalty_payments
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
);

-- Allow users to view their own penalty payment records
CREATE POLICY "Users can view their own penalty_payments"
ON penalty_payments
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM payments
    WHERE payments.id = penalty_payments.payment_id
    AND payments.user_id = auth.uid()
  )
);

-- ============================================================================
-- PENALTIES TABLE POLICIES (Update permissions)
-- ============================================================================

-- Drop existing update policy if it exists
DROP POLICY IF EXISTS "Admins and cashiers can update penalties" ON penalties;

-- Allow admins and cashiers to update penalties (for payment application)
CREATE POLICY "Admins and cashiers can update penalties"
ON penalties
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
);

-- ============================================================================
-- PAYMENTS TABLE POLICIES (Update permissions)
-- ============================================================================

-- Drop existing update policy if it exists
DROP POLICY IF EXISTS "Admins and cashiers can update payments" ON payments;

-- Allow admins and cashiers to update payments (for approval/rejection)
CREATE POLICY "Admins and cashiers can update payments"
ON payments
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier')
  )
);

-- ============================================================================
-- AUDIT_LOGS TABLE POLICIES (Insert permissions)
-- ============================================================================

-- Drop existing insert policy if it exists
DROP POLICY IF EXISTS "Admins and cashiers can insert audit logs" ON audit_logs;

-- Allow admins and cashiers to insert audit log entries
CREATE POLICY "Admins and cashiers can insert audit logs"
ON audit_logs
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role IN ('admin', 'cashier', 'supervisor')
  )
);

-- Allow admins to view all audit logs
DROP POLICY IF EXISTS "Admins can view all audit logs" ON audit_logs;
CREATE POLICY "Admins can view all audit logs"
ON audit_logs
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify policies were created
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename IN ('penalty_payments', 'penalties', 'payments', 'audit_logs')
ORDER BY tablename, policyname;

-- ============================================================================
-- SUMMARY
-- ============================================================================

/*
This script creates the following RLS policies:

1. PENALTY_PAYMENTS:
   - Admins/cashiers can INSERT (needed for FIFO payment application)
   - Admins/cashiers can SELECT all records
   - Users can SELECT their own records

2. PENALTIES:
   - Admins/cashiers can UPDATE (needed to mark penalties as paid/partially_paid)

3. PAYMENTS:
   - Admins/cashiers can UPDATE (needed to approve/reject payments)

4. AUDIT_LOGS:
   - Admins/cashiers/supervisors can INSERT (needed for logging actions)
   - Admins can SELECT all records

USAGE:
1. Run this script in your Supabase SQL Editor
2. Verify the policies were created by checking the verification query results
3. Test payment approval flow in the app
*/
