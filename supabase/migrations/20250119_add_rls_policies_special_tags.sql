-- Migration: Add RLS Policies for Special Tags
-- Description: Adds Row Level Security policies for existing special_tags and user_tags tables
-- Date: 2025-01-19
-- Note: Uses existing special_tags and user_tags tables from the schema

-- ============================================================================
-- Add Row Level Security (RLS) for special_tags
-- ============================================================================
ALTER TABLE public.special_tags ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Everyone can view special tags" ON public.special_tags;
DROP POLICY IF EXISTS "Admins and supervisors can manage special tags" ON public.special_tags;

-- Everyone can view special tags
CREATE POLICY "Everyone can view special tags"
  ON public.special_tags FOR SELECT
  USING (true);

-- Only admins and supervisors can manage special tags
CREATE POLICY "Admins and supervisors can manage special tags"
  ON public.special_tags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('admin', 'supervisor')
    )
  );

-- ============================================================================
-- Add Row Level Security (RLS) for user_tags
-- ============================================================================
ALTER TABLE public.user_tags ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own tags" ON public.user_tags;
DROP POLICY IF EXISTS "Admins and supervisors can manage user tags" ON public.user_tags;

-- Users can view their own tags
CREATE POLICY "Users can view their own tags"
  ON public.user_tags FOR SELECT
  USING (user_id = auth.uid() OR EXISTS (
    SELECT 1 FROM users
    WHERE id = auth.uid()
    AND role IN ('admin', 'supervisor')
  ));

-- Only admins and supervisors can assign/remove tags
CREATE POLICY "Admins and supervisors can manage user tags"
  ON public.user_tags FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('admin', 'supervisor')
    )
  );

-- ============================================================================
-- Add default special tags if they don't exist
-- ============================================================================
INSERT INTO public.special_tags (tag_key, display_name, description, criteria, auto_assign) VALUES
('fajr_champion', 'Fajr Champion', 'Consistently performs Fajr prayer - 90%+ completion over 30 days', '{"deed_key": "fajr_prayer", "completion_rate": 90, "days": 30}', TRUE),
('perfect_week', 'Perfect Week', 'Completed all 10 deeds for 7 consecutive days', '{"type": "perfect_streak", "days": 7}', TRUE),
('consistent_performer', 'Consistent Performer', 'Maintained 90%+ compliance for 30 days', '{"type": "compliance_rate", "threshold": 90, "period_days": 30}', TRUE),
('top_contributor', 'Top Contributor', 'Manually awarded to exceptional performers', '{"type": "manual"}', FALSE)
ON CONFLICT (tag_key) DO NOTHING;

-- ============================================================================
-- Add comments for documentation
-- ============================================================================
COMMENT ON TABLE public.special_tags IS 'Achievement badges/tags for gamification';
COMMENT ON TABLE public.user_tags IS 'Junction table linking users to their earned tags';
