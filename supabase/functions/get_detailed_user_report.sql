-- Supabase RPC Function: Get Detailed User Report with Date Range
-- This function fetches comprehensive user report data including all deed entries for each day

CREATE OR REPLACE FUNCTION get_detailed_user_report(
  p_user_id UUID,
  p_start_date DATE,
  p_end_date DATE
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_result JSON;
  v_user_info JSON;
  v_daily_reports JSON;
  v_total_reports INT;
  v_avg_deeds DECIMAL(4,1);
  v_compliance_rate DECIMAL(5,2);
  v_faraid_compliance DECIMAL(5,2);
  v_sunnah_compliance DECIMAL(5,2);
BEGIN
  -- Calculate statistics
  SELECT
    COUNT(DISTINCT dr.id),
    COALESCE(AVG(dr.total_deeds), 0),
    CASE
      WHEN COUNT(dr.id) > 0
      THEN (SUM(CASE WHEN dr.total_deeds >= 10 THEN 1 ELSE 0 END)::FLOAT / COUNT(dr.id)::FLOAT * 100)
      ELSE 0
    END,
    CASE
      WHEN COUNT(dr.id) > 0
      THEN (AVG(dr.faraid_count) / 5.0 * 100)
      ELSE 0
    END,
    CASE
      WHEN COUNT(dr.id) > 0
      THEN (AVG(dr.sunnah_count) / 5.0 * 100)
      ELSE 0
    END
  INTO v_total_reports, v_avg_deeds, v_compliance_rate, v_faraid_compliance, v_sunnah_compliance
  FROM deeds_reports dr
  WHERE dr.user_id = p_user_id
    AND dr.report_date BETWEEN p_start_date AND p_end_date
    AND dr.status = 'submitted';

  -- Get user information
  SELECT json_build_object(
    'user_id', u.id,
    'full_name', u.name,
    'email', u.email,
    'phone_number', u.phone,
    'profile_photo_url', u.photo_url,
    'membership_status', u.membership_status,
    'member_since', u.created_at,
    'start_date', p_start_date,
    'end_date', p_end_date,
    'current_balance', COALESCE(us.current_penalty_balance, 0),
    'total_reports_in_range', v_total_reports,
    'average_deeds', v_avg_deeds,
    'compliance_rate', v_compliance_rate,
    'faraid_compliance', v_faraid_compliance,
    'sunnah_compliance', v_sunnah_compliance,
    'achievement_tags', COALESCE(
      (SELECT json_agg(st.display_name)
       FROM user_tags ut
       JOIN special_tags st ON st.id = ut.tag_id
       WHERE ut.user_id = p_user_id),
      '[]'::json
    )
  ) INTO v_user_info
  FROM users u
  LEFT JOIN user_statistics us ON us.user_id = u.id
  WHERE u.id = p_user_id;

  -- Get daily reports with deed entries
  SELECT json_agg(
    json_build_object(
      'report_date', dr.report_date,
      'status', dr.status,
      'total_deeds', dr.total_deeds,
      'faraid_count', dr.faraid_count,
      'sunnah_count', dr.sunnah_count,
      'submitted_at', dr.submitted_at,
      'deed_entries', (
        SELECT json_agg(
          json_build_object(
            'deed_name', dt.deed_name,
            'deed_key', dt.deed_key,
            'category', dt.category,
            'value_type', dt.value_type,
            'deed_value', de.deed_value,
            'sort_order', dt.sort_order
          ) ORDER BY dt.sort_order
        )
        FROM deed_entries de
        JOIN deed_templates dt ON dt.id = de.deed_template_id
        WHERE de.report_id = dr.id
      )
    ) ORDER BY dr.report_date DESC
  ) INTO v_daily_reports
  FROM deeds_reports dr
  WHERE dr.user_id = p_user_id
    AND dr.report_date BETWEEN p_start_date AND p_end_date
    AND dr.status = 'submitted';

  -- Combine results
  v_result := json_build_object(
    'user_id', (v_user_info->>'user_id')::UUID,
    'full_name', v_user_info->>'full_name',
    'email', v_user_info->>'email',
    'phone_number', v_user_info->>'phone_number',
    'profile_photo_url', v_user_info->>'profile_photo_url',
    'membership_status', v_user_info->>'membership_status',
    'member_since', v_user_info->>'member_since',
    'start_date', p_start_date,
    'end_date', p_end_date,
    'current_balance', (v_user_info->>'current_balance')::DECIMAL,
    'total_reports_in_range', v_total_reports,
    'average_deeds', v_avg_deeds,
    'compliance_rate', v_compliance_rate,
    'faraid_compliance', v_faraid_compliance,
    'sunnah_compliance', v_sunnah_compliance,
    'achievement_tags', v_user_info->'achievement_tags',
    'daily_reports', COALESCE(v_daily_reports, '[]'::json)
  );

  RETURN v_result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_detailed_user_report(UUID, DATE, DATE) TO authenticated;

-- Comment
COMMENT ON FUNCTION get_detailed_user_report IS 'Fetches detailed user report with all deed entries for a specified date range';
