-- Migration: WhatsApp Templates Cache
-- Purpose: Cache WhatsApp templates from Meta API with health and preview data
-- Date: 2025-02-04

-- ============================================
-- 1. Create whatsapp_templates_cache Table
-- ============================================

CREATE TABLE IF NOT EXISTS whatsapp_templates_cache (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Template Identity (from Meta API)
  template_id VARCHAR(255) UNIQUE NOT NULL,
  template_name VARCHAR(255) NOT NULL,
  language VARCHAR(10) NOT NULL,

  -- Template Status (from Meta API)
  status VARCHAR(50) NOT NULL CHECK (status IN ('APPROVED', 'PENDING', 'REJECTED', 'DISABLED', 'PAUSED', 'IN_APPEAL')),
  category VARCHAR(50) NOT NULL, -- UTILITY, MARKETING, AUTHENTICATION

  -- Quality/Health Information
  quality_score VARCHAR(20), -- HIGH, MEDIUM, LOW, UNKNOWN
  quality_rating VARCHAR(20), -- GREEN, YELLOW, RED
  rejection_reason TEXT,

  -- Template Components (JSONB for flexibility)
  components JSONB NOT NULL, -- Header, Body, Footer, Buttons

  -- Template Preview Data
  header_type VARCHAR(20), -- TEXT, IMAGE, VIDEO, DOCUMENT
  header_text TEXT,
  body_text TEXT NOT NULL,
  footer_text TEXT,
  buttons JSONB, -- Call-to-action or quick reply buttons

  -- Variable Information
  variable_count INTEGER DEFAULT 0,
  variables JSONB, -- Array of variable names extracted from body

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  cached_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP WITH TIME ZONE,

  -- Meta API Response
  meta_response JSONB -- Full response from Meta for debugging
);

-- ============================================
-- 2. Create Indexes
-- ============================================

-- Index for quick lookup by template name
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_cache_name
ON whatsapp_templates_cache(template_name);

-- Index for filtering by language
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_cache_language
ON whatsapp_templates_cache(language);

-- Index for filtering by status
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_cache_status
ON whatsapp_templates_cache(status);

-- Index for cache expiration queries
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_cache_expires
ON whatsapp_templates_cache(expires_at);

-- Compound index for approved templates by language
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_approved_lang
ON whatsapp_templates_cache(status, language)
WHERE status = 'APPROVED';

-- ============================================
-- 3. Add Comments
-- ============================================

COMMENT ON TABLE whatsapp_templates_cache IS 'Cache of WhatsApp message templates fetched from Meta Business API';

COMMENT ON COLUMN whatsapp_templates_cache.template_id IS 'Unique template ID from Meta API';
COMMENT ON COLUMN whatsapp_templates_cache.template_name IS 'Template name (e.g., deed_reminder)';
COMMENT ON COLUMN whatsapp_templates_cache.status IS 'Template approval status from Meta';
COMMENT ON COLUMN whatsapp_templates_cache.quality_score IS 'Template quality score (HIGH, MEDIUM, LOW)';
COMMENT ON COLUMN whatsapp_templates_cache.components IS 'Full template components from Meta API';
COMMENT ON COLUMN whatsapp_templates_cache.variables IS 'Extracted variable names from template body';
COMMENT ON COLUMN whatsapp_templates_cache.cached_at IS 'When this template was last synced from Meta API';
COMMENT ON COLUMN whatsapp_templates_cache.expires_at IS 'When this cache entry should be refreshed';

-- ============================================
-- 4. Create Updated At Trigger
-- ============================================

CREATE OR REPLACE FUNCTION update_whatsapp_templates_cache_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER whatsapp_templates_cache_updated_at
BEFORE UPDATE ON whatsapp_templates_cache
FOR EACH ROW
EXECUTE FUNCTION update_whatsapp_templates_cache_updated_at();

-- ============================================
-- 5. Create Helper Functions
-- ============================================

-- Function to get approved templates only
CREATE OR REPLACE FUNCTION get_approved_whatsapp_templates(
  filter_language VARCHAR DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  template_id VARCHAR,
  template_name VARCHAR,
  language VARCHAR,
  quality_score VARCHAR,
  body_text TEXT,
  variables JSONB,
  variable_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    wt.id,
    wt.template_id,
    wt.template_name,
    wt.language,
    wt.quality_score,
    wt.body_text,
    wt.variables,
    wt.variable_count
  FROM whatsapp_templates_cache wt
  WHERE
    wt.status = 'APPROVED'
    AND (filter_language IS NULL OR wt.language = filter_language)
    AND (wt.expires_at IS NULL OR wt.expires_at > CURRENT_TIMESTAMP)
  ORDER BY wt.template_name, wt.language;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_approved_whatsapp_templates IS 'Get all approved WhatsApp templates with optional language filter';

-- Function to check if cache needs refresh
CREATE OR REPLACE FUNCTION whatsapp_templates_cache_needs_refresh()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM whatsapp_templates_cache
    WHERE expires_at IS NULL OR expires_at <= CURRENT_TIMESTAMP
  ) OR NOT EXISTS (
    SELECT 1 FROM whatsapp_templates_cache LIMIT 1
  );
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION whatsapp_templates_cache_needs_refresh IS 'Check if template cache needs to be refreshed from Meta API';

-- Function to mark cache as expired
CREATE OR REPLACE FUNCTION expire_whatsapp_templates_cache()
RETURNS VOID AS $$
BEGIN
  UPDATE whatsapp_templates_cache
  SET expires_at = CURRENT_TIMESTAMP
  WHERE expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION expire_whatsapp_templates_cache IS 'Mark all cached templates as expired to force refresh';

-- ============================================
-- 6. Enable Row Level Security (RLS)
-- ============================================

ALTER TABLE whatsapp_templates_cache ENABLE ROW LEVEL SECURITY;

-- Allow admins to view all templates
CREATE POLICY "Admins can view whatsapp templates cache"
ON whatsapp_templates_cache
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Allow system/edge functions to insert and update
CREATE POLICY "System can manage whatsapp templates cache"
ON whatsapp_templates_cache
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- ============================================
-- 7. Create View for Template Summary
-- ============================================

CREATE OR REPLACE VIEW whatsapp_templates_summary AS
SELECT
  status,
  language,
  COUNT(*) as template_count,
  COUNT(*) FILTER (WHERE quality_score = 'HIGH') as high_quality_count,
  COUNT(*) FILTER (WHERE quality_score = 'MEDIUM') as medium_quality_count,
  COUNT(*) FILTER (WHERE quality_score = 'LOW') as low_quality_count,
  MAX(cached_at) as last_sync_time
FROM whatsapp_templates_cache
GROUP BY status, language
ORDER BY status, language;

COMMENT ON VIEW whatsapp_templates_summary IS 'Summary of WhatsApp templates by status and language';

GRANT SELECT ON whatsapp_templates_summary TO authenticated;

-- ============================================
-- End of Migration
-- ============================================
