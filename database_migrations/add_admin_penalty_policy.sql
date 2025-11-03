-- Add admin permission to penalties table
-- This allows admins to delete and recreate penalties when editing reports
-- Does NOT drop existing user policies

-- Check if the policy already exists and drop it if it does
DROP POLICY IF EXISTS "Admins can manage all penalties" ON penalties;

-- Create the admin policy
CREATE POLICY "Admins can manage all penalties"
ON penalties FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Verification: Show all policies on penalties table
SELECT
  policyname,
  cmd,
  CASE
    WHEN qual IS NOT NULL THEN 'Has USING clause'
    ELSE 'No USING clause'
  END as using_check,
  CASE
    WHEN with_check IS NOT NULL THEN 'Has WITH CHECK clause'
    ELSE 'No WITH CHECK clause'
  END as with_check_status
FROM pg_policies
WHERE tablename = 'penalties'
ORDER BY policyname;
