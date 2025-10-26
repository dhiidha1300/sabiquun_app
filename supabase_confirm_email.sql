-- ============================================
-- FIX: Manually Confirm User Email
-- ============================================
-- Use this to confirm email for testing purposes

-- ============================================
-- STEP 1: First, check if user exists
-- ============================================
SELECT
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email = 'bullaale33@gmail.com';

-- If the above returns a row, proceed with Step 2
-- If it returns nothing, the user doesn't exist in auth.users

-- ============================================
-- STEP 2: Confirm the email
-- ============================================
-- NOTE: Do NOT update 'confirmed_at' as it's a generated column

UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email = 'bullaale33@gmail.com';

-- ============================================
-- STEP 3: Verify the update
-- ============================================
SELECT
  id,
  email,
  email_confirmed_at,
  created_at
FROM auth.users
WHERE email = 'bullaale33@gmail.com';

-- Expected: email_confirmed_at should now have a timestamp

-- ============================================
-- ALTERNATIVE: If user doesn't exist in auth.users
-- ============================================
-- This means auth.signUp() didn't create the user
-- You need to:
-- 1. Delete from public.users
-- 2. Sign up again through the app

-- To delete:
-- DELETE FROM public.users WHERE email = 'bullaale33@gmail.com';