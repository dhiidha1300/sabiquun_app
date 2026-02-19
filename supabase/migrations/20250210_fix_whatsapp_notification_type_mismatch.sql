-- Migration: Fix Type Mismatch in get_pending_whatsapp_notifications
-- Date: 2026-02-10
-- Issue: Function returns TEXT but declares VARCHAR(100) for type column
-- Error: "Returned type text does not match expected type character varying in column 3"

-- ============================================
-- Fix get_pending_whatsapp_notifications Function
-- ============================================

-- Drop the existing function first (required when changing return type)
DROP FUNCTION IF EXISTS get_pending_whatsapp_notifications(INTEGER);

-- Recreate the function with correct type for column 3 (type)
CREATE FUNCTION get_pending_whatsapp_notifications(p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  type TEXT,  -- Changed from VARCHAR(100) to TEXT to match notification_queue.type
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
    nq.created_at::TIMESTAMP WITH TIME ZONE  -- Cast to match return type
  FROM notification_queue nq
  WHERE nq.delivery_channel = 'whatsapp'
    AND nq.status = 'pending'
  ORDER BY nq.created_at ASC
  LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION get_pending_whatsapp_notifications IS 'Get pending WhatsApp notifications from the queue (fixed type mismatch)';

-- Grant permissions (maintain existing permissions)
GRANT EXECUTE ON FUNCTION get_pending_whatsapp_notifications TO service_role;
