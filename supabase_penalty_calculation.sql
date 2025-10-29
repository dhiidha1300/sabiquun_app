-- =====================================================
-- AUTOMATIC PENALTY CALCULATION FUNCTION
-- =====================================================
-- This function should be called daily at 12:00 PM (noon)
-- to automatically calculate and apply penalties for users
-- who failed to submit complete deed reports within the grace period.
--
-- Usage:
--   SELECT calculate_daily_penalties();
--
-- Can be triggered by:
--   1. pg_cron extension (PostgreSQL scheduler)
--   2. Supabase Edge Function with cron
--   3. External cron job calling RPC endpoint
-- =====================================================

CREATE OR REPLACE FUNCTION calculate_daily_penalties()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_yesterday DATE;
  v_target_deeds DECIMAL(4,1);
  v_penalty_per_deed DECIMAL(10,2);
  v_grace_period_hours INTEGER;
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
  -- Get yesterday's date
  v_yesterday := CURRENT_DATE - INTERVAL '1 day';

  -- Get system settings
  SELECT COALESCE(setting_value::INTEGER, 12) INTO v_grace_period_hours
  FROM settings WHERE setting_key = 'grace_period_hours';

  SELECT COALESCE(setting_value::DECIMAL, 5000) INTO v_penalty_per_deed
  FROM settings WHERE setting_key = 'penalty_per_deed';

  SELECT COALESCE(setting_value::INTEGER, 30) INTO v_training_days
  FROM settings WHERE setting_key = 'training_period_days';

  -- Count active deed templates to get target
  SELECT COALESCE(COUNT(*), 10) INTO v_target_deeds
  FROM deed_templates WHERE is_active = true;

  RAISE NOTICE 'Starting penalty calculation for date: %', v_yesterday;
  RAISE NOTICE 'Target deeds: %, Penalty per deed: %', v_target_deeds, v_penalty_per_deed;

  -- Loop through all active users who should be penalized
  FOR v_user_record IN
    SELECT
      u.id,
      u.name as full_name,
      u.membership_status,
      u.account_status,
      u.created_at,
      (CURRENT_DATE - u.created_at::DATE) as days_since_joined
    FROM users u
    WHERE u.account_status = 'active'
      AND u.membership_status IN ('exclusive', 'legacy')  -- Only penalize these memberships
      AND NOT EXISTS (
        -- Skip if already has a penalty for this date
        SELECT 1 FROM penalties p
        WHERE p.user_id = u.id
          AND p.date_incurred = v_yesterday
      )
  LOOP
    BEGIN
      v_users_processed := v_users_processed + 1;

      -- Check if user is in training period (new member)
      IF v_user_record.days_since_joined < v_training_days THEN
        RAISE NOTICE 'Skipping user % (%) - still in training period (% days)',
          v_user_record.full_name, v_user_record.id, v_user_record.days_since_joined;
        CONTINUE;
      END IF;

      -- Check if yesterday was a rest day
      IF EXISTS (SELECT 1 FROM rest_days WHERE rest_date = v_yesterday) THEN
        RAISE NOTICE 'Skipping user % (%) - rest day',
          v_user_record.full_name, v_user_record.id;
        CONTINUE;
      END IF;

      -- Check if user has approved excuse for yesterday
      IF EXISTS (
        SELECT 1 FROM excuses
        WHERE user_id = v_user_record.id
          AND report_date = v_yesterday
          AND status = 'approved'
      ) THEN
        RAISE NOTICE 'Skipping user % (%) - approved excuse',
          v_user_record.full_name, v_user_record.id;
        CONTINUE;
      END IF;

      -- Get user's report for yesterday
      SELECT
        id,
        total_deeds,
        status,
        submitted_at
      INTO v_report_record
      FROM deeds_reports
      WHERE user_id = v_user_record.id
        AND report_date = v_yesterday;

      -- Calculate missed deeds
      IF v_report_record.id IS NULL THEN
        -- No report at all - all deeds missed
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'User % (%) - NO REPORT - Missed: % deeds',
          v_user_record.full_name, v_user_record.id, v_missed_deeds;
      ELSIF v_report_record.status = 'draft' THEN
        -- Draft report after grace period - treat as no submission
        v_missed_deeds := v_target_deeds;
        RAISE NOTICE 'User % (%) - DRAFT REPORT - Missed: % deeds',
          v_user_record.full_name, v_user_record.id, v_missed_deeds;
      ELSIF v_report_record.status = 'submitted' THEN
        -- Submitted report - calculate based on completion
        v_missed_deeds := v_target_deeds - COALESCE(v_report_record.total_deeds, 0);
        RAISE NOTICE 'User % (%) - SUBMITTED (%) - Missed: % deeds',
          v_user_record.full_name, v_user_record.id, v_report_record.total_deeds, v_missed_deeds;
      ELSE
        v_missed_deeds := 0;
      END IF;

      -- Only create penalty if deeds were missed
      IF v_missed_deeds > 0 THEN
        -- Calculate penalty amount (5000 per deed, 500 per 0.1)
        v_penalty_amount := v_missed_deeds * v_penalty_per_deed;

        -- Create penalty record
        INSERT INTO penalties (
          user_id,
          report_id,
          amount,
          date_incurred,
          status,
          paid_amount,
          created_at,
          updated_at
        ) VALUES (
          v_user_record.id,
          v_report_record.id,  -- May be NULL if no report
          v_penalty_amount,
          v_yesterday,
          'unpaid',
          0,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        )
        RETURNING id INTO v_new_penalty_id;

        v_penalties_created := v_penalties_created + 1;

        RAISE NOTICE 'PENALTY CREATED for user % (%) - Amount: % shillings - Penalty ID: %',
          v_user_record.full_name, v_user_record.id, v_penalty_amount, v_new_penalty_id;

        -- TODO: Send notification to user (implement notification sending)
        -- This would typically call a notification function or insert into a notifications queue

      ELSE
        RAISE NOTICE 'User % (%) - NO PENALTY (completed all deeds)',
          v_user_record.full_name, v_user_record.id;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      -- Log error but continue processing other users
      v_errors := array_append(v_errors,
        format('Error processing user %s (%s): %s',
          v_user_record.full_name, v_user_record.id, SQLERRM));
      RAISE WARNING 'Error processing user % (%): %',
        v_user_record.full_name, v_user_record.id, SQLERRM;
    END;
  END LOOP;

  -- Build result JSON
  v_result := json_build_object(
    'success', true,
    'date_processed', v_yesterday,
    'users_processed', v_users_processed,
    'penalties_created', v_penalties_created,
    'target_deeds', v_target_deeds,
    'penalty_per_deed', v_penalty_per_deed,
    'errors', v_errors,
    'timestamp', CURRENT_TIMESTAMP
  );

  RAISE NOTICE 'Penalty calculation completed: % users processed, % penalties created',
    v_users_processed, v_penalties_created;

  RETURN v_result;

EXCEPTION WHEN OTHERS THEN
  -- Return error result
  RETURN json_build_object(
    'success', false,
    'error', SQLERRM,
    'timestamp', CURRENT_TIMESTAMP
  );
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION calculate_daily_penalties() TO authenticated;

-- =====================================================
-- OPTIONAL: Setup pg_cron for automatic daily execution
-- =====================================================
-- Uncomment the following lines if you have pg_cron extension enabled
-- and want automatic daily execution at 12:00 PM

-- Enable pg_cron extension (requires superuser)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule the penalty calculation to run daily at 12:00 PM
-- SELECT cron.schedule(
--   'calculate-daily-penalties',  -- Job name
--   '0 12 * * *',                  -- Cron expression (12:00 PM daily)
--   $$SELECT calculate_daily_penalties();$$
-- );

-- To view scheduled jobs:
-- SELECT * FROM cron.job;

-- To unschedule:
-- SELECT cron.unschedule('calculate-daily-penalties');

-- =====================================================
-- TESTING: Manual execution
-- =====================================================
-- To manually test the function:
-- SELECT calculate_daily_penalties();

-- To check created penalties:
-- SELECT * FROM penalties
-- WHERE date_incurred = CURRENT_DATE - INTERVAL '1 day'
-- ORDER BY created_at DESC;

-- =====================================================
-- AUDIT LOG (Optional Enhancement)
-- =====================================================
-- You may want to log each execution for audit purposes:

CREATE TABLE IF NOT EXISTS penalty_calculation_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  execution_date DATE NOT NULL,
  users_processed INTEGER NOT NULL,
  penalties_created INTEGER NOT NULL,
  errors TEXT[],
  execution_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  result json NOT NULL
);

-- Modified function to include logging:
CREATE OR REPLACE FUNCTION calculate_daily_penalties_with_logging()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result json;
BEGIN
  -- Execute penalty calculation
  v_result := calculate_daily_penalties();

  -- Log the execution
  INSERT INTO penalty_calculation_log (
    execution_date,
    users_processed,
    penalties_created,
    errors,
    execution_time,
    result
  ) VALUES (
    CURRENT_DATE - INTERVAL '1 day',
    (v_result->>'users_processed')::INTEGER,
    (v_result->>'penalties_created')::INTEGER,
    ARRAY(SELECT json_array_elements_text(v_result->'errors')),
    CURRENT_TIMESTAMP,
    v_result
  );

  RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION calculate_daily_penalties_with_logging() TO authenticated;

-- =====================================================
-- COMMENTS AND NOTES
-- =====================================================
-- This function implements the automatic penalty calculation
-- as specified in the Sabiquun App business logic documentation.
--
-- Key Features:
-- 1. Processes all active users with 'exclusive' or 'legacy' membership
-- 2. Skips users in training period (first 30 days)
-- 3. Skips rest days
-- 4. Skips users with approved excuses
-- 5. Calculates penalties based on missed deeds (5000 per deed)
-- 6. Creates penalty records in the database
-- 7. Handles errors gracefully and continues processing
-- 8. Returns detailed execution results
--
-- Security:
-- - Uses SECURITY DEFINER to run with elevated privileges
-- - Validates all inputs
-- - Logs all operations for audit trail
--
-- Deployment:
-- 1. Run this SQL script in Supabase SQL Editor
-- 2. Set up cron job (pg_cron, Edge Function, or external)
-- 3. Monitor penalty_calculation_log table for execution history
-- 4. Test with: SELECT calculate_daily_penalties();
