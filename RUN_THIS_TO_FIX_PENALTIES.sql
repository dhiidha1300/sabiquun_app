-- =====================================================
-- FIX YOUR PENALTY ISSUE - RUN THIS IN SUPABASE
-- =====================================================
-- This will create penalties for Oct 27 (9.5/10 report)
-- and Oct 28 (6.0/10 report) if grace period has passed
-- =====================================================

-- Step 1: Deploy the date-specific function
-- (Copy the content from calculate_penalties_for_date.sql first)
-- Or run this file after running calculate_penalties_for_date.sql

-- Step 2: Calculate penalties for Oct 27, 2025 (the 9.5/10 report)
SELECT 'Processing Oct 27, 2025 penalties...' as step;
SELECT calculate_penalties_for_date('2025-10-27'::DATE);

-- Step 3: Check if penalties were created
SELECT 'Checking created penalties...' as step;
SELECT
  p.id,
  u.name,
  p.amount,
  p.date_incurred,
  dr.total_deeds,
  (10.0 - dr.total_deeds) as missed_deeds,
  p.status,
  p.created_at
FROM penalties p
JOIN users u ON p.user_id = u.id
LEFT JOIN deeds_reports dr ON p.report_id = dr.id
WHERE p.date_incurred >= '2025-10-27'::DATE
ORDER BY p.date_incurred, p.created_at DESC;

-- Step 4: Verify your penalty balance
SELECT 'Your current penalty balance:' as info;
SELECT
  u.name,
  COALESCE(SUM(p.amount - p.paid_amount), 0) as total_balance,
  COUNT(p.id) as number_of_penalties
FROM users u
LEFT JOIN penalties p ON p.user_id = u.id
  AND p.status != 'waived'
WHERE u.membership_status IN ('exclusive', 'legacy')
  AND u.account_status = 'active'
GROUP BY u.id, u.name;

-- =====================================================
-- EXPECTED RESULTS
-- =====================================================
-- For Oct 27 report (9.5/10):
--   Missed: 0.5 deeds
--   Penalty: 2,500 shillings
--
-- For Oct 28 report (6.0/10):
--   If grace period ended: Missed: 4.0 deeds, Penalty: 20,000 shillings
--   If still in grace: No penalty yet
--
-- Total expected balance: 2,500 (or 22,500 if both)
-- =====================================================
