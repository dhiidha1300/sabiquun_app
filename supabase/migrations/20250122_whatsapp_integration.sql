-- Migration: WhatsApp Business Cloud API Integration
-- Phase 70: Add WhatsApp as a notification channel
-- Date: 2025-01-22

-- ============================================
-- 1. Add WhatsApp Configuration Settings
-- ============================================

-- Insert WhatsApp settings into the settings table
-- Note: settings table structure: id, setting_key, setting_value, description, data_type, updated_by, updated_at
INSERT INTO settings (setting_key, setting_value, description, data_type)
VALUES
  ('whatsapp_enabled', 'false', 'Enable/disable WhatsApp notifications globally', 'boolean'),
  ('whatsapp_phone_number_id', '', 'WhatsApp Business Phone Number ID from Meta', 'string'),
  ('whatsapp_business_account_id', '', 'WhatsApp Business Account ID from Meta', 'string'),
  ('whatsapp_access_token', '', 'WhatsApp Cloud API Access Token (permanent token)', 'string'),
  ('whatsapp_api_version', 'v18.0', 'WhatsApp Cloud API version', 'string')
ON CONFLICT (setting_key) DO NOTHING;

-- ============================================
-- 2. Update notification_templates Table
-- ============================================

-- Add WhatsApp-specific columns to notification_templates
ALTER TABLE notification_templates
ADD COLUMN IF NOT EXISTS whatsapp_template_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS whatsapp_template_language VARCHAR(10) DEFAULT 'en',
ADD COLUMN IF NOT EXISTS whatsapp_enabled BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN notification_templates.whatsapp_template_name IS 'Meta-approved WhatsApp template name (e.g., penalty_notification)';
COMMENT ON COLUMN notification_templates.whatsapp_template_language IS 'Template language code (e.g., en, sw, ar)';
COMMENT ON COLUMN notification_templates.whatsapp_enabled IS 'Whether this notification type should be sent via WhatsApp';

-- ============================================
-- 3. Create/Update user_notification_preferences Table
-- ============================================

-- Create user_notification_preferences table if not exists
CREATE TABLE IF NOT EXISTS user_notification_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN DEFAULT TRUE,
  email_enabled BOOLEAN DEFAULT TRUE,
  whatsapp_enabled BOOLEAN DEFAULT FALSE,
  whatsapp_phone VARCHAR(20),
  whatsapp_verified BOOLEAN DEFAULT FALSE,
  sound VARCHAR(50) DEFAULT 'default',
  quiet_hours_enabled BOOLEAN DEFAULT FALSE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Add columns if table already exists but missing WhatsApp columns
ALTER TABLE user_notification_preferences
ADD COLUMN IF NOT EXISTS whatsapp_enabled BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS whatsapp_phone VARCHAR(20),
ADD COLUMN IF NOT EXISTS whatsapp_verified BOOLEAN DEFAULT FALSE;

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_user_notification_preferences_user
ON user_notification_preferences(user_id);

CREATE INDEX IF NOT EXISTS idx_user_notification_preferences_whatsapp
ON user_notification_preferences(whatsapp_enabled, whatsapp_verified)
WHERE whatsapp_enabled = TRUE AND whatsapp_verified = TRUE;

COMMENT ON TABLE user_notification_preferences IS 'User-level notification preferences including WhatsApp settings';
COMMENT ON COLUMN user_notification_preferences.whatsapp_phone IS 'User WhatsApp phone number in international format (e.g., +254712345678)';
COMMENT ON COLUMN user_notification_preferences.whatsapp_verified IS 'Whether admin has verified this phone number for WhatsApp';

-- ============================================
-- 4. Create WhatsApp Template Mapping Table
-- ============================================

CREATE TABLE IF NOT EXISTS whatsapp_template_mapping (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  notification_type VARCHAR(100) NOT NULL,
  whatsapp_template_name VARCHAR(255) NOT NULL,
  whatsapp_template_language VARCHAR(10) DEFAULT 'en',
  parameter_mapping JSONB NOT NULL DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(notification_type, whatsapp_template_language)
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_template_mapping_type
ON whatsapp_template_mapping(notification_type) WHERE is_active = TRUE;

COMMENT ON TABLE whatsapp_template_mapping IS 'Maps internal notification types to WhatsApp approved templates';
COMMENT ON COLUMN whatsapp_template_mapping.parameter_mapping IS 'JSON mapping of placeholders to WhatsApp template parameters, e.g., {"user_name": "{{1}}", "amount": "{{2}}"}';

-- Insert default template mappings (these will need actual template names after Meta approval)
INSERT INTO whatsapp_template_mapping (notification_type, whatsapp_template_name, parameter_mapping) VALUES
  ('deadline_reminder', 'deed_reminder', '{"user_name": "{{1}}", "progress": "{{2}}"}'),
  ('penalty_incurred', 'penalty_alert', '{"user_name": "{{1}}", "amount": "{{2}}", "balance": "{{3}}"}'),
  ('payment_approved', 'payment_confirmed', '{"user_name": "{{1}}", "amount": "{{2}}", "balance": "{{3}}"}'),
  ('payment_rejected', 'payment_rejected', '{"user_name": "{{1}}", "amount": "{{2}}", "reason": "{{3}}"}'),
  ('payment_submitted', 'payment_pending', '{"user_name": "{{1}}", "amount": "{{2}}"}'),
  ('account_deactivated', 'account_deactivated', '{"user_name": "{{1}}", "balance": "{{2}}"}'),
  ('auto_deactivation_warning', 'account_warning', '{"user_name": "{{1}}", "balance": "{{2}}"}'),
  ('deeds_submitted', 'deeds_confirmation', '{"user_name": "{{1}}", "total_deeds": "{{2}}", "date": "{{3}}"}'),
  ('user_submitted_deeds', 'user_deeds_notification', '{"submitter_name": "{{1}}", "total_deeds": "{{2}}", "date": "{{3}}"}'),
  ('grace_period_ending', 'deadline_warning', '{"user_name": "{{1}}", "time_remaining": "{{2}}"}')
ON CONFLICT (notification_type, whatsapp_template_language) DO NOTHING;

-- ============================================
-- 5. Update notification_queue Table
-- ============================================

-- Add WhatsApp-specific columns to notification_queue if it exists
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notification_queue') THEN
    ALTER TABLE notification_queue
    ADD COLUMN IF NOT EXISTS delivery_channel VARCHAR(20) DEFAULT 'in_app',
    ADD COLUMN IF NOT EXISTS whatsapp_message_id VARCHAR(255),
    ADD COLUMN IF NOT EXISTS whatsapp_status VARCHAR(50),
    ADD COLUMN IF NOT EXISTS whatsapp_error_code VARCHAR(50);

    CREATE INDEX IF NOT EXISTS idx_notification_queue_whatsapp
    ON notification_queue(delivery_channel, status)
    WHERE delivery_channel = 'whatsapp';
  END IF;
END $$;

-- ============================================
-- 6. Database Functions for WhatsApp
-- ============================================

-- Function to queue a WhatsApp notification
CREATE OR REPLACE FUNCTION queue_whatsapp_notification(
  p_user_id UUID,
  p_notification_type VARCHAR(100),
  p_template_params JSONB
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_notification_id UUID;
  v_user_phone VARCHAR(20);
  v_whatsapp_enabled BOOLEAN;
  v_whatsapp_verified BOOLEAN;
  v_template_name VARCHAR(255);
  v_template_language VARCHAR(10);
  v_title TEXT;
  v_body TEXT;
BEGIN
  -- Check if user has WhatsApp enabled and verified
  SELECT
    whatsapp_phone,
    whatsapp_enabled,
    whatsapp_verified
  INTO v_user_phone, v_whatsapp_enabled, v_whatsapp_verified
  FROM user_notification_preferences
  WHERE user_id = p_user_id;

  -- Skip if WhatsApp not enabled or not verified for user
  IF NOT COALESCE(v_whatsapp_enabled, FALSE) OR NOT COALESCE(v_whatsapp_verified, FALSE) OR v_user_phone IS NULL THEN
    RETURN NULL;
  END IF;

  -- Check if WhatsApp is globally enabled
  IF NOT EXISTS (
    SELECT 1 FROM settings
    WHERE setting_key = 'whatsapp_enabled' AND setting_value = 'true'
  ) THEN
    RETURN NULL;
  END IF;

  -- Get WhatsApp template mapping
  SELECT
    whatsapp_template_name,
    whatsapp_template_language
  INTO v_template_name, v_template_language
  FROM whatsapp_template_mapping
  WHERE notification_type = p_notification_type
    AND is_active = TRUE
  LIMIT 1;

  -- Skip if no template mapping found
  IF v_template_name IS NULL THEN
    RETURN NULL;
  END IF;

  -- Get notification template for title/body (for logging)
  SELECT title, body
  INTO v_title, v_body
  FROM notification_templates
  WHERE template_key = p_notification_type
    AND is_enabled = TRUE
  LIMIT 1;

  -- Insert into notification queue
  INSERT INTO notification_queue (
    user_id,
    type,
    title,
    body,
    data,
    delivery_channel,
    status,
    created_at
  ) VALUES (
    p_user_id,
    p_notification_type,
    COALESCE(v_title, p_notification_type),
    COALESCE(v_body, ''),
    jsonb_build_object(
      'whatsapp_phone', v_user_phone,
      'whatsapp_template_name', v_template_name,
      'whatsapp_template_language', v_template_language,
      'template_params', p_template_params
    ),
    'whatsapp',
    'pending',
    CURRENT_TIMESTAMP
  )
  RETURNING id INTO v_notification_id;

  RETURN v_notification_id;
END;
$$;

COMMENT ON FUNCTION queue_whatsapp_notification IS 'Queue a WhatsApp notification for a user if they have WhatsApp enabled and verified';

-- Function to get pending WhatsApp notifications
CREATE OR REPLACE FUNCTION get_pending_whatsapp_notifications(p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  type VARCHAR(100),
  title TEXT,
  body TEXT,
  whatsapp_phone VARCHAR(20),
  whatsapp_template_name VARCHAR(255),
  whatsapp_template_language VARCHAR(10),
  template_params JSONB,
  created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    nq.id,
    nq.user_id,
    nq.type,
    nq.title,
    nq.body,
    (nq.data->>'whatsapp_phone')::VARCHAR(20),
    (nq.data->>'whatsapp_template_name')::VARCHAR(255),
    (nq.data->>'whatsapp_template_language')::VARCHAR(10),
    (nq.data->'template_params')::JSONB,
    nq.created_at
  FROM notification_queue nq
  WHERE nq.delivery_channel = 'whatsapp'
    AND nq.status = 'pending'
  ORDER BY nq.created_at ASC
  LIMIT p_limit;
END;
$$;

-- Function to mark WhatsApp notification as sent
CREATE OR REPLACE FUNCTION mark_whatsapp_notification_sent(
  p_notification_id UUID,
  p_whatsapp_message_id VARCHAR(255)
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notification_queue
  SET
    status = 'sent',
    whatsapp_message_id = p_whatsapp_message_id,
    whatsapp_status = 'sent',
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_notification_id;
END;
$$;

-- Function to mark WhatsApp notification as failed
CREATE OR REPLACE FUNCTION mark_whatsapp_notification_failed(
  p_notification_id UUID,
  p_error_code VARCHAR(50),
  p_error_message TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notification_queue
  SET
    status = 'failed',
    whatsapp_status = 'failed',
    whatsapp_error_code = p_error_code,
    error_message = p_error_message,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_notification_id;
END;
$$;

-- ============================================
-- 7. RLS Policies for New Tables
-- ============================================

-- Enable RLS on user_notification_preferences
ALTER TABLE user_notification_preferences ENABLE ROW LEVEL SECURITY;

-- Users can view their own preferences
CREATE POLICY "Users can view own notification preferences"
ON user_notification_preferences
FOR SELECT
USING (auth.uid() = user_id);

-- Users can update their own preferences (except whatsapp_verified which is admin-only)
CREATE POLICY "Users can update own notification preferences"
ON user_notification_preferences
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Users can insert their own preferences
CREATE POLICY "Users can insert own notification preferences"
ON user_notification_preferences
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Admins can view all preferences
CREATE POLICY "Admins can view all notification preferences"
ON user_notification_preferences
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Admins can update all preferences (for WhatsApp verification)
CREATE POLICY "Admins can update all notification preferences"
ON user_notification_preferences
FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Enable RLS on whatsapp_template_mapping
ALTER TABLE whatsapp_template_mapping ENABLE ROW LEVEL SECURITY;

-- Only admins can view template mappings
CREATE POLICY "Admins can view whatsapp template mappings"
ON whatsapp_template_mapping
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Only admins can modify template mappings
CREATE POLICY "Admins can modify whatsapp template mappings"
ON whatsapp_template_mapping
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- ============================================
-- 8. Trigger for Deeds Submission WhatsApp Notification
-- ============================================

-- Function to send WhatsApp notification when deeds are submitted
CREATE OR REPLACE FUNCTION on_deeds_submitted_whatsapp()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_name TEXT;
  v_admin_record RECORD;
BEGIN
  -- Only trigger on status change to 'submitted'
  IF NEW.status = 'submitted' AND (OLD.status IS NULL OR OLD.status != 'submitted') THEN
    -- Get user name
    SELECT full_name INTO v_user_name FROM users WHERE id = NEW.user_id;

    -- Queue WhatsApp notification for user confirmation
    PERFORM queue_whatsapp_notification(
      NEW.user_id,
      'deeds_submitted',
      jsonb_build_object(
        'user_name', COALESCE(v_user_name, 'User'),
        'total_deeds', NEW.total_deeds::TEXT,
        'date', to_char(NEW.report_date, 'Mon DD, YYYY')
      )
    );

    -- Queue WhatsApp notifications for admins and supervisors
    FOR v_admin_record IN
      SELECT u.id
      FROM users u
      WHERE u.role IN ('admin', 'supervisor')
        AND u.account_status = 'active'
    LOOP
      PERFORM queue_whatsapp_notification(
        v_admin_record.id,
        'user_submitted_deeds',
        jsonb_build_object(
          'submitter_name', COALESCE(v_user_name, 'User'),
          'total_deeds', NEW.total_deeds::TEXT,
          'date', to_char(NEW.report_date, 'Mon DD, YYYY')
        )
      );
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$;

-- Create trigger on deeds_reports table
DROP TRIGGER IF EXISTS after_deeds_report_submitted_whatsapp ON deeds_reports;
CREATE TRIGGER after_deeds_report_submitted_whatsapp
AFTER UPDATE ON deeds_reports
FOR EACH ROW
EXECUTE FUNCTION on_deeds_submitted_whatsapp();

-- Also trigger on INSERT for direct submissions
DROP TRIGGER IF EXISTS after_deeds_report_insert_whatsapp ON deeds_reports;
CREATE TRIGGER after_deeds_report_insert_whatsapp
AFTER INSERT ON deeds_reports
FOR EACH ROW
WHEN (NEW.status = 'submitted')
EXECUTE FUNCTION on_deeds_submitted_whatsapp();

COMMENT ON FUNCTION on_deeds_submitted_whatsapp IS 'Queue WhatsApp notifications when deeds are submitted';

-- ============================================
-- 9. Grant Permissions
-- ============================================

-- Grant execute permissions on functions to authenticated users
GRANT EXECUTE ON FUNCTION queue_whatsapp_notification TO authenticated;
GRANT EXECUTE ON FUNCTION get_pending_whatsapp_notifications TO service_role;
GRANT EXECUTE ON FUNCTION mark_whatsapp_notification_sent TO service_role;
GRANT EXECUTE ON FUNCTION mark_whatsapp_notification_failed TO service_role;
