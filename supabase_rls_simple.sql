-- SIMPLE RLS POLICIES - NO RECURSION
-- Run this in your Supabase SQL Editor
-- This is the safest approach for getting signup working

-- ============================================
-- STEP 1: CLEAN UP - Remove all existing policies
-- ============================================

-- Drop all existing policies on users table
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;
DROP POLICY IF EXISTS "Enable insert for signup" ON users;
DROP POLICY IF EXISTS "Enable update for users based on uid" ON users;

-- ============================================
-- STEP 2: SIMPLE USERS TABLE POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Policy 1: SELECT - Anyone authenticated can read all users
-- (We'll restrict this later once signup works)
CREATE POLICY "users_select_policy"
  ON users
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy 2: INSERT - Allow new signups
-- This is the critical one for signup to work
CREATE POLICY "users_insert_policy"
  ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- Policy 3: UPDATE - Users can update their own data
CREATE POLICY "users_update_policy"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Policy 4: DELETE - Disabled for now
-- (No policy means no one can delete)

-- ============================================
-- VERIFICATION
-- ============================================

-- Run this to see the policies that were created:
SELECT tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename = 'users'
ORDER BY policyname;

-- Expected output:
-- tablename | policyname              | permissive | roles           | cmd
-- ----------|------------------------|------------|-----------------|--------
-- users     | users_insert_policy    | PERMISSIVE | {authenticated} | INSERT
-- users     | users_select_policy    | PERMISSIVE | {authenticated} | SELECT
-- users     | users_update_policy    | PERMISSIVE | {authenticated} | UPDATE
