-- ============================================
-- FINAL RLS FIX - Run this in Supabase SQL Editor
-- ============================================
-- This script will completely reset and fix the users table RLS policies

-- ============================================
-- STEP 1: DISABLE RLS temporarily to clean up
-- ============================================
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 2: DROP ALL EXISTING POLICIES
-- ============================================
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;
DROP POLICY IF EXISTS "Enable insert for signup" ON users;
DROP POLICY IF EXISTS "Enable update for users based on uid" ON users;
DROP POLICY IF EXISTS "users_select_policy" ON users;
DROP POLICY IF EXISTS "users_insert_policy" ON users;
DROP POLICY IF EXISTS "users_update_policy" ON users;

-- ============================================
-- STEP 3: RE-ENABLE RLS
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 4: CREATE SIMPLE, NON-RECURSIVE POLICIES
-- ============================================

-- SELECT: Allow all authenticated users to read all user records
CREATE POLICY "allow_select_users"
ON users FOR SELECT
TO authenticated
USING (true);

-- INSERT: Allow signup - authenticated users can insert their own record
CREATE POLICY "allow_insert_own_user"
ON users FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- UPDATE: Allow users to update their own record
CREATE POLICY "allow_update_own_user"
ON users FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================
-- STEP 5: VERIFY POLICIES WERE CREATED
-- ============================================
-- Run this to confirm the policies:
SELECT
  policyname,
  cmd as operation,
  qual as using_expression,
  with_check as with_check_expression
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;

-- Expected output should show 3 policies:
-- allow_insert_own_user (INSERT)
-- allow_select_users (SELECT)
-- allow_update_own_user (UPDATE)
