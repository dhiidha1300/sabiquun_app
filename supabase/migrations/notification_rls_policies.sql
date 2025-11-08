-- RLS Policies for notifications_log table
-- This ensures users can only see their own notifications

-- Enable RLS on notifications_log table
ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own notifications
CREATE POLICY "Users can view own notifications"
ON notifications_log
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can update their own notifications (mark as read)
CREATE POLICY "Users can update own notifications"
ON notifications_log
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
ON notifications_log
FOR DELETE
USING (auth.uid() = user_id);

-- Policy: System (service role) can insert notifications for any user
-- This is used by backend functions to create notifications
CREATE POLICY "Service role can insert notifications"
ON notifications_log
FOR INSERT
WITH CHECK (true);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread
ON notifications_log(user_id, is_read, sent_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_type
ON notifications_log(notification_type);

-- Function to get unread notification count for a user
CREATE OR REPLACE FUNCTION get_unread_notification_count(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM notifications_log
    WHERE user_id = p_user_id
    AND is_read = FALSE
  );
END;
$$;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION get_unread_notification_count(UUID) TO authenticated;
