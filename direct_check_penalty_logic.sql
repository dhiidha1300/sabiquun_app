-- =====================================================
-- DIRECT CHECK - Manually simulate the exact logic
-- =====================================================
-- This will show you exactly what the function is doing
-- Returns actual data instead of NOTICE messages
-- =====================================================

WITH user_data AS (
  SELECT
    u.id,
    u.name,
    u.membership_status,
    u.account_status,
    ('2025-10-27'::DATE - u.created_at::DATE) as days_since_joined
  FROM users u
  WHERE u.account_status = 'active'
    AND u.membership_status IN ('exclusive', 'legacy')
  LIMIT 1
),
report_data AS (
  SELECT
    dr.id as report_id,
    dr.user_id,
    dr.report_date,
    dr.total_deeds,
    dr.status,
    dr.submitted_at
  FROM deeds_reports dr
  WHERE dr.report_date = '2025-10-27'::DATE
    AND dr.user_id = (SELECT id FROM user_data)
),
settings_data AS (
  SELECT
    (SELECT COUNT(*) FROM deed_templates WHERE is_active = true) as target_deeds,
    (SELECT COALESCE(setting_value::DECIMAL, 5000) FROM settings WHERE setting_key = 'penalty_per_deed') as penalty_per_deed,
    (SELECT COALESCE(setting_value::INTEGER, 30) FROM settings WHERE setting_key = 'training_period_days') as training_days
),
calculation AS (
  SELECT
    u.id as user_id,
    u.name as user_name,
    u.membership_status,
    u.days_since_joined,
    s.training_days,
    CASE
      WHEN u.days_since_joined < s.training_days THEN 'YES - Would skip (training period)'
      ELSE 'NO - Passes training check'
    END as in_training_period,

    r.report_id,
    r.report_date,
    r.total_deeds,
    r.status as report_status,

    s.target_deeds,

    CASE
      WHEN r.report_id IS NULL THEN s.target_deeds
      WHEN r.status = 'draft' THEN s.target_deeds
      WHEN r.status = 'submitted' THEN s.target_deeds - COALESCE(r.total_deeds, 0)
      ELSE 0
    END as missed_deeds,

    CASE
      WHEN r.report_id IS NULL THEN 'NO REPORT FOUND'
      WHEN r.status = 'draft' THEN 'DRAFT (counts as no submission)'
      WHEN r.status = 'submitted' THEN 'SUBMITTED'
      ELSE 'UNKNOWN STATUS: ' || r.status
    END as report_situation,

    s.penalty_per_deed,

    CASE
      WHEN r.report_id IS NULL THEN s.target_deeds * s.penalty_per_deed
      WHEN r.status = 'draft' THEN s.target_deeds * s.penalty_per_deed
      WHEN r.status = 'submitted' THEN (s.target_deeds - COALESCE(r.total_deeds, 0)) * s.penalty_per_deed
      ELSE 0
    END as calculated_penalty,

    CASE
      WHEN r.report_id IS NULL THEN 'YES - No report'
      WHEN r.status = 'draft' THEN 'YES - Draft report'
      WHEN r.status = 'submitted' AND (s.target_deeds - COALESCE(r.total_deeds, 0)) > 0
        THEN 'YES - Incomplete (' || (s.target_deeds - COALESCE(r.total_deeds, 0))::TEXT || ' deeds missed)'
      WHEN r.status = 'submitted' AND (s.target_deeds - COALESCE(r.total_deeds, 0)) <= 0
        THEN 'NO - Completed all deeds'
      ELSE 'UNKNOWN'
    END as should_create_penalty,

    EXISTS(SELECT 1 FROM penalties p WHERE p.user_id = u.id AND p.date_incurred = '2025-10-27'::DATE) as penalty_already_exists

  FROM user_data u
  LEFT JOIN report_data r ON r.user_id = u.id
  CROSS JOIN settings_data s
)
SELECT
  '=== USER INFO ===' as section,
  user_name::TEXT as col1,
  membership_status::TEXT as col2,
  days_since_joined::TEXT as col3,
  training_days::TEXT as col4,
  in_training_period::TEXT as col5
FROM calculation
UNION ALL
SELECT
  '=== REPORT INFO ===' as section,
  COALESCE(report_id::TEXT, 'NULL'),
  COALESCE(report_status, 'NO REPORT'),
  COALESCE(total_deeds::TEXT, 'NULL'),
  report_situation,
  ''
FROM calculation
UNION ALL
SELECT
  '=== CALCULATION ===' as section,
  'Target: ' || target_deeds::TEXT,
  'Completed: ' || COALESCE(total_deeds::TEXT, '0'),
  'Missed: ' || missed_deeds::TEXT,
  'Penalty rate: ' || penalty_per_deed::TEXT,
  'Total penalty: ' || calculated_penalty::TEXT
FROM calculation
UNION ALL
SELECT
  '=== DECISION ===' as section,
  should_create_penalty,
  CASE WHEN penalty_already_exists THEN 'PENALTY ALREADY EXISTS' ELSE 'No existing penalty' END,
  '',
  '',
  ''
FROM calculation;

-- Also show if there IS a report but for a DIFFERENT user
SELECT
  '=== ALERT: Report belongs to different user? ===' as alert,
  dr.user_id,
  u.name,
  u.membership_status,
  'If this user membership is not legacy, change it!' as action
FROM deeds_reports dr
JOIN users u ON u.id = dr.user_id
WHERE dr.report_date = '2025-10-27'::DATE
  AND NOT EXISTS (
    SELECT 1 FROM users u2
    WHERE u2.id = dr.user_id
      AND u2.membership_status IN ('exclusive', 'legacy')
      AND u2.account_status = 'active'
  );
