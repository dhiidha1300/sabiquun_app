-- ============================================================================
-- NOTIFICATION SYSTEM DATABASE FIX
-- ============================================================================
-- This migration fixes the notification system by:
-- 1. Adding missing email columns to notification_templates
-- 2. Adding RLS policies for notification_schedules table
-- ============================================================================

-- Fix 1: Add missing email columns to notification_templates
-- ----------------------------------------------------------------------------

ALTER TABLE notification_templates
ADD COLUMN IF NOT EXISTS email_subject VARCHAR(255),
ADD COLUMN IF NOT EXISTS email_body TEXT;

-- Add comments for documentation
COMMENT ON COLUMN notification_templates.email_subject IS 'Email notification subject line (optional)';
COMMENT ON COLUMN notification_templates.email_body IS 'Email notification body content (optional)';

-- Fix 2: Add RLS policies for notification_schedules table
-- ----------------------------------------------------------------------------

-- Enable RLS on notification_schedules if not already enabled
ALTER TABLE notification_schedules ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Admins can read notification schedules" ON notification_schedules;
DROP POLICY IF EXISTS "Admins can insert notification schedules" ON notification_schedules;
DROP POLICY IF EXISTS "Admins can update notification schedules" ON notification_schedules;
DROP POLICY IF EXISTS "Admins can delete notification schedules" ON notification_schedules;

-- Create RLS policies for admins to manage schedules
CREATE POLICY "Admins can read notification schedules"
ON notification_schedules
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can insert notification schedules"
ON notification_schedules
FOR INSERT
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update notification schedules"
ON notification_schedules
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete notification schedules"
ON notification_schedules
FOR DELETE
USING (public.is_admin());

-- Fix 3: Add RLS policies for notification_templates table
-- ----------------------------------------------------------------------------

-- Enable RLS on notification_templates if not already enabled
ALTER TABLE notification_templates ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can read notification templates" ON notification_templates;
DROP POLICY IF EXISTS "Admins can insert notification templates" ON notification_templates;
DROP POLICY IF EXISTS "Admins can update notification templates" ON notification_templates;
DROP POLICY IF EXISTS "Admins can delete notification templates" ON notification_templates;

-- Create RLS policies for admins to manage templates
CREATE POLICY "Admins can read notification templates"
ON notification_templates
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can insert notification templates"
ON notification_templates
FOR INSERT
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can update notification templates"
ON notification_templates
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "Admins can delete notification templates"
ON notification_templates
FOR DELETE
USING (
  public.is_admin() AND
  NOT is_system_default  -- Prevent deletion of system default templates
);

-- Fix 4: Create default notification templates (if they don't exist)
-- ----------------------------------------------------------------------------

-- Check if default templates exist, if not insert them
INSERT INTO notification_templates (template_key, title, body, notification_type, is_system_default, is_enabled)
SELECT * FROM (VALUES
  ('deadline_reminder', 'Reminder: Submit Today''s Deeds', 'You have until 12 PM tomorrow to submit today''s report. Current progress: {{progress}}%', 'daily_reminder', TRUE, TRUE),
  ('penalty_incurred', 'Penalty Applied', 'Penalty of {{amount}} shillings applied for {{missed_deeds}} missed deeds on {{date}}. Current balance: {{balance}} shillings.', 'penalty', TRUE, TRUE),
  ('payment_approved', 'Payment Approved', 'Your payment of {{amount}} shillings has been approved. New balance: {{balance}} shillings.', 'payment', TRUE, TRUE),
  ('grace_period_ending', 'Grace Period Ending Soon', 'You have 1 hour left to submit yesterday''s report. Submit now to avoid penalty.', 'grace_warning', TRUE, TRUE),
  ('account_deactivated', 'Account Deactivated', 'Your account has been deactivated due to penalty balance of {{balance}} shillings. Contact admin for reactivation.', 'account', TRUE, TRUE),
  ('weekly_leaderboard', 'Weekly Leaderboard', 'Congratulations! You ranked #{{rank}} this week with {{compliance}}% compliance. Keep up the great work!', 'weekly_leaderboard', TRUE, TRUE)
) AS v(template_key, title, body, notification_type, is_system_default, is_enabled)
WHERE NOT EXISTS (
  SELECT 1 FROM notification_templates WHERE template_key = v.template_key
);

-- Fix 5: Add RLS policies for notifications_log table
-- ----------------------------------------------------------------------------

-- Enable RLS on notifications_log if not already enabled
ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can read their own notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications_log;

-- Create RLS policies for notifications_log

-- Admins and system can insert notifications
CREATE POLICY "Admins can insert notifications"
ON notifications_log
FOR INSERT
WITH CHECK (public.is_admin());

-- Users can read their own notifications
CREATE POLICY "Users can read their own notifications"
ON notifications_log
FOR SELECT
USING (auth.uid() = user_id OR public.is_admin());

-- Users can update their own notifications (for marking as read)
CREATE POLICY "Users can update their own notifications"
ON notifications_log
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Fix 6: Verify RLS helper function exists
-- ----------------------------------------------------------------------------

-- Verify that the is_admin() function exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'is_admin'
    AND pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  ) THEN
    RAISE EXCEPTION 'Function public.is_admin() does not exist. Please create it first.';
  END IF;
END $$;

-- ============================================================================
-- VERIFICATION QUERIES (Run these to verify the fix)
-- ============================================================================

-- Verify notification_templates columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'notification_templates'
ORDER BY ordinal_position;

-- Verify RLS policies for all notification tables
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('notification_templates', 'notification_schedules', 'notifications_log')
ORDER BY tablename, policyname;

-- Count system default templates
SELECT COUNT(*) as system_templates_count
FROM notification_templates
WHERE is_system_default = TRUE;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
