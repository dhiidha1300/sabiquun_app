-- ============================================================================
-- QUICK FIX: notifications_log RLS Policy
-- ============================================================================
-- Run this immediately to fix the "Send Manual Notification" error
-- ============================================================================

-- Enable RLS on notifications_log
ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Admins can insert notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can read their own notifications" ON notifications_log;
DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications_log;

-- Create RLS policies for notifications_log

-- Admins can insert notifications (required for manual notifications)
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

-- Verify the policies were created
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'notifications_log'
ORDER BY policyname;

-- Test: Check if you can now insert (should return success)
-- This is just a test - the actual insert will be done by the app
SELECT 'RLS policies successfully created for notifications_log!' as status;
