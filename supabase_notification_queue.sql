-- =====================================================
-- NOTIFICATION QUEUE TABLE
-- =====================================================
-- This table stores pending notifications to be sent to users
-- Used by the automated penalty calculation system and other features
-- =====================================================

-- Create notification queue table
CREATE TABLE IF NOT EXISTS notification_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}'::jsonb,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
  fcm_message_id TEXT,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sent_at TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_notification_queue_user_id ON notification_queue(user_id);
CREATE INDEX IF NOT EXISTS idx_notification_queue_status ON notification_queue(status);
CREATE INDEX IF NOT EXISTS idx_notification_queue_created_at ON notification_queue(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_queue_type ON notification_queue(type);

-- Add composite index for common queries
CREATE INDEX IF NOT EXISTS idx_notification_queue_user_status
  ON notification_queue(user_id, status);

-- Add comment for documentation
COMMENT ON TABLE notification_queue IS 'Queue for pending notifications to be processed and sent to users';
COMMENT ON COLUMN notification_queue.type IS 'Notification type: penalty_incurred, payment_approved, deactivation_warning, etc.';
COMMENT ON COLUMN notification_queue.status IS 'Processing status: pending, sent, or failed';
COMMENT ON COLUMN notification_queue.data IS 'Additional JSON data for the notification (action, parameters, etc.)';
COMMENT ON COLUMN notification_queue.fcm_message_id IS 'Firebase Cloud Messaging message ID if sent successfully';

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS
ALTER TABLE notification_queue ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
  ON notification_queue
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Only service role can insert (from Edge Functions)
CREATE POLICY "Service role can insert notifications"
  ON notification_queue
  FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Only service role can update (mark as sent/failed)
CREATE POLICY "Service role can update notifications"
  ON notification_queue
  FOR UPDATE
  TO service_role
  USING (true);

-- Admins can view all notifications
CREATE POLICY "Admins can view all notifications"
  ON notification_queue
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
        AND role = 'admin'
    )
  );

-- =====================================================
-- HELPER FUNCTION: Get User's Penalty Balance
-- =====================================================
-- Used by notification system to include current balance in messages

CREATE OR REPLACE FUNCTION get_user_penalty_balance(p_user_id UUID)
RETURNS TABLE (
  total_balance DECIMAL(10,2),
  unpaid_count INTEGER,
  oldest_penalty_date DATE
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(p.amount - p.paid_amount), 0)::DECIMAL(10,2) as total_balance,
    COUNT(*)::INTEGER as unpaid_count,
    MIN(p.date_incurred)::DATE as oldest_penalty_date
  FROM penalties p
  WHERE p.user_id = p_user_id
    AND p.status IN ('unpaid', 'partially_paid');
END;
$$;

GRANT EXECUTE ON FUNCTION get_user_penalty_balance(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_penalty_balance(UUID) TO service_role;

-- =====================================================
-- TRIGGER: Queue Notification on Penalty Insert
-- =====================================================
-- Automatically queue a notification when a penalty is created

CREATE OR REPLACE FUNCTION queue_penalty_notification()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_user_name TEXT;
  v_user_email TEXT;
  v_balance DECIMAL(10,2);
  v_unpaid_count INTEGER;
BEGIN
  -- Get user info
  SELECT name, email INTO v_user_name, v_user_email
  FROM users WHERE id = NEW.user_id;

  -- Calculate new balance
  SELECT total_balance, unpaid_count INTO v_balance, v_unpaid_count
  FROM get_user_penalty_balance(NEW.user_id);

  -- Queue notification for penalty incurred
  INSERT INTO notification_queue (
    user_id,
    type,
    title,
    body,
    data,
    status,
    created_at
  ) VALUES (
    NEW.user_id,
    'penalty_incurred',
    'Penalty Applied',
    format('Penalty of %s shillings applied for missed deeds. Current balance: %s shillings.',
      NEW.amount::TEXT, v_balance::TEXT),
    jsonb_build_object(
      'penalty_id', NEW.id,
      'amount', NEW.amount,
      'balance', v_balance,
      'unpaid_count', v_unpaid_count,
      'date_incurred', NEW.date_incurred,
      'action', 'open_payment_screen'
    ),
    'pending',
    CURRENT_TIMESTAMP
  );

  RAISE NOTICE 'Notification queued for user % (penalty: % shillings, balance: % shillings)',
    v_user_name, NEW.amount, v_balance;

  RETURN NEW;
END;
$$;

-- Attach trigger to penalties table
DROP TRIGGER IF EXISTS after_penalty_insert ON penalties;
CREATE TRIGGER after_penalty_insert
  AFTER INSERT ON penalties
  FOR EACH ROW
  EXECUTE FUNCTION queue_penalty_notification();

-- =====================================================
-- FUNCTION: Queue Deactivation Warning
-- =====================================================
-- Used to queue warnings for users approaching deactivation threshold

CREATE OR REPLACE FUNCTION queue_deactivation_warning(
  p_user_id UUID,
  p_balance DECIMAL(10,2),
  p_warning_level TEXT  -- 'first', 'final', or 'deactivated'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_title TEXT;
  v_body TEXT;
  v_type TEXT;
BEGIN
  -- Determine notification content based on warning level
  CASE p_warning_level
    WHEN 'first' THEN
      v_type := 'deactivation_warning';
      v_title := 'Payment Warning';
      v_body := format('⚠️ Warning: Your penalty balance is %s shillings. Account will be deactivated at 500,000. Please clear your dues.',
        p_balance::TEXT);

    WHEN 'final' THEN
      v_type := 'deactivation_warning_final';
      v_title := 'Final Payment Warning';
      v_body := format('⚠️ FINAL WARNING: Your penalty balance is %s shillings. Account will be deactivated at 500,000. Please pay immediately!',
        p_balance::TEXT);

    WHEN 'deactivated' THEN
      v_type := 'account_deactivated';
      v_title := 'Account Deactivated';
      v_body := format('Your account has been deactivated due to penalty balance of %s shillings. Please contact admin for reactivation.',
        p_balance::TEXT);

    ELSE
      RAISE EXCEPTION 'Invalid warning level: %', p_warning_level;
  END CASE;

  -- Queue the notification
  INSERT INTO notification_queue (
    user_id,
    type,
    title,
    body,
    data,
    status,
    created_at
  ) VALUES (
    p_user_id,
    v_type,
    v_title,
    v_body,
    jsonb_build_object(
      'balance', p_balance,
      'warning_level', p_warning_level,
      'threshold', 500000,
      'action', 'open_payment_screen'
    ),
    'pending',
    CURRENT_TIMESTAMP
  );

  RAISE NOTICE 'Deactivation warning queued for user % (level: %, balance: %)',
    p_user_id, p_warning_level, p_balance;
END;
$$;

GRANT EXECUTE ON FUNCTION queue_deactivation_warning(UUID, DECIMAL, TEXT) TO service_role;

-- =====================================================
-- FUNCTION: Get Pending Notifications
-- =====================================================
-- Retrieve all pending notifications for processing

CREATE OR REPLACE FUNCTION get_pending_notifications(p_limit INTEGER DEFAULT 100)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  user_name TEXT,
  user_email TEXT,
  fcm_token TEXT,
  type TEXT,
  title TEXT,
  body TEXT,
  data JSONB,
  created_at TIMESTAMP
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    nq.id,
    nq.user_id,
    u.name as user_name,
    u.email as user_email,
    u.fcm_token,
    nq.type,
    nq.title,
    nq.body,
    nq.data,
    nq.created_at
  FROM notification_queue nq
  JOIN users u ON nq.user_id = u.id
  WHERE nq.status = 'pending'
  ORDER BY nq.created_at ASC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION get_pending_notifications(INTEGER) TO service_role;

-- =====================================================
-- FUNCTION: Mark Notification as Sent
-- =====================================================

CREATE OR REPLACE FUNCTION mark_notification_sent(
  p_notification_id UUID,
  p_fcm_message_id TEXT DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notification_queue
  SET
    status = 'sent',
    fcm_message_id = p_fcm_message_id,
    sent_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_notification_id;
END;
$$;

GRANT EXECUTE ON FUNCTION mark_notification_sent(UUID, TEXT) TO service_role;

-- =====================================================
-- FUNCTION: Mark Notification as Failed
-- =====================================================

CREATE OR REPLACE FUNCTION mark_notification_failed(
  p_notification_id UUID,
  p_error_message TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE notification_queue
  SET
    status = 'failed',
    error_message = p_error_message,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_notification_id;
END;
$$;

GRANT EXECUTE ON FUNCTION mark_notification_failed(UUID, TEXT) TO service_role;

-- =====================================================
-- CLEANUP: Delete Old Sent Notifications
-- =====================================================
-- Optional: Clean up sent notifications older than 30 days

CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_deleted_count INTEGER;
BEGIN
  DELETE FROM notification_queue
  WHERE status = 'sent'
    AND sent_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

  RAISE NOTICE 'Deleted % old sent notifications', v_deleted_count;

  RETURN v_deleted_count;
END;
$$;

GRANT EXECUTE ON FUNCTION cleanup_old_notifications() TO service_role;

-- =====================================================
-- TESTING
-- =====================================================
-- Test queries to verify the notification queue

-- View all notifications
-- SELECT * FROM notification_queue ORDER BY created_at DESC LIMIT 10;

-- View pending notifications with user info
-- SELECT * FROM get_pending_notifications(10);

-- Test getting user balance
-- SELECT * FROM get_user_penalty_balance('user-uuid-here');

-- =====================================================
-- NOTES
-- =====================================================
-- 1. The notification_queue table stores all pending notifications
-- 2. Triggers automatically queue notifications when penalties are created
-- 3. Edge Functions or background workers process the queue and send FCM/email
-- 4. Sent notifications are marked with 'sent' status and FCM message ID
-- 5. Failed notifications are marked with 'failed' status and error message
-- 6. Old sent notifications can be cleaned up periodically
