-- Achievement Tags System Migration
-- This migration creates tables for the achievement tags feature

-- Create achievement_tags table
CREATE TABLE IF NOT EXISTS achievement_tags (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50) NOT NULL DEFAULT '⭐',
  criteria JSONB,
  auto_assign BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create user_achievement_tags table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS user_achievement_tags (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  tag_id UUID REFERENCES achievement_tags(id) ON DELETE CASCADE,
  awarded_at TIMESTAMPTZ DEFAULT NOW(),
  awarded_by UUID REFERENCES auth.users(id),
  PRIMARY KEY (user_id, tag_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_achievement_tags_auto_assign ON achievement_tags(auto_assign);
CREATE INDEX IF NOT EXISTS idx_user_achievement_tags_user_id ON user_achievement_tags(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievement_tags_tag_id ON user_achievement_tags(tag_id);

-- Create updated_at trigger for achievement_tags
CREATE OR REPLACE FUNCTION update_achievement_tags_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER achievement_tags_updated_at
BEFORE UPDATE ON achievement_tags
FOR EACH ROW
EXECUTE FUNCTION update_achievement_tags_updated_at();

-- Enable RLS for achievement_tags
ALTER TABLE achievement_tags ENABLE ROW LEVEL SECURITY;

-- Policies for achievement_tags
-- All authenticated users can view achievement tags
CREATE POLICY achievement_tags_select_policy ON achievement_tags
  FOR SELECT
  TO authenticated
  USING (true);

-- Only admins and supervisors can insert achievement tags
CREATE POLICY achievement_tags_insert_policy ON achievement_tags
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Only admins and supervisors can update achievement tags
CREATE POLICY achievement_tags_update_policy ON achievement_tags
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Only admins and supervisors can delete achievement tags
CREATE POLICY achievement_tags_delete_policy ON achievement_tags
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Enable RLS for user_achievement_tags
ALTER TABLE user_achievement_tags ENABLE ROW LEVEL SECURITY;

-- Policies for user_achievement_tags
-- Users can view their own achievement tags
CREATE POLICY user_achievement_tags_select_own_policy ON user_achievement_tags
  FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Supervisors and admins can view all achievement tags
CREATE POLICY user_achievement_tags_select_all_policy ON user_achievement_tags
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Only admins and supervisors can assign achievement tags
CREATE POLICY user_achievement_tags_insert_policy ON user_achievement_tags
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Only admins and supervisors can remove achievement tags
CREATE POLICY user_achievement_tags_delete_policy ON user_achievement_tags
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'supervisor')
    )
  );

-- Insert default achievement tags
INSERT INTO achievement_tags (name, description, icon, criteria, auto_assign) VALUES
  ('Fajr Champion', '90%+ Fajr completion for 30 consecutive days', '🌅',
   '{"deed": "fajr", "rate": 0.9, "days": 30}'::jsonb, true),
  ('Perfect Week', '10/10 deeds all 7 days of the week', '💯',
   '{"target": 10, "days": 7, "consecutive": true}'::jsonb, true),
  ('Consistency King', '30-day streak of submitting reports', '🔥',
   '{"streak": 30}'::jsonb, true),
  ('Early Bird', 'Submit report before 6 PM for 7 consecutive days', '🐦',
   '{"time": "18:00", "days": 7}'::jsonb, true);

COMMENT ON TABLE achievement_tags IS 'Achievement tags that can be awarded to users';
COMMENT ON TABLE user_achievement_tags IS 'User achievement tag assignments';
