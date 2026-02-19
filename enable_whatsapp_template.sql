-- Enable WhatsApp for an existing notification template
-- Replace 'your_template_key' with your actual template key

UPDATE notification_templates
SET
    whatsapp_enabled = true,
    whatsapp_template_name = 'deed_reminder',  -- Change this to your Meta-approved template name
    whatsapp_template_language = 'en'          -- Change to: en, sw, ar, or so
WHERE template_key = 'deed_reminder';          -- Change this to match your template

-- Verify the update
SELECT
    template_key,
    title,
    whatsapp_enabled,
    whatsapp_template_name,
    whatsapp_template_language
FROM notification_templates
WHERE whatsapp_enabled = true;
