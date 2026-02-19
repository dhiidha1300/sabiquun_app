-- Migration: Add Hijri calendar support to rest_days table
-- Phase 72: Hijri Calendar Implementation

-- Add Hijri-specific columns for Islamic holidays
ALTER TABLE rest_days ADD COLUMN IF NOT EXISTS hijri_month INTEGER;
ALTER TABLE rest_days ADD COLUMN IF NOT EXISTS hijri_day INTEGER;
ALTER TABLE rest_days ADD COLUMN IF NOT EXISTS is_hijri_based BOOLEAN DEFAULT FALSE;

-- Add constraints for valid Hijri values
ALTER TABLE rest_days ADD CONSTRAINT hijri_month_check
  CHECK (hijri_month IS NULL OR (hijri_month >= 1 AND hijri_month <= 12));
ALTER TABLE rest_days ADD CONSTRAINT hijri_day_check
  CHECK (hijri_day IS NULL OR (hijri_day >= 1 AND hijri_day <= 30));

-- Add comment for documentation
COMMENT ON COLUMN rest_days.hijri_month IS 'Hijri month (1=Muharram, 9=Ramadan, 10=Shawwal, 12=Dhul Hijjah)';
COMMENT ON COLUMN rest_days.hijri_day IS 'Hijri day of month (1-30)';
COMMENT ON COLUMN rest_days.is_hijri_based IS 'True if this rest day follows the Hijri calendar (e.g., Eid)';

-- Create index for Hijri-based queries
CREATE INDEX IF NOT EXISTS idx_rest_days_hijri ON rest_days(hijri_month, hijri_day) WHERE is_hijri_based = TRUE;
