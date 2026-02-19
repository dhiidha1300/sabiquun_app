-- Quick Fix: Insert WhatsApp settings into the settings table
-- Run this in Supabase SQL Editor if WhatsApp settings are not saving

-- Insert WhatsApp settings (will insert only if they don't exist)
INSERT INTO settings (setting_key, setting_value, description, data_type)
VALUES
  ('whatsapp_enabled', 'false', 'Enable/disable WhatsApp notifications globally', 'boolean'),
  ('whatsapp_phone_number_id', '', 'WhatsApp Business Phone Number ID from Meta', 'string'),
  ('whatsapp_business_account_id', '', 'WhatsApp Business Account ID from Meta', 'string'),
  ('whatsapp_access_token', '', 'WhatsApp Cloud API Access Token (permanent token)', 'string'),
  ('whatsapp_api_version', 'v18.0', 'WhatsApp Cloud API version', 'string')
ON CONFLICT (setting_key) DO UPDATE SET
  description = EXCLUDED.description,
  data_type = EXCLUDED.data_type;

-- Verify the settings were created
SELECT setting_key, setting_value, data_type, description
FROM settings
WHERE setting_key LIKE 'whatsapp%'
ORDER BY setting_key;
