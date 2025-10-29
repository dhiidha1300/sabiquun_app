-- Check what date the function is processing vs what data exists
SELECT
  'Today is: ' || CURRENT_DATE as info,
  'Function processes: ' || (CURRENT_DATE - INTERVAL '1 day')::DATE as function_date,
  'Your reports are from: 2025-10-27 and 2025-10-28' as actual_reports;

-- Check if user has a report for Oct 28 (what the function is checking)
SELECT
  'Report for Oct 28 (what function checks):' as info,
  u.name,
  dr.report_date,
  dr.total_deeds,
  dr.status,
  (10.0 - COALESCE(dr.total_deeds, 0)) as missed_deeds
FROM users u
LEFT JOIN deeds_reports dr ON dr.user_id = u.id
  AND dr.report_date = '2025-10-28'::DATE
WHERE u.membership_status IN ('exclusive', 'legacy')
  AND u.account_status = 'active';

-- Check report for Oct 27 (what you want penalties for)
SELECT
  'Report for Oct 27 (what you want):' as info,
  u.name,
  dr.report_date,
  dr.total_deeds,
  dr.status,
  (10.0 - COALESCE(dr.total_deeds, 0)) as missed_deeds
FROM users u
LEFT JOIN deeds_reports dr ON dr.user_id = u.id
  AND dr.report_date = '2025-10-27'::DATE
WHERE u.membership_status IN ('exclusive', 'legacy')
  AND u.account_status = 'active';
