-- =====================================================
-- DEBUG - See exactly what the function is calculating
-- =====================================================

-- Check the exact report data for Oct 27
SELECT
  'Checking Oct 27 report data:' as step,
  u.id as user_id,
  u.name,
  dr.id as report_id,
  dr.report_date,
  dr.total_deeds,
  dr.status,
  (SELECT COUNT(*) FROM deed_templates WHERE is_active = true) as target_deeds,
  (10.0 - COALESCE(dr.total_deeds, 0)) as calculated_missed_deeds,
  ((10.0 - COALESCE(dr.total_deeds, 0)) * 5000) as expected_penalty_amount,
  CASE
    WHEN (10.0 - COALESCE(dr.total_deeds, 0)) > 0 THEN 'SHOULD CREATE PENALTY'
    ELSE 'NO PENALTY'
  END as penalty_decision
FROM users u
LEFT JOIN deeds_reports dr ON dr.user_id = u.id AND dr.report_date = '2025-10-27'::DATE
WHERE u.membership_status IN ('exclusive', 'legacy')
  AND u.account_status = 'active';

-- Check if penalty already exists
SELECT
  'Checking existing penalties for Oct 27:' as step;

SELECT
  p.id,
  p.user_id,
  u.name,
  p.amount,
  p.date_incurred,
  p.status,
  p.created_at
FROM penalties p
JOIN users u ON p.user_id = u.id
WHERE p.date_incurred = '2025-10-27'::DATE;

-- Check deed templates count
SELECT
  'Checking deed templates:' as step,
  COUNT(*) as total_templates,
  COUNT(*) FILTER (WHERE is_active = true) as active_templates
FROM deed_templates;

-- Manual calculation test
DO $$
DECLARE
  v_target_deeds DECIMAL(4,1);
  v_report_deeds DECIMAL(4,1);
  v_missed_deeds DECIMAL(4,1);
BEGIN
  -- Get target
  SELECT COALESCE(COUNT(*), 10) INTO v_target_deeds
  FROM deed_templates WHERE is_active = true;

  -- Get report
  SELECT COALESCE(total_deeds, 0) INTO v_report_deeds
  FROM deeds_reports
  WHERE report_date = '2025-10-27'::DATE
  LIMIT 1;

  -- Calculate missed
  v_missed_deeds := v_target_deeds - v_report_deeds;

  RAISE NOTICE '=== MANUAL CALCULATION ===';
  RAISE NOTICE 'Target deeds: %', v_target_deeds;
  RAISE NOTICE 'Report deeds: %', v_report_deeds;
  RAISE NOTICE 'Missed deeds: %', v_missed_deeds;
  RAISE NOTICE 'Is missed > 0? %', v_missed_deeds > 0;
  RAISE NOTICE 'Expected penalty: %', v_missed_deeds * 5000;
END $$;
