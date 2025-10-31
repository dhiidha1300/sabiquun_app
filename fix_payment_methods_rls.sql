-- ===================================================================
-- FIX RLS POLICY FOR PAYMENT_METHODS TABLE
-- ===================================================================
-- This script allows all authenticated users to read payment methods
-- Run this in your Supabase SQL Editor
-- ===================================================================

-- Enable RLS on payment_methods table (if not already enabled)
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Allow all users to read payment methods" ON payment_methods;
DROP POLICY IF EXISTS "Enable read access for all users" ON payment_methods;

-- Create a policy that allows all authenticated users to read payment methods
CREATE POLICY "Enable read access for all users"
ON payment_methods
FOR SELECT
TO authenticated
USING (true);

-- Also allow public read access (optional - only if you want anonymous users to see payment methods)
-- Uncomment the next 4 lines if needed:
-- CREATE POLICY "Enable read access for public"
-- ON payment_methods
-- FOR SELECT
-- TO anon
-- USING (true);

-- Verify the policy was created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'payment_methods';
