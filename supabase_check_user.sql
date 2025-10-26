-- ============================================
-- DIAGNOSTIC: Check User Status
-- ============================================
-- This script checks if users exist in both tables

-- Replace with the actual email
-- SET email_to_check = 'bullaale33@gmail.com';

-- ============================================
-- Check 1: User in public.users table
-- ============================================
SELECT
  'PUBLIC.USERS' as table_name,
  id,
  email,
  name,
  role,
  account_status,
  created_at
FROM public.users
WHERE email = 'bullaale33@gmail.com';

-- ============================================
-- Check 2: User in auth.users table (Supabase Auth)
-- ============================================
SELECT
  'AUTH.USERS' as table_name,
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  last_sign_in_at,
  created_at,
  is_super_admin,
  role as auth_role
FROM auth.users
WHERE email = 'bullaale33@gmail.com';

-- ============================================
-- Check 3: Check if email confirmation is required
-- ============================================
SELECT
  name as setting_name,
  value as setting_value
FROM auth.config
WHERE name IN ('email_confirmation_required', 'enable_signup');

-- Alternative way to check auth config
SELECT
  key,
  value
FROM pg_catalog.pg_settings
WHERE name LIKE '%supabase%';