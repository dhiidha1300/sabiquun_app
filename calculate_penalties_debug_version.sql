-- =====================================================
-- DEBUG VERSION - Shows detailed step-by-step execution
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_penalties_for_date_debug(target_date DATE)
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

  RAISE NOTICE '========================================';
  RAISE NOTICE 'PENALTY CALCULATION DEBUG';
  RAISE NOTICE 'Date: %', target_date;
  RAISE NOTICE 'Target deeds: %', v_target_deeds;
  RAISE NOTICE 'Penalty per deed: %', v_penalty_per_deed;
  RAISE NOTICE '========================================';

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

      RAISE NOTICE '';
      RAISE NOTICE '--- Processing User % (ID: %) ---', v_user_record.full_name, v_user_record.id;
      RAISE NOTICE 'Membership: %, Account: %, Days: %',
        v_user_record.membership_status, v_user_record.account_status, v_user_record.days_since_joined;

      -- Check if user is in training period
      IF v_user_record.days_since_joined < v_training_days THEN
        RAISE NOTICE 'SKIPPED - Training period (% < % days)', v_user_record.days_since_joined, v_training_days;
        CONTINUE;
      END IF;
      RAISE NOTICE 'CHECK 1 PASSED - Not in training period';

      -- Check if it was a rest day
      IF EXISTS (SELECT 1 FROM rest_days WHERE rest_date = target_date) THEN
        RAISE NOTICE 'SKIPPED - Rest day';
        CONTINUE;
      END IF;
      RAISE NOTICE 'CHECK 2 PASSED - Not a rest day';

      -- Check if user has approved excuse
      IF EXISTS (
        SELECT 1 FROM excuses
        WHERE user_id = v_user_record.id
          AND excuse_date = target_date
          AND status = 'approved'
      ) THEN
        RAISE NOTICE 'SKIPPED - Approved excuse';
        CONTINUE;
      END IF;
      RAISE NOTICE 'CHECK 3 PASSED - No approved excuse';

      -- Get user's report for the target date
      SELECT id, total_deeds, status, submitted_at
      INTO v_report_record
      FROM deeds_reports
      WHERE user_id = v_user_record.id
        AND report_date = target_date;

      IF v_report_record.id IS NULL THEN
        RAISE NOTICE 'Report: NOT FOUND';
      ELSE
        RAISE NOTICE 'Report: FOUND (ID: %, Status: %, Deeds: %)',
          v_report_record.id, v_report_record.status, v_report_record.total_deeds;
      END IF;

      -- Calculate missed deeds
      IF v_report_record.id IS NULL THEN
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'Calculation: NO REPORT -> Missed all % deeds', v_missed_deeds;
      ELSIF v_report_record.status = 'draft' THEN
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'Calculation: DRAFT REPORT -> Missed all % deeds', v_missed_deeds;
      ELSIF v_report_record.status = 'submitted' THEN
        v_missed_deeds := v_target_deeds - COALESCE(v_report_record.total_deeds, 0);
        RAISE NOTICE 'Calculation: SUBMITTED -> % - % = % missed deeds',
          v_target_deeds, COALESCE(v_report_record.total_deeds, 0), v_missed_deeds;
      ELSE
        v_missed_deeds := 0;
        RAISE NOTICE 'Calculation: Unknown status ''%'' -> 0 missed', v_report_record.status;
      END IF;

      RAISE NOTICE 'Missed deeds value: %', v_missed_deeds;
      RAISE NOTICE 'Is missed > 0? %', v_missed_deeds > 0;

      -- Create penalty if deeds were missed
      IF v_missed_deeds > 0 THEN
        v_penalty_amount := v_missed_deeds * v_penalty_per_deed;
        RAISE NOTICE 'CREATING PENALTY: % deeds × % = % shillings',
          v_missed_deeds, v_penalty_per_deed, v_penalty_amount;

        INSERT INTO penalties (
          user_id, report_id, amount, date_incurred,
          status, paid_amount, created_at, updated_at
        ) VALUES (
          v_user_record.id, v_report_record.id, v_penalty_amount, target_date,
          'unpaid', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        )
        RETURNING id INTO v_new_penalty_id;

        v_penalties_created := v_penalties_created + 1;

        RAISE NOTICE '✓ PENALTY CREATED - ID: %', v_new_penalty_id;
      ELSE
        RAISE NOTICE '✗ NO PENALTY - Missed deeds is NOT > 0 (value: %)', v_missed_deeds;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      v_errors := array_append(v_errors,
        format('Error: %s: %s', v_user_record.full_name, SQLERRM));
      RAISE WARNING 'ERROR processing user %: %', v_user_record.full_name, SQLERRM;
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

  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'RESULT: % users processed, % penalties created', v_users_processed, v_penalties_created;
  RAISE NOTICE '========================================';

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM,
    'timestamp', CURRENT_TIMESTAMP
  );
END;
$$;

GRANT EXECUTE ON FUNCTION calculate_penalties_for_date_debug(DATE) TO authenticated;

-- Run the debug version
SELECT calculate_penalties_for_date_debug('2025-10-27'::DATE);
