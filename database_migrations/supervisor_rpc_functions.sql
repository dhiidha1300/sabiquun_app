-- Supervisor RPC Functions
-- These functions provide data for supervisor features

-- Function to get all user reports with filters
CREATE OR REPLACE FUNCTION get_all_user_reports(
  search_query TEXT DEFAULT NULL,
  membership_status_filter TEXT DEFAULT NULL,
  compliance_filter TEXT DEFAULT NULL,
  report_status_filter TEXT DEFAULT NULL,
  sort_by TEXT DEFAULT 'name'
)
RETURNS TABLE (
  "userId" UUID,
  "fullName" TEXT,
  email TEXT,
  "phoneNumber" TEXT,
  "profilePhotoUrl" TEXT,
  "membershipStatus" TEXT,
  "memberSince" TIMESTAMPTZ,
  "todayDeeds" INTEGER,
  "todayTarget" INTEGER,
  "hasSubmittedToday" BOOLEAN,
  "lastReportTime" TIMESTAMPTZ,
  "complianceRate" NUMERIC,
  "currentStreak" INTEGER,
  "totalReports" INTEGER,
  "currentBalance" NUMERIC,
  "isAtRisk" BOOLEAN,
  "daysWithoutReport" INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  WITH user_stats AS (
    SELECT
      u.id,
      u.full_name,
      u.email,
      u.phone_number,
      u.profile_photo_url,
      u.membership_status,
      u.created_at AS member_since,
      COALESCE(today_report.total_value, 0)::INTEGER AS today_deeds,
      10 AS today_target,
      (today_report.id IS NOT NULL) AS has_submitted_today,
      last_report.submitted_at AS last_report_time,
      COALESCE(
        (SELECT COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT DATE(dr.submitted_at)), 0)
         FROM deed_reports dr
         WHERE dr.user_id = u.id
         AND dr.submitted_at >= NOW() - INTERVAL '30 days'), 0
      ) / 10 AS compliance_rate,
      COALESCE(u.current_streak, 0) AS current_streak,
      (SELECT COUNT(*) FROM deed_reports WHERE user_id = u.id)::INTEGER AS total_reports,
      COALESCE((SELECT SUM(amount) FROM penalties WHERE user_id = u.id AND paid = false), 0) AS current_balance,
      COALESCE((SELECT SUM(amount) FROM penalties WHERE user_id = u.id AND paid = false), 0) >= 100000 AS is_at_risk,
      COALESCE(EXTRACT(DAY FROM NOW() - last_report.submitted_at)::INTEGER, 999) AS days_without_report
    FROM users u
    LEFT JOIN LATERAL (
      SELECT id, total_value, submitted_at
      FROM deed_reports
      WHERE user_id = u.id
      AND DATE(submitted_at) = CURRENT_DATE
      ORDER BY submitted_at DESC
      LIMIT 1
    ) today_report ON true
    LEFT JOIN LATERAL (
      SELECT id, submitted_at
      FROM deed_reports
      WHERE user_id = u.id
      ORDER BY submitted_at DESC
      LIMIT 1
    ) last_report ON true
    WHERE u.status = 'active'
    AND u.role = 'user'
  )
  SELECT
    us.id,
    us.full_name,
    us.email,
    us.phone_number,
    us.profile_photo_url,
    us.membership_status,
    us.member_since,
    us.today_deeds,
    us.today_target,
    us.has_submitted_today,
    us.last_report_time,
    us.compliance_rate,
    us.current_streak,
    us.total_reports,
    us.current_balance,
    us.is_at_risk,
    us.days_without_report
  FROM user_stats us
  WHERE
    -- Search filter
    (search_query IS NULL OR us.full_name ILIKE '%' || search_query || '%' OR us.email ILIKE '%' || search_query || '%')
    -- Membership filter
    AND (membership_status_filter IS NULL OR us.membership_status = membership_status_filter)
    -- Compliance filter
    AND (compliance_filter IS NULL OR
      (compliance_filter = 'High (90%+)' AND us.compliance_rate >= 0.9) OR
      (compliance_filter = 'Medium (70-89%)' AND us.compliance_rate >= 0.7 AND us.compliance_rate < 0.9) OR
      (compliance_filter = 'Low (<70%)' AND us.compliance_rate < 0.7)
    )
    -- Report status filter
    AND (report_status_filter IS NULL OR
      (report_status_filter = 'Submitted' AND us.has_submitted_today) OR
      (report_status_filter = 'Not Submitted' AND NOT us.has_submitted_today)
    )
  ORDER BY
    CASE
      WHEN sort_by = 'name' THEN us.full_name
      ELSE NULL
    END ASC,
    CASE
      WHEN sort_by = 'compliance' THEN us.compliance_rate
      WHEN sort_by = 'balance' THEN us.current_balance
      ELSE NULL
    END DESC,
    CASE
      WHEN sort_by = 'recent' THEN us.last_report_time
      ELSE NULL
    END DESC;
END;
$$;

-- Function to get leaderboard rankings
CREATE OR REPLACE FUNCTION get_leaderboard_rankings(
  period TEXT DEFAULT 'weekly',
  limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
  rank INTEGER,
  "userId" UUID,
  "fullName" TEXT,
  "profilePhotoUrl" TEXT,
  "membershipStatus" TEXT,
  "averageDeeds" NUMERIC,
  "complianceRate" NUMERIC,
  "achievementTags" TEXT[],
  "hasFajrChampion" BOOLEAN,
  "currentStreak" INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  start_date TIMESTAMPTZ;
BEGIN
  -- Determine start date based on period
  start_date := CASE
    WHEN period = 'daily' THEN CURRENT_DATE
    WHEN period = 'weekly' THEN DATE_TRUNC('week', CURRENT_DATE)
    WHEN period = 'monthly' THEN DATE_TRUNC('month', CURRENT_DATE)
    ELSE '1970-01-01'::TIMESTAMPTZ
  END;

  RETURN QUERY
  WITH user_deeds AS (
    SELECT
      dr.user_id,
      AVG(dr.total_value) AS avg_deeds,
      COUNT(*)::NUMERIC / NULLIF(EXTRACT(DAY FROM NOW() - start_date), 0) AS compliance_rate
    FROM deed_reports dr
    WHERE dr.submitted_at >= start_date
    GROUP BY dr.user_id
  ),
  user_tags AS (
    SELECT
      uat.user_id,
      ARRAY_AGG(at.name) AS tags,
      BOOL_OR(at.name = 'Fajr Champion') AS has_fajr_champion
    FROM user_achievement_tags uat
    JOIN achievement_tags at ON at.id = uat.tag_id
    GROUP BY uat.user_id
  )
  SELECT
    ROW_NUMBER() OVER (ORDER BY ud.avg_deeds DESC)::INTEGER AS rank,
    u.id,
    u.full_name,
    u.profile_photo_url,
    u.membership_status,
    COALESCE(ud.avg_deeds, 0),
    COALESCE(ud.compliance_rate, 0),
    COALESCE(ut.tags, ARRAY[]::TEXT[]),
    COALESCE(ut.has_fajr_champion, false),
    COALESCE(u.current_streak, 0)
  FROM users u
  LEFT JOIN user_deeds ud ON ud.user_id = u.id
  LEFT JOIN user_tags ut ON ut.user_id = u.id
  WHERE u.status = 'active'
  AND u.role = 'user'
  ORDER BY ud.avg_deeds DESC NULLS LAST
  LIMIT limit_count;
END;
$$;

-- Function to get users at risk
CREATE OR REPLACE FUNCTION get_users_at_risk(
  balance_threshold NUMERIC DEFAULT 100000
)
RETURNS TABLE (
  "userId" UUID,
  "fullName" TEXT,
  email TEXT,
  "phoneNumber" TEXT,
  "profilePhotoUrl" TEXT,
  "membershipStatus" TEXT,
  "memberSince" TIMESTAMPTZ,
  "todayDeeds" INTEGER,
  "todayTarget" INTEGER,
  "hasSubmittedToday" BOOLEAN,
  "lastReportTime" TIMESTAMPTZ,
  "complianceRate" NUMERIC,
  "currentStreak" INTEGER,
  "totalReports" INTEGER,
  "currentBalance" NUMERIC,
  "isAtRisk" BOOLEAN,
  "daysWithoutReport" INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM get_all_user_reports()
  WHERE "currentBalance" >= balance_threshold
  ORDER BY "currentBalance" DESC;
END;
$$;

-- Function to get user detail for supervisor view
CREATE OR REPLACE FUNCTION get_user_detail_for_supervisor(
  target_user_id UUID
)
RETURNS TABLE (
  "userId" UUID,
  "fullName" TEXT,
  email TEXT,
  "phoneNumber" TEXT,
  "profilePhotoUrl" TEXT,
  "membershipStatus" TEXT,
  "memberSince" TIMESTAMPTZ,
  status TEXT,
  "overallCompliance" NUMERIC,
  "currentBalance" NUMERIC,
  "totalReports" INTEGER,
  "currentStreak" INTEGER,
  "longestStreak" INTEGER,
  "lastReportDate" TIMESTAMPTZ,
  "deedsThisWeek" INTEGER,
  "deedsThisMonth" INTEGER,
  "faraidCompliance" NUMERIC,
  "sunnahCompliance" NUMERIC,
  "achievementTags" TEXT[]
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    u.id,
    u.full_name,
    u.email,
    u.phone_number,
    u.profile_photo_url,
    u.membership_status,
    u.created_at,
    u.status,
    COALESCE(
      (SELECT COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT DATE(dr.submitted_at)), 0)
       FROM deed_reports dr
       WHERE dr.user_id = u.id), 0
    ) / 10 AS overall_compliance,
    COALESCE((SELECT SUM(amount) FROM penalties WHERE user_id = u.id AND paid = false), 0) AS current_balance,
    (SELECT COUNT(*)::INTEGER FROM deed_reports WHERE user_id = u.id) AS total_reports,
    COALESCE(u.current_streak, 0) AS current_streak,
    COALESCE(u.longest_streak, 0) AS longest_streak,
    (SELECT MAX(submitted_at) FROM deed_reports WHERE user_id = u.id) AS last_report_date,
    (SELECT COALESCE(SUM(total_value), 0)::INTEGER FROM deed_reports
     WHERE user_id = u.id AND submitted_at >= DATE_TRUNC('week', CURRENT_DATE)) AS deeds_this_week,
    (SELECT COALESCE(SUM(total_value), 0)::INTEGER FROM deed_reports
     WHERE user_id = u.id AND submitted_at >= DATE_TRUNC('month', CURRENT_DATE)) AS deeds_this_month,
    0.0 AS faraid_compliance, -- TODO: Calculate from deed values
    0.0 AS sunnah_compliance,  -- TODO: Calculate from deed values
    COALESCE(
      (SELECT ARRAY_AGG(at.name) FROM user_achievement_tags uat
       JOIN achievement_tags at ON at.id = uat.tag_id
       WHERE uat.user_id = u.id),
      ARRAY[]::TEXT[]
    ) AS achievement_tags
  FROM users u
  WHERE u.id = target_user_id;
END;
$$;

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION get_all_user_reports TO authenticated;
GRANT EXECUTE ON FUNCTION get_leaderboard_rankings TO authenticated;
GRANT EXECUTE ON FUNCTION get_users_at_risk TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_detail_for_supervisor TO authenticated;

COMMENT ON FUNCTION get_all_user_reports IS 'Get all user reports with filters for supervisor dashboard';
COMMENT ON FUNCTION get_leaderboard_rankings IS 'Get leaderboard rankings for specified period';
COMMENT ON FUNCTION get_users_at_risk IS 'Get users with high penalty balances';
COMMENT ON FUNCTION get_user_detail_for_supervisor IS 'Get detailed user information for supervisor view';
