-- =====================================================
-- DIAGNOSTIC SCRIPT - Find out why no users are processed
-- =====================================================
-- Run this in Supabase SQL Editor to diagnose the issue
-- =====================================================

-- 1. Check all users and their membership status
SELECT
  'STEP 1: Checking all users' as diagnostic_step;

SELECT
  id,
  name,
  email,
  membership_status,
  account_status,
  created_at,
  (CURRENT_DATE - created_at::DATE) as days_since_joined
FROM users
ORDER BY created_at DESC
LIMIT 10;

-- 2. Check yesterday's reports
SELECT
  'STEP 2: Checking yesterday reports (2025-10-27)' as diagnostic_step;

SELECT
  u.id,
  u.name,
  u.membership_status,
  dr.report_date,
  dr.total_deeds,
  dr.status,
  (10.0 - COALESCE(dr.total_deeds, 0)) as missed_deeds,
  ((10.0 - COALESCE(dr.total_deeds, 0)) * 5000) as expected_penalty
FROM users u
LEFT JOIN deeds_reports dr ON dr.user_id = u.id
  AND dr.report_date = '2025-10-27'::DATE
ORDER BY u.created_at DESC
LIMIT 10;

-- 3. Check the specific filtering criteria
SELECT
  'STEP 3: Breaking down the WHERE clause filters' as diagnostic_step;

-- 3a. How many users are active?
SELECT
  'Active users' as filter,
  COUNT(*) as user_count
FROM users
WHERE account_status = 'active';

-- 3b. How many users have 'exclusive' or 'legacy' membership?
SELECT
  membership_status,
  COUNT(*) as user_count
FROM users
GROUP BY membership_status
ORDER BY user_count DESC;

-- 3c. Check what membership statuses exist
SELECT DISTINCT membership_status FROM users;

-- 4. Check existing penalties for yesterday
SELECT
  'STEP 4: Checking existing penalties for yesterday' as diagnostic_step;

SELECT
  p.id,
  u.name,
  p.amount,
  p.date_incurred,
  p.status,
  p.created_at
FROM penalties p
JOIN users u ON p.user_id = u.id
WHERE p.date_incurred >= '2025-10-27'::DATE
ORDER BY p.created_at DESC;

-- 5. Check what the exact WHERE clause would return
SELECT
  'STEP 5: Simulating the exact WHERE clause from the function' as diagnostic_step;

SELECT
  u.id,
  u.name,
  u.membership_status,
  u.account_status,
  (CURRENT_DATE - u.created_at::DATE) as days_since_joined,
  CASE
    WHEN u.account_status != 'active' THEN 'NOT ACTIVE'
    WHEN u.membership_status NOT IN ('exclusive', 'legacy') THEN 'WRONG MEMBERSHIP: ' || u.membership_status
    WHEN EXISTS (SELECT 1 FROM penalties p WHERE p.user_id = u.id AND p.date_incurred = CURRENT_DATE - INTERVAL '1 day') THEN 'ALREADY HAS PENALTY'
    ELSE 'SHOULD BE PROCESSED'
  END as filter_result
FROM users u
ORDER BY u.created_at DESC
LIMIT 10;

-- 6. Check settings
SELECT
  'STEP 6: Checking system settings' as diagnostic_step;

SELECT
  setting_key,
  setting_value,
  data_type
FROM settings
WHERE setting_key IN (
  'penalty_per_deed',
  'grace_period_hours',
  'training_period_days'
);

-- 7. Final recommendation query
SELECT
  'STEP 7: What needs to be fixed?' as diagnostic_step;

SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM users WHERE account_status = 'active') = 0
    THEN '⚠️ NO ACTIVE USERS - Update users to account_status = ''active'''
    WHEN (SELECT COUNT(*) FROM users WHERE membership_status IN ('exclusive', 'legacy')) = 0
    THEN '⚠️ NO EXCLUSIVE/LEGACY USERS - Update users to membership_status = ''exclusive'' or ''legacy'''
    WHEN (SELECT COUNT(*) FROM deed_templates WHERE is_active = true) = 0
    THEN '⚠️ NO ACTIVE DEED TEMPLATES - Insert deed templates or set is_active = true'
    ELSE '✓ Everything looks good - check detailed results above'
  END as recommendation;
