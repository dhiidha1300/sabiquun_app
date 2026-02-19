-- Migration: WhatsApp Logs Table
-- Purpose: Track all WhatsApp message delivery attempts with success/error logs
-- Date: 2025-02-03

-- ============================================
-- 1. Create whatsapp_logs Table
-- ============================================

CREATE TABLE IF NOT EXISTS whatsapp_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Recipient Information
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  phone_number VARCHAR(20) NOT NULL,
  user_name VARCHAR(255),

  -- Message Information
  template_name VARCHAR(255) NOT NULL,
  template_language VARCHAR(10) DEFAULT 'en',
  template_variables JSONB DEFAULT '{}',
  message_content TEXT,

  -- Delivery Status
  status VARCHAR(50) NOT NULL CHECK (status IN ('pending', 'sent', 'delivered', 'read', 'failed')),
  whatsapp_message_id VARCHAR(255),

  -- Response from WhatsApp API
  api_response JSONB,
  error_code VARCHAR(100),
  error_message TEXT,

  -- Metadata
  notification_type VARCHAR(100),
  sent_by UUID REFERENCES users(id) ON DELETE SET NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  delivered_at TIMESTAMP WITH TIME ZONE,
  read_at TIMESTAMP WITH TIME ZONE,

  -- Tracking
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. Create Indexes for Performance
-- ============================================

-- Index for querying by user
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_user_id
ON whatsapp_logs(user_id);

-- Index for querying by phone number
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_phone
ON whatsapp_logs(phone_number);

-- Index for querying by status
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_status
ON whatsapp_logs(status);

-- Index for querying by template
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_template
ON whatsapp_logs(template_name);

-- Index for querying by date range
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_sent_at
ON whatsapp_logs(sent_at DESC);

-- Index for failed messages
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_failed
ON whatsapp_logs(status, sent_at DESC)
WHERE status = 'failed';

-- Compound index for user + date queries
CREATE INDEX IF NOT EXISTS idx_whatsapp_logs_user_date
ON whatsapp_logs(user_id, sent_at DESC);

-- ============================================
-- 3. Add Comments for Documentation
-- ============================================

COMMENT ON TABLE whatsapp_logs IS 'Logs all WhatsApp message delivery attempts with success/error information';

COMMENT ON COLUMN whatsapp_logs.user_id IS 'Reference to the user who received the message (nullable if user deleted)';
COMMENT ON COLUMN whatsapp_logs.phone_number IS 'WhatsApp phone number in international format (e.g., +254712345678)';
COMMENT ON COLUMN whatsapp_logs.template_name IS 'Name of the Meta-approved WhatsApp template used';
COMMENT ON COLUMN whatsapp_logs.template_variables IS 'JSON object containing template variable values';
COMMENT ON COLUMN whatsapp_logs.status IS 'Message delivery status: pending, sent, delivered, read, failed';
COMMENT ON COLUMN whatsapp_logs.whatsapp_message_id IS 'Unique message ID returned by WhatsApp API';
COMMENT ON COLUMN whatsapp_logs.api_response IS 'Full JSON response from WhatsApp Cloud API';
COMMENT ON COLUMN whatsapp_logs.error_code IS 'Error code if message failed';
COMMENT ON COLUMN whatsapp_logs.error_message IS 'Error message if message failed';
COMMENT ON COLUMN whatsapp_logs.notification_type IS 'Type of notification (e.g., deed_reminder, penalty_alert)';
COMMENT ON COLUMN whatsapp_logs.sent_by IS 'Admin/system user who triggered the message';

-- ============================================
-- 4. Create Updated At Trigger
-- ============================================

CREATE OR REPLACE FUNCTION update_whatsapp_logs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER whatsapp_logs_updated_at
BEFORE UPDATE ON whatsapp_logs
FOR EACH ROW
EXECUTE FUNCTION update_whatsapp_logs_updated_at();

-- ============================================
-- 5. Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE whatsapp_logs ENABLE ROW LEVEL SECURITY;

-- Allow admins to view all logs
CREATE POLICY "Admins can view all whatsapp logs"
ON whatsapp_logs
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Allow system to insert logs
CREATE POLICY "System can insert whatsapp logs"
ON whatsapp_logs
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow admins to update logs (for status updates from webhooks)
CREATE POLICY "Admins can update whatsapp logs"
ON whatsapp_logs
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- ============================================
-- 6. Create View for Summary Statistics
-- ============================================

CREATE OR REPLACE VIEW whatsapp_logs_summary AS
SELECT
  DATE(sent_at) as date,
  template_name,
  status,
  COUNT(*) as message_count,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT phone_number) as unique_numbers
FROM whatsapp_logs
GROUP BY DATE(sent_at), template_name, status
ORDER BY date DESC, template_name, status;

COMMENT ON VIEW whatsapp_logs_summary IS 'Daily summary of WhatsApp message delivery statistics';

-- Grant access to the view
GRANT SELECT ON whatsapp_logs_summary TO authenticated;

-- ============================================
-- 7. Create Function to Get Recent Logs
-- ============================================

CREATE OR REPLACE FUNCTION get_recent_whatsapp_logs(
  limit_count INTEGER DEFAULT 50,
  offset_count INTEGER DEFAULT 0,
  filter_status VARCHAR DEFAULT NULL,
  filter_template VARCHAR DEFAULT NULL,
  search_phone VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  phone_number VARCHAR,
  user_name VARCHAR,
  template_name VARCHAR,
  template_language VARCHAR,
  status VARCHAR,
  whatsapp_message_id VARCHAR,
  error_code VARCHAR,
  error_message TEXT,
  notification_type VARCHAR,
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  read_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    wl.id,
    wl.user_id,
    wl.phone_number,
    wl.user_name,
    wl.template_name,
    wl.template_language,
    wl.status,
    wl.whatsapp_message_id,
    wl.error_code,
    wl.error_message,
    wl.notification_type,
    wl.sent_at,
    wl.delivered_at,
    wl.read_at
  FROM whatsapp_logs wl
  WHERE
    (filter_status IS NULL OR wl.status = filter_status)
    AND (filter_template IS NULL OR wl.template_name = filter_template)
    AND (search_phone IS NULL OR wl.phone_number ILIKE '%' || search_phone || '%')
  ORDER BY wl.sent_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_recent_whatsapp_logs IS 'Retrieve recent WhatsApp logs with optional filters';

-- ============================================
-- 8. Create Function to Get Delivery Statistics
-- ============================================

CREATE OR REPLACE FUNCTION get_whatsapp_delivery_stats(
  days_back INTEGER DEFAULT 7
)
RETURNS TABLE (
  total_sent BIGINT,
  total_delivered BIGINT,
  total_read BIGINT,
  total_failed BIGINT,
  delivery_rate NUMERIC,
  read_rate NUMERIC,
  failure_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) FILTER (WHERE status IN ('sent', 'delivered', 'read')) as total_sent,
    COUNT(*) FILTER (WHERE status = 'delivered' OR status = 'read') as total_delivered,
    COUNT(*) FILTER (WHERE status = 'read') as total_read,
    COUNT(*) FILTER (WHERE status = 'failed') as total_failed,
    ROUND(
      (COUNT(*) FILTER (WHERE status = 'delivered' OR status = 'read')::NUMERIC /
       NULLIF(COUNT(*) FILTER (WHERE status IN ('sent', 'delivered', 'read', 'failed')), 0)) * 100,
      2
    ) as delivery_rate,
    ROUND(
      (COUNT(*) FILTER (WHERE status = 'read')::NUMERIC /
       NULLIF(COUNT(*) FILTER (WHERE status IN ('sent', 'delivered', 'read')), 0)) * 100,
      2
    ) as read_rate,
    ROUND(
      (COUNT(*) FILTER (WHERE status = 'failed')::NUMERIC /
       NULLIF(COUNT(*), 0)) * 100,
      2
    ) as failure_rate
  FROM whatsapp_logs
  WHERE sent_at >= CURRENT_TIMESTAMP - (days_back || ' days')::INTERVAL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_whatsapp_delivery_stats IS 'Get WhatsApp delivery statistics for the last N days';

-- ============================================
-- 9. Sample Data (Optional - for testing)
-- ============================================

-- Uncomment to insert sample data for testing
/*
INSERT INTO whatsapp_logs (
  phone_number,
  user_name,
  template_name,
  template_language,
  template_variables,
  status,
  whatsapp_message_id,
  notification_type
) VALUES
  ('+254712345678', 'John Doe', 'deed_reminder', 'en', '{"user_name": "John", "progress": "5/10"}', 'delivered', 'wamid.123456', 'deadline_reminder'),
  ('+254787654321', 'Jane Smith', 'penalty_alert', 'en', '{"user_name": "Jane", "amount": "5000", "balance": "15000"}', 'read', 'wamid.789012', 'penalty_incurred'),
  ('+254700000000', 'Test User', 'payment_confirmed', 'en', '{"user_name": "Test", "amount": "10000"}', 'failed', NULL, 'payment_approved');

UPDATE whatsapp_logs
SET
  error_code = '131047',
  error_message = 'Phone number not registered on WhatsApp'
WHERE status = 'failed';
*/

-- ============================================
-- End of Migration
-- ============================================
