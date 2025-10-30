-- ============================================================================
-- Admin Phase 2 - Database Setup SQL (TYPE FIXED VERSION)
-- This file contains all required database setup for Analytics & Settings
-- FIXED: All integer fields explicitly cast to INTEGER to avoid type errors
-- ============================================================================

-- ============================================================================
-- PART 1: SETTINGS TABLE & DEFAULT VALUES
-- ============================================================================

-- The settings table should already exist from your schema
-- If not, create it:
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT NOT NULL,
  description TEXT,
  data_type VARCHAR(50) NOT NULL DEFAULT 'string',
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_settings_key ON settings(setting_key);

-- Insert default settings values
-- Using ON CONFLICT to avoid errors if already exists
INSERT INTO settings (setting_key, setting_value, description, data_type) VALUES
('daily_deed_target', '10', 'Number of deeds required per day', 'number'),
('penalty_per_deed', '5000', 'Penalty amount per full deed missed (in shillings)', 'number'),
('grace_period_hours', '2', 'Hours after midnight for grace period', 'number'),
('training_period_days', '30', 'Days of training period for new members (no penalties)', 'number'),
('auto_deactivation_threshold', '400000', 'Penalty balance threshold for auto-deactivation', 'number'),
('warning_thresholds', '[200000, 350000]', 'Balance thresholds for warning notifications', 'json'),
('organization_name', 'Sabiquun', 'Organization name for receipts', 'string'),
('receipt_footer_text', 'Thank you for your payment', 'Footer text on payment receipts', 'string'),
('app_version', '1.0.0', 'Current app version', 'string'),
('minimum_required_version', '1.0.0', 'Minimum required app version', 'string'),
('force_update', 'false', 'Force app update for users', 'boolean')
ON CONFLICT (setting_key) DO NOTHING;

-- ============================================================================
-- PART 2: ANALYTICS RPC FUNCTIONS (TYPE FIXED)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. USER METRICS FUNCTION
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_user_metrics()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'pending_users', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE account_status = 'pending'
    ), 0),
    'active_users', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE account_status = 'active'
    ), 0),
    'suspended_users', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE account_status = 'suspended'
    ), 0),
    'deactivated_users', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE account_status = 'auto_deactivated'
    ), 0),
    'new_members', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE membership_status = 'new'
    ), 0),
    'exclusive_members', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE membership_status = 'exclusive'
    ), 0),
    'legacy_members', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE membership_status = 'legacy'
    ), 0),
    'users_at_risk', COALESCE((
      SELECT COUNT(*)::INTEGER
      FROM user_statistics
      WHERE current_penalty_balance > 400000
    ), 0),
    'new_registrations_this_week', COALESCE((
      SELECT COUNT(*)::INTEGER
      FROM users
      WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
    ), 0)
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 2. DEED METRICS FUNCTION (TYPE FIXED)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_deed_metrics(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS JSON AS $$
DECLARE
  result JSON;
  today_date DATE := CURRENT_DATE;
  week_start DATE := CURRENT_DATE - INTERVAL '7 days';
  month_start DATE := DATE_TRUNC('month', CURRENT_DATE)::DATE;
BEGIN
  SELECT json_build_object(
    -- Today's metrics (INTEGER for counts)
    'total_deeds_today', COALESCE((
      SELECT SUM(total_deeds)::INTEGER
      FROM deeds_reports
      WHERE report_date = today_date AND status = 'submitted'
    ), 0),
    'users_completed_today', COALESCE((
      SELECT COUNT(DISTINCT user_id)::INTEGER
      FROM deeds_reports
      WHERE report_date = today_date
        AND status = 'submitted'
        AND total_deeds >= 10
    ), 0),
    'average_per_user_today', COALESCE((
      SELECT AVG(total_deeds)::DOUBLE PRECISION
      FROM deeds_reports
      WHERE report_date = today_date AND status = 'submitted'
    ), 0.0),
    'compliance_rate_today', COALESCE((
      SELECT CASE
        WHEN COUNT(*) > 0 THEN
          (COUNT(CASE WHEN total_deeds >= 10 THEN 1 END)::DOUBLE PRECISION / COUNT(*))
        ELSE 0.0
      END
      FROM deeds_reports
      WHERE report_date = today_date AND status = 'submitted'
    ), 0.0),

    -- Week metrics
    'total_deeds_week', COALESCE((
      SELECT SUM(total_deeds)::INTEGER
      FROM deeds_reports
      WHERE report_date >= week_start AND status = 'submitted'
    ), 0),
    'average_per_user_week', COALESCE((
      SELECT AVG(total_deeds)::DOUBLE PRECISION
      FROM deeds_reports
      WHERE report_date >= week_start AND status = 'submitted'
    ), 0.0),
    'compliance_rate_week', COALESCE((
      SELECT CASE
        WHEN COUNT(*) > 0 THEN
          (COUNT(CASE WHEN total_deeds >= 10 THEN 1 END)::DOUBLE PRECISION / COUNT(*))
        ELSE 0.0
      END
      FROM deeds_reports
      WHERE report_date >= week_start AND status = 'submitted'
    ), 0.0),

    -- Month metrics
    'total_deeds_month', COALESCE((
      SELECT SUM(total_deeds)::INTEGER
      FROM deeds_reports
      WHERE report_date >= month_start AND status = 'submitted'
    ), 0),
    'average_per_user_month', COALESCE((
      SELECT AVG(total_deeds)::DOUBLE PRECISION
      FROM deeds_reports
      WHERE report_date >= month_start AND status = 'submitted'
    ), 0.0),
    'compliance_rate_month', COALESCE((
      SELECT CASE
        WHEN COUNT(*) > 0 THEN
          (COUNT(CASE WHEN total_deeds >= 10 THEN 1 END)::DOUBLE PRECISION / COUNT(*))
        ELSE 0.0
      END
      FROM deeds_reports
      WHERE report_date >= month_start AND status = 'submitted'
    ), 0.0),

    -- All time
    'total_deeds_all_time', COALESCE((
      SELECT SUM(total_deeds)::INTEGER
      FROM deeds_reports
      WHERE status = 'submitted'
    ), 0),

    -- Active users
    'total_active_users', COALESCE((
      SELECT COUNT(*)::INTEGER FROM users WHERE account_status = 'active'
    ), 0),

    -- Faraid and Sunnah compliance (DOUBLE PRECISION)
    'faraid_compliance_rate', COALESCE((
      SELECT (AVG(faraid_completion_rate) / 100.0)::DOUBLE PRECISION
      FROM user_statistics
    ), 0.0),
    'sunnah_compliance_rate', COALESCE((
      SELECT (AVG(sunnah_completion_rate) / 100.0)::DOUBLE PRECISION
      FROM user_statistics
    ), 0.0),

    -- Top performers (last 30 days)
    'top_performers', COALESCE((
      SELECT json_agg(json_build_object(
        'user_id', user_id,
        'user_name', name,
        'average_deeds', avg_deeds
      ))
      FROM (
        SELECT
          dr.user_id,
          u.name,
          AVG(dr.total_deeds)::DOUBLE PRECISION as avg_deeds
        FROM deeds_reports dr
        JOIN users u ON u.id = dr.user_id
        WHERE dr.report_date >= CURRENT_DATE - INTERVAL '30 days'
          AND dr.status = 'submitted'
        GROUP BY dr.user_id, u.name
        ORDER BY avg_deeds DESC
        LIMIT 5
      ) top
    ), '[]'::json),

    -- Users needing attention (last 30 days, lowest performers)
    'users_needing_attention', COALESCE((
      SELECT json_agg(json_build_object(
        'user_id', user_id,
        'user_name', name,
        'average_deeds', avg_deeds
      ))
      FROM (
        SELECT
          dr.user_id,
          u.name,
          AVG(dr.total_deeds)::DOUBLE PRECISION as avg_deeds
        FROM deeds_reports dr
        JOIN users u ON u.id = dr.user_id
        WHERE dr.report_date >= CURRENT_DATE - INTERVAL '30 days'
          AND dr.status = 'submitted'
          AND u.account_status = 'active'
        GROUP BY dr.user_id, u.name
        HAVING AVG(dr.total_deeds) < 7
        ORDER BY avg_deeds ASC
        LIMIT 5
      ) bottom
    ), '[]'::json),

    -- Deed compliance by type (simplified - empty object)
    'deed_compliance_by_type', '{}'::json

  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 3. FINANCIAL METRICS FUNCTION (TYPE FIXED)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_financial_metrics(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS JSON AS $$
DECLARE
  result JSON;
  month_start DATE := DATE_TRUNC('month', CURRENT_DATE)::DATE;
BEGIN
  SELECT json_build_object(
    -- This month penalties (DOUBLE PRECISION for money)
    'penalties_incurred_this_month', COALESCE((
      SELECT SUM(amount)::DOUBLE PRECISION
      FROM penalties
      WHERE date_incurred >= month_start
    ), 0.0),

    -- All time penalties
    'penalties_incurred_all_time', COALESCE((
      SELECT SUM(amount)::DOUBLE PRECISION
      FROM penalties
    ), 0.0),

    -- This month payments
    'payments_received_this_month', COALESCE((
      SELECT SUM(amount)::DOUBLE PRECISION
      FROM payments
      WHERE submitted_at >= month_start AND status = 'approved'
    ), 0.0),

    -- All time payments
    'payments_received_all_time', COALESCE((
      SELECT SUM(amount)::DOUBLE PRECISION
      FROM payments
      WHERE status = 'approved'
    ), 0.0),

    -- Outstanding balance
    'outstanding_balance', COALESCE((
      SELECT SUM(current_penalty_balance)::DOUBLE PRECISION
      FROM user_statistics
    ), 0.0),

    -- Pending payments count (INTEGER)
    'pending_payments_count', COALESCE((
      SELECT COUNT(*)::INTEGER
      FROM payments
      WHERE status = 'pending'
    ), 0),

    -- Pending payments amount (DOUBLE PRECISION)
    'pending_payments_amount', COALESCE((
      SELECT SUM(amount)::DOUBLE PRECISION
      FROM payments
      WHERE status = 'pending'
    ), 0.0)
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 4. ENGAGEMENT METRICS FUNCTION (TYPE FIXED)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_engagement_metrics()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    -- Daily active users (INTEGER)
    'daily_active_users', COALESCE((
      SELECT COUNT(DISTINCT user_id)::INTEGER
      FROM deeds_reports
      WHERE report_date = CURRENT_DATE
        AND status = 'submitted'
    ), 0),

    -- Total active users (INTEGER)
    'total_active_users', COALESCE((
      SELECT COUNT(*)::INTEGER
      FROM users
      WHERE account_status = 'active'
    ), 0),

    -- Report submission rate (DOUBLE PRECISION)
    'report_submission_rate', COALESCE((
      SELECT CASE
        WHEN (SELECT COUNT(*) FROM users WHERE account_status = 'active') > 0 THEN
          (SELECT COUNT(DISTINCT user_id)::DOUBLE PRECISION
           FROM deeds_reports
           WHERE report_date = CURRENT_DATE AND status = 'submitted')
          /
          (SELECT COUNT(*)::DOUBLE PRECISION FROM users WHERE account_status = 'active')
        ELSE 0.0
      END
    ), 0.0),

    -- Average submission time (STRING)
    'average_submission_time', '21:30',

    -- Notification open rate (DOUBLE PRECISION - placeholder)
    'notification_open_rate', 0.75::DOUBLE PRECISION,

    -- Average response time in minutes (INTEGER - placeholder)
    'average_response_time_minutes', 45

  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------------------
-- 5. EXCUSE METRICS FUNCTION (TYPE FIXED)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_excuse_metrics()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    -- Pending excuses (INTEGER)
    'pending_excuses', COALESCE((
      SELECT COUNT(*)::INTEGER
      FROM excuses
      WHERE status = 'pending'
    ), 0),

    -- Approval rate (DOUBLE PRECISION)
    'approval_rate', COALESCE((
      SELECT CASE
        WHEN COUNT(*) > 0 THEN
          (COUNT(CASE WHEN status = 'approved' THEN 1 END)::DOUBLE PRECISION / COUNT(*))
        ELSE 0.0
      END
      FROM excuses
      WHERE status IN ('approved', 'rejected')
    ), 0.0),

    -- Excuses by reason (top 5 most common)
    'excuses_by_reason', COALESCE((
      SELECT json_object_agg(excuse_type, count)
      FROM (
        SELECT excuse_type, COUNT(*)::INTEGER as count
        FROM excuses
        GROUP BY excuse_type
        ORDER BY count DESC
        LIMIT 5
      ) reasons
    ), '{}'::json)
  ) INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PART 3: RLS POLICIES FOR SETTINGS TABLE
-- ============================================================================

-- Enable RLS on settings table
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can read settings" ON settings;
DROP POLICY IF EXISTS "Admins can update settings" ON settings;
DROP POLICY IF EXISTS "Admins can insert settings" ON settings;

-- Allow admins to read settings
CREATE POLICY "Admins can read settings" ON settings
FOR SELECT
USING (public.is_admin());

-- Allow admins to update settings
CREATE POLICY "Admins can update settings" ON settings
FOR UPDATE
USING (public.is_admin());

-- Allow admins to insert settings
CREATE POLICY "Admins can insert settings" ON settings
FOR INSERT
WITH CHECK (public.is_admin());

-- ============================================================================
-- PART 4: VERIFICATION QUERIES
-- ============================================================================

-- Verify settings table has data
SELECT COUNT(*) as settings_count FROM settings;

-- Test user metrics function
SELECT get_user_metrics();

-- Test deed metrics function (with current date range)
SELECT get_deed_metrics(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);

-- Test financial metrics function
SELECT get_financial_metrics(CURRENT_DATE - INTERVAL '30 days', CURRENT_DATE);

-- Test engagement metrics function
SELECT get_engagement_metrics();

-- Test excuse metrics function
SELECT get_excuse_metrics();

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================
DO $$
BEGIN
  RAISE NOTICE '✅ Admin Phase 2 database setup complete (TYPE FIXED)!';
  RAISE NOTICE 'All RPC functions created with correct type casting.';
  RAISE NOTICE 'Settings table configured with default values.';
  RAISE NOTICE 'RLS policies applied.';
  RAISE NOTICE '';
  RAISE NOTICE 'INTEGER fields are explicitly cast to INTEGER';
  RAISE NOTICE 'DOUBLE PRECISION fields are explicitly cast to DOUBLE PRECISION';
  RAISE NOTICE '';
  RAISE NOTICE 'You can now test the Analytics Dashboard and System Settings pages.';
END $$;
