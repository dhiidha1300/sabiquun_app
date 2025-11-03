-- Fix RLS policies for deed_entries table
-- This allows admins to read deed entries when editing reports

-- Enable RLS on deed_entries if not already enabled
ALTER TABLE deed_entries ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Admins can read all deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can read their own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can insert their own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can update their own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can delete their own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Admins can manage all deed entries" ON deed_entries;

-- Policy 1: Admins can do everything with deed entries
CREATE POLICY "Admins can manage all deed entries"
ON deed_entries FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Policy 2: Users can read their own deed entries (via report ownership)
CREATE POLICY "Users can read their own deed entries"
ON deed_entries FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
  )
);

-- Policy 3: Users can insert their own deed entries
CREATE POLICY "Users can insert their own deed entries"
ON deed_entries FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
  )
);

-- Policy 4: Users can update their own deed entries
CREATE POLICY "Users can update their own deed entries"
ON deed_entries FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
  )
);

-- Policy 5: Users can delete their own deed entries
CREATE POLICY "Users can delete their own deed entries"
ON deed_entries FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
  )
);

-- Verification queries
SELECT 'RLS policies created successfully for deed_entries' AS status;

-- Show all policies on deed_entries
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'deed_entries';
