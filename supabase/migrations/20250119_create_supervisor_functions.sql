-- Migration: Create Supervisor Functions
-- Description: Creates the RPC functions needed for supervisor features
-- Date: 2025-01-19

-- ============================================================================
-- Function: get_leaderboard_rankings
-- Description: Get leaderboard rankings for a specific period
-- Parameters:
--   - period: 'daily', 'weekly', 'monthly', or 'all-time'
--   - limit_count: Maximum number of entries to return
-- Returns: Array of leaderboard entries with user info and rankings
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_leaderboard_rankings(
  period TEXT,
  limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
  rank BIGINT,
  user_id UUID,
  user_name VARCHAR(255),
  total_deeds DECIMAL(10,1),
  average_deeds DECIMAL(4,1),
  special_tags JSONB,
  photo_url TEXT,
  membership_status VARCHAR(50)
) AS $$
DECLARE
  start_date DATE;
  end_date DATE;
BEGIN
  -- Calculate date range based on period
  end_date := CURRENT_DATE;

  CASE period
    WHEN 'daily' THEN
      start_date := CURRENT_DATE;
    WHEN 'weekly' THEN
      start_date := date_trunc('week', CURRENT_DATE)::DATE;
    WHEN 'monthly' THEN
      start_date := date_trunc('month', CURRENT_DATE)::DATE;
    WHEN 'all-time' THEN
      start_date := '2000-01-01'::DATE; -- Far back date for all-time
    ELSE
      start_date := date_trunc('week', CURRENT_DATE)::DATE; -- Default to weekly
  END CASE;

  -- Get leaderboard rankings
  RETURN QUERY
  WITH user_deed_stats AS (
    SELECT
      u.id AS user_id,
      u.name AS user_name,
      u.photo_url,
      u.membership_status,
      COALESCE(SUM(dr.total_deeds), 0) AS total_deeds,
      CASE
        WHEN COUNT(dr.id) > 0 THEN
          COALESCE(SUM(dr.total_deeds) / COUNT(dr.id), 0)
        ELSE 0
      END AS average_deeds
    FROM users u
    LEFT JOIN deeds_reports dr ON dr.user_id = u.id
      AND dr.report_date >= start_date
      AND dr.report_date <= end_date
      AND dr.status = 'submitted'
    WHERE u.account_status = 'active'
    GROUP BY u.id, u.name, u.photo_url, u.membership_status
  ),
  user_special_tags AS (
    SELECT
      ut.user_id,
      jsonb_agg(
        jsonb_build_object(
          'tag_id', st.id,
          'tag_key', st.tag_key,
          'name', st.display_name
        )
      ) AS tags
    FROM user_tags ut
    JOIN special_tags st ON st.id = ut.tag_id
    WHERE ut.expires_at IS NULL OR ut.expires_at > NOW()
    GROUP BY ut.user_id
  ),
  ranked_users AS (
    SELECT
      ROW_NUMBER() OVER (ORDER BY uds.total_deeds DESC, uds.average_deeds DESC) AS rank,
      uds.user_id,
      uds.user_name,
      uds.total_deeds,
      uds.average_deeds,
      COALESCE(ust.tags, '[]'::jsonb) AS special_tags,
      uds.photo_url,
      uds.membership_status
    FROM user_deed_stats uds
    LEFT JOIN user_special_tags ust ON ust.user_id = uds.user_id
    WHERE uds.total_deeds > 0  -- Only include users with deeds
  )
  SELECT *
  FROM ranked_users
  ORDER BY rank
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_leaderboard_rankings(TEXT, INTEGER) TO authenticated;

-- ============================================================================
-- Function: get_users_at_risk
-- Description: Get users with penalty balance above threshold
-- Parameters:
--   - balance_threshold: Minimum balance to be considered "at risk"
-- Returns: Array of user reports with high balances
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_users_at_risk(
  balance_threshold DECIMAL DEFAULT 100000
)
RETURNS TABLE (
  user_id UUID,
  user_name VARCHAR(255),
  email VARCHAR(255),
  phone VARCHAR(50),
  photo_url TEXT,
  membership_status VARCHAR(50),
  current_balance DECIMAL(10,2),
  total_deeds_today DECIMAL(4,1),
  submitted_today BOOLEAN,
  last_report_date DATE,
  compliance_rate DECIMAL(5,2)
) AS $$
BEGIN
  RETURN QUERY
  WITH user_balances AS (
    SELECT
      u.id AS user_id,
      u.name AS user_name,
      u.email,
      u.phone,
      u.photo_url,
      u.membership_status,
      COALESCE(SUM(CASE WHEN p.status = 'unpaid' THEN p.amount - p.paid_amount ELSE 0 END), 0) AS current_balance
    FROM users u
    LEFT JOIN penalties p ON p.user_id = u.id
    WHERE u.account_status = 'active'
    GROUP BY u.id, u.name, u.email, u.phone, u.photo_url, u.membership_status
    HAVING COALESCE(SUM(CASE WHEN p.status = 'unpaid' THEN p.amount - p.paid_amount ELSE 0 END), 0) >= balance_threshold
  ),
  user_today_stats AS (
    SELECT
      dr.user_id,
      dr.total_deeds,
      TRUE AS submitted_today
    FROM deeds_reports dr
    WHERE dr.report_date = CURRENT_DATE
      AND dr.status = 'submitted'
  ),
  user_last_report AS (
    SELECT DISTINCT ON (dr.user_id)
      dr.user_id,
      dr.report_date AS last_report_date
    FROM deeds_reports dr
    WHERE dr.status = 'submitted'
    ORDER BY dr.user_id, dr.report_date DESC
  ),
  user_compliance AS (
    SELECT
      dr.user_id,
      CASE
        WHEN COUNT(dr.id) > 0 THEN
          (COUNT(CASE WHEN dr.total_deeds >= 10 THEN 1 END)::DECIMAL / COUNT(dr.id)::DECIMAL) * 100
        ELSE 0
      END AS compliance_rate
    FROM deeds_reports dr
    WHERE dr.status = 'submitted'
      AND dr.report_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY dr.user_id
  )
  SELECT
    ub.user_id,
    ub.user_name,
    ub.email,
    ub.phone,
    ub.photo_url,
    ub.membership_status,
    ub.current_balance,
    COALESCE(uts.total_deeds, 0) AS total_deeds_today,
    COALESCE(uts.submitted_today, FALSE) AS submitted_today,
    ulr.last_report_date,
    COALESCE(uc.compliance_rate, 0) AS compliance_rate
  FROM user_balances ub
  LEFT JOIN user_today_stats uts ON uts.user_id = ub.user_id
  LEFT JOIN user_last_report ulr ON ulr.user_id = ub.user_id
  LEFT JOIN user_compliance uc ON uc.user_id = ub.user_id
  ORDER BY ub.current_balance DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_users_at_risk(DECIMAL) TO authenticated;

-- ============================================================================
-- Function: get_all_user_reports
-- Description: Get all user reports with filtering and sorting
-- Parameters:
--   - search_query: Search by user name or email
--   - membership_status_filter: Filter by membership status
--   - compliance_filter: Filter by compliance ('high', 'medium', 'low')
--   - report_status_filter: Filter by report status ('submitted', 'not_submitted')
--   - sort_by: Sort order ('name', 'balance', 'compliance', 'streak')
-- Returns: Array of user reports with detailed information
-- ============================================================================
CREATE OR REPLACE FUNCTION public.get_all_user_reports(
  search_query TEXT DEFAULT NULL,
  membership_status_filter TEXT DEFAULT NULL,
  compliance_filter TEXT DEFAULT NULL,
  report_status_filter TEXT DEFAULT NULL,
  sort_by TEXT DEFAULT 'name'
)
RETURNS TABLE (
  user_id UUID,
  full_name VARCHAR(255),
  email VARCHAR(255),
  phone_number VARCHAR(50),
  profile_photo_url TEXT,
  membership_status VARCHAR(50),
  member_since TIMESTAMP,
  today_deeds INTEGER,
  today_target INTEGER,
  has_submitted_today BOOLEAN,
  last_report_time TIMESTAMP,
  compliance_rate DECIMAL(5,2),
  current_streak INTEGER,
  total_reports INTEGER,
  current_balance DECIMAL(10,2),
  is_at_risk BOOLEAN,
  days_without_report INTEGER
) AS $$
BEGIN
  RETURN QUERY
  WITH user_today_report AS (
    SELECT
      dr.user_id,
      dr.total_deeds,
      TRUE AS submitted_today,
      dr.created_at AS report_time
    FROM deeds_reports dr
    WHERE dr.report_date = CURRENT_DATE
      AND dr.status = 'submitted'
  ),
  user_last_report AS (
    SELECT DISTINCT ON (dr.user_id)
      dr.user_id,
      dr.created_at AS last_report_time
    FROM deeds_reports dr
    WHERE dr.status = 'submitted'
    ORDER BY dr.user_id, dr.created_at DESC
  ),
  user_compliance AS (
    SELECT
      dr.user_id,
      CASE
        WHEN COUNT(dr.id) > 0 THEN
          (COUNT(CASE WHEN dr.total_deeds >= 10 THEN 1 END)::DECIMAL / COUNT(dr.id)::DECIMAL) * 100
        ELSE 0
      END AS compliance_rate,
      COUNT(dr.id) AS total_reports
    FROM deeds_reports dr
    WHERE dr.status = 'submitted'
      AND dr.report_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY dr.user_id
  ),
  user_streak AS (
    SELECT
      dr.user_id,
      COUNT(DISTINCT dr.report_date) AS current_streak
    FROM deeds_reports dr
    WHERE dr.status = 'submitted'
      AND dr.report_date >= CURRENT_DATE - INTERVAL '7 days'
      AND dr.total_deeds >= 10
    GROUP BY dr.user_id
  ),
  user_balance AS (
    SELECT
      p.user_id,
      COALESCE(SUM(CASE WHEN p.status = 'unpaid' THEN p.amount - p.paid_amount ELSE 0 END), 0) AS current_balance
    FROM penalties p
    GROUP BY p.user_id
  )
  SELECT
    u.id AS user_id,
    u.name AS full_name,
    u.email,
    u.phone AS phone_number,
    u.photo_url AS profile_photo_url,
    u.membership_status,
    u.created_at AS member_since,
    COALESCE(utr.total_deeds::INTEGER, 0) AS today_deeds,
    10 AS today_target,
    COALESCE(utr.submitted_today, FALSE) AS has_submitted_today,
    ulr.last_report_time,
    COALESCE(uc.compliance_rate, 0) AS compliance_rate,
    COALESCE(us.current_streak::INTEGER, 0) AS current_streak,
    COALESCE(uc.total_reports::INTEGER, 0) AS total_reports,
    COALESCE(ub.current_balance, 0) AS current_balance,
    COALESCE(ub.current_balance, 0) >= 100000 AS is_at_risk,
    CASE
      WHEN ulr.last_report_time IS NULL THEN 999
      ELSE EXTRACT(DAY FROM (NOW() - ulr.last_report_time))::INTEGER
    END AS days_without_report
  FROM users u
  LEFT JOIN user_today_report utr ON utr.user_id = u.id
  LEFT JOIN user_last_report ulr ON ulr.user_id = u.id
  LEFT JOIN user_compliance uc ON uc.user_id = u.id
  LEFT JOIN user_streak us ON us.user_id = u.id
  LEFT JOIN user_balance ub ON ub.user_id = u.id
  WHERE u.account_status = 'active'
    AND (search_query IS NULL OR
         u.name ILIKE '%' || search_query || '%' OR
         u.email ILIKE '%' || search_query || '%')
    AND (membership_status_filter IS NULL OR u.membership_status = membership_status_filter)
    AND (compliance_filter IS NULL OR
         (compliance_filter = 'high' AND COALESCE(uc.compliance_rate, 0) >= 80) OR
         (compliance_filter = 'medium' AND COALESCE(uc.compliance_rate, 0) >= 50 AND COALESCE(uc.compliance_rate, 0) < 80) OR
         (compliance_filter = 'low' AND COALESCE(uc.compliance_rate, 0) < 50))
    AND (report_status_filter IS NULL OR
         (report_status_filter = 'submitted' AND utr.submitted_today = TRUE) OR
         (report_status_filter = 'not_submitted' AND COALESCE(utr.submitted_today, FALSE) = FALSE))
  ORDER BY
    CASE WHEN sort_by = 'name' THEN u.name END ASC,
    CASE WHEN sort_by = 'balance' THEN COALESCE(ub.current_balance, 0) END DESC,
    CASE WHEN sort_by = 'compliance' THEN COALESCE(uc.compliance_rate, 0) END DESC,
    CASE WHEN sort_by = 'streak' THEN COALESCE(us.current_streak, 0) END DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.get_all_user_reports(TEXT, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- ============================================================================
-- Add comments for documentation
-- ============================================================================
COMMENT ON FUNCTION public.get_leaderboard_rankings IS 'Returns leaderboard rankings for users based on their deed performance for a given period';
COMMENT ON FUNCTION public.get_users_at_risk IS 'Returns users with penalty balances above the specified threshold, sorted by balance';
COMMENT ON FUNCTION public.get_all_user_reports IS 'Returns all user reports with filtering and sorting capabilities for supervisor dashboard';
