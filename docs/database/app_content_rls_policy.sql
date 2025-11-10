-- =====================================================
-- RLS Policies for app_content Table
-- =====================================================
-- This file contains Row Level Security policies for the app_content table
-- to allow all authenticated users to read published content

-- Enable RLS on app_content table
ALTER TABLE app_content ENABLE ROW LEVEL SECURITY;

-- Policy: Allow all authenticated users to read published content
-- This allows any logged-in user to view app content that is marked as published
CREATE POLICY "Allow authenticated users to read published content"
ON app_content
FOR SELECT
TO authenticated
USING (is_published = true);

-- Policy: Allow admins to read all content (published and unpublished)
-- This allows admins to see draft content and manage all content
CREATE POLICY "Allow admins to read all content"
ON app_content
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Policy: Allow admins to insert new content
CREATE POLICY "Allow admins to insert content"
ON app_content
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Policy: Allow admins to update content
CREATE POLICY "Allow admins to update content"
ON app_content
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- Policy: Allow admins to delete content
CREATE POLICY "Allow admins to delete content"
ON app_content
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM users
    WHERE users.id = auth.uid()
    AND users.role = 'admin'
  )
);

-- =====================================================
-- Notes:
-- =====================================================
-- 1. All authenticated users can read published content
-- 2. Only admins can create, update, or delete content
-- 3. Only admins can see unpublished content
-- 4. The is_published flag controls content visibility
-- =====================================================
