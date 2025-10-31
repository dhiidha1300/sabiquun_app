-- ===================================================================
-- SEED PAYMENT METHODS
-- ===================================================================
-- This script inserts the default payment methods into the database.
-- Run this script in your Supabase SQL Editor to enable payment functionality.
-- ===================================================================

-- Insert default payment methods (ZAAD and eDahab)
INSERT INTO payment_methods (method_name, display_name, sort_order, is_active)
VALUES
  ('zaad', 'ZAAD', 1, true),
  ('edahab', 'eDahab', 2, true)
ON CONFLICT (method_name) DO NOTHING;

-- Verify the insert
SELECT * FROM payment_methods ORDER BY sort_order;
