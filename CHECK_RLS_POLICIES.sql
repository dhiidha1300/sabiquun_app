-- ============================================================================
-- RLS Policy Verification Script
-- Description: Run this in Supabase SQL Editor to check all RLS policies
-- ============================================================================

-- Check if RLS is enabled on all tables
SELECT
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'users',
    'deeds_reports',
    'excuses',
    'penalties',
    'payments',
    'notifications',
    'special_tags',
    'user_tags'
  )
ORDER BY tablename;

-- View all policies on excuses table
SELECT
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'excuses'
ORDER BY policyname;

-- Count policies per table
SELECT
  tablename,
  COUNT(*) as policy_count
FROM pg_policies
WHERE schemaname = 'public'
GROUP BY tablename
ORDER BY tablename;

-- ============================================================================
-- Quick Fix: Enable RLS on excuses if not enabled
-- ============================================================================
-- Uncomment and run if needed:
-- ALTER TABLE public.excuses ENABLE ROW LEVEL SECURITY;
