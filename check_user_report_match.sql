-- Check if the user with legacy membership has the Oct 27 report
SELECT
  'User and Report Match Check:' as info;

-- Show the user
SELECT
  'User with legacy membership:' as type,
  id,
  name,
  email,
  membership_status,
  account_status,
  created_at
FROM users
WHERE membership_status = 'legacy'
  AND account_status = 'active';

-- Show the report for Oct 27
SELECT
  'Report for Oct 27:' as type,
  dr.id as report_id,
  dr.user_id,
  u.name as user_name,
  u.membership_status,
  dr.report_date,
  dr.total_deeds,
  dr.status,
  dr.submitted_at
FROM deeds_reports dr
JOIN users u ON u.id = dr.user_id
WHERE dr.report_date = '2025-10-27'::DATE;

-- Check if they match
SELECT
  'Do they match?' as question,
  CASE
    WHEN EXISTS (
      SELECT 1
      FROM users u
      JOIN deeds_reports dr ON dr.user_id = u.id
      WHERE u.membership_status = 'legacy'
        AND u.account_status = 'active'
        AND dr.report_date = '2025-10-27'::DATE
    ) THEN 'YES - User with legacy membership HAS Oct 27 report'
    ELSE 'NO - The Oct 27 report belongs to a different user'
  END as answer;

-- If they don't match, show which user has the report
SELECT
  'If different, the Oct 27 report belongs to:' as info,
  u.name,
  u.membership_status,
  u.account_status,
  'Change this user to legacy membership' as action
FROM deeds_reports dr
JOIN users u ON u.id = dr.user_id
WHERE dr.report_date = '2025-10-27'::DATE
  AND u.membership_status != 'legacy';
