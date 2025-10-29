-- =====================================================
-- CALCULATE PENALTIES FOR A SPECIFIC DATE
-- =====================================================
-- This function allows you to calculate penalties for any specific date
-- Useful for:
-- 1. Backfilling missed penalty calculations
-- 2. Testing with specific dates
-- 3. Manual penalty runs
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_penalties_for_date(target_date DATE)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_target_deeds DECIMAL(4,1);
  v_penalty_per_deed DECIMAL(10,2);
  v_training_days INTEGER;
  v_user_record RECORD;
  v_report_record RECORD;
  v_missed_deeds DECIMAL(4,1);
  v_penalty_amount DECIMAL(10,2);
  v_new_penalty_id UUID;
  v_penalties_created INTEGER := 0;
  v_users_processed INTEGER := 0;
  v_errors TEXT[] := ARRAY[]::TEXT[];
  v_result json;
BEGIN
  -- Get system settings
  SELECT COALESCE(setting_value::DECIMAL, 5000) INTO v_penalty_per_deed
  FROM settings WHERE setting_key = 'penalty_per_deed';

  SELECT COALESCE(setting_value::INTEGER, 30) INTO v_training_days
  FROM settings WHERE setting_key = 'training_period_days';

  -- Count active deed templates to get target
  SELECT COALESCE(COUNT(*), 10) INTO v_target_deeds
  FROM deed_templates WHERE is_active = true;

  RAISE NOTICE 'Starting penalty calculation for date: %', target_date;
  RAISE NOTICE 'Target deeds: %, Penalty per deed: %', v_target_deeds, v_penalty_per_deed;

  -- Loop through all active users who should be penalized
  FOR v_user_record IN
    SELECT
      u.id,
      u.name as full_name,
      u.membership_status,
      u.account_status,
      u.created_at,
      (target_date - u.created_at::DATE) as days_since_joined
    FROM users u
    WHERE u.account_status = 'active'
      AND u.membership_status IN ('exclusive', 'legacy')
      AND NOT EXISTS (
        SELECT 1 FROM penalties p
        WHERE p.user_id = u.id
          AND p.date_incurred = target_date
      )
  LOOP
    BEGIN
      v_users_processed := v_users_processed + 1;

      -- Check if user is in training period
      IF v_user_record.days_since_joined < v_training_days THEN
        RAISE NOTICE 'Skipping user % - training period (% days)',
          v_user_record.full_name, v_user_record.days_since_joined;
        CONTINUE;
      END IF;

      -- Check if it was a rest day
      IF EXISTS (SELECT 1 FROM rest_days WHERE rest_date = target_date) THEN
        RAISE NOTICE 'Skipping user % - rest day', v_user_record.full_name;
        CONTINUE;
      END IF;

      -- Check if user has approved excuse
      IF EXISTS (
        SELECT 1 FROM excuses
        WHERE user_id = v_user_record.id
          AND report_date = target_date
          AND status = 'approved'
      ) THEN
        RAISE NOTICE 'Skipping user % - approved excuse', v_user_record.full_name;
        CONTINUE;
      END IF;

      -- Get user's report for the target date
      SELECT id, total_deeds, status, submitted_at
      INTO v_report_record
      FROM deeds_reports
      WHERE user_id = v_user_record.id
        AND report_date = target_date;

      -- Calculate missed deeds
      IF v_report_record.id IS NULL THEN
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'User % - NO REPORT - Missed: %', v_user_record.full_name, v_missed_deeds;
      ELSIF v_report_record.status = 'draft' THEN
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'User % - DRAFT - Missed: %', v_user_record.full_name, v_missed_deeds;
      ELSIF v_report_record.status = 'submitted' THEN
        v_missed_deeds := v_target_deeds - COALESCE(v_report_record.total_deeds, 0);
        RAISE NOTICE 'User % - SUBMITTED (%) - Missed: %',
          v_user_record.full_name, v_report_record.total_deeds, v_missed_deeds;
      ELSE
        v_missed_deeds := 0;
      END IF;

      -- Create penalty if deeds were missed
      IF v_missed_deeds > 0 THEN
        v_penalty_amount := v_missed_deeds * v_penalty_per_deed;

        INSERT INTO penalties (
          user_id, report_id, amount, date_incurred,
          status, paid_amount, created_at, updated_at
        ) VALUES (
          v_user_record.id, v_report_record.id, v_penalty_amount, target_date,
          'unpaid', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
        RETURNING id INTO v_new_penalty_id;

        v_penalties_created := v_penalties_created + 1;

        RAISE NOTICE 'PENALTY CREATED - User: %, Amount: %, ID: %',
          v_user_record.full_name, v_penalty_amount, v_new_penalty_id;
      ELSE
        RAISE NOTICE 'User % - NO PENALTY (completed all deeds)', v_user_record.full_name;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      v_errors := array_append(v_errors,
        format('Error: %s (%s): %s', v_user_record.full_name, v_user_record.id, SQLERRM));
      RAISE WARNING 'Error: % - %', v_user_record.full_name, SQLERRM;
    END;
  END LOOP;

  v_result := json_build_object(
    'success', true,
    'date_processed', target_date,
    'users_processed', v_users_processed,
    'penalties_created', v_penalties_created,
    'target_deeds', v_target_deeds,
    'penalty_per_deed', v_penalty_per_deed,
    'errors', v_errors,
    'timestamp', CURRENT_TIMESTAMP
  );

  RAISE NOTICE 'Completed: % users, % penalties', v_users_processed, v_penalties_created;
  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM,
    'timestamp', CURRENT_TIMESTAMP
  );
END;
$$;

GRANT EXECUTE ON FUNCTION calculate_penalties_for_date(DATE) TO authenticated;

-- =====================================================
-- USAGE EXAMPLES
-- =====================================================

-- Calculate penalties for Oct 27, 2025 (9.5/10 report)
-- SELECT calculate_penalties_for_date('2025-10-27'::DATE);

-- Calculate penalties for Oct 28, 2025 (6.0/10 report)
-- SELECT calculate_penalties_for_date('2025-10-28'::DATE);

-- Calculate for yesterday
-- SELECT calculate_penalties_for_date(CURRENT_DATE - INTERVAL '1 day');

-- Calculate for a range of dates (backfill)
-- DO $$
-- DECLARE
--   d DATE;
-- BEGIN
--   FOR d IN SELECT generate_series('2025-10-20'::DATE, '2025-10-27'::DATE, '1 day'::INTERVAL)::DATE
--   LOOP
--     PERFORM calculate_penalties_for_date(d);
--   END LOOP;
-- END $$;
