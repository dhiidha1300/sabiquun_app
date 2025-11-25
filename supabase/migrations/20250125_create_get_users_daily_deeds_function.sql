-- Migration: Create get_users_daily_deeds Function
-- Description: Creates RPC function to get daily deeds for users in a date range
-- Date: 2025-01-25

-- ============================================================================
-- Function: get_users_daily_deeds
-- Description: Get daily deeds for all users (or specific users) in a date range
-- Parameters:
--   - p_start_date: Start date of the range
--   - p_end_date: End date of the range
--   - p_user_ids: Optional array of user IDs to filter
-- Returns: JSON object with structure: { user_id: { date: { deeds, target } } }
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_users_daily_deeds(
  p_start_date DATE,
  p_end_date DATE,
  p_user_ids UUID[] DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
  result JSONB := '{}'::jsonb;
  user_data JSONB;
  date_data JSONB;
  current_user_id UUID;
  active_deeds_count INTEGER;
BEGIN
  -- Get count of active deed templates (this is the target)
  SELECT COUNT(*) INTO active_deeds_count
  FROM deed_templates
  WHERE is_active = TRUE;

  -- If no active deeds found, default to 10
  IF active_deeds_count IS NULL OR active_deeds_count = 0 THEN
    active_deeds_count := 10;
  END IF;

  -- Build the result JSON structure
  FOR current_user_id IN
    SELECT DISTINCT user_id
    FROM deeds_reports
    WHERE report_date >= p_start_date
      AND report_date <= p_end_date
      AND status = 'submitted'
      AND (p_user_ids IS NULL OR user_id = ANY(p_user_ids))
  LOOP
    -- Build date data for this user
    SELECT jsonb_object_agg(
      report_date::text,
      jsonb_build_object(
        'deeds', COALESCE(total_deeds::integer, 0),
        'target', active_deeds_count
      )
    ) INTO date_data
    FROM deeds_reports
    WHERE user_id = current_user_id
      AND report_date >= p_start_date
      AND report_date <= p_end_date
      AND status = 'submitted';

    -- Add this user's data to result
    result := result || jsonb_build_object(current_user_id::text, date_data);
  END LOOP;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_daily_deeds(DATE, DATE, UUID[]) TO authenticated;

-- ============================================================================
-- Add comment for documentation
-- ============================================================================
COMMENT ON FUNCTION public.get_users_daily_deeds IS 'Returns daily deeds data for users in a date range with calculated targets based on active deed templates';
