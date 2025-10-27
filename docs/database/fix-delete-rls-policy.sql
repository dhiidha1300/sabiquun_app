-- Add DELETE RLS policy for deeds_reports table
-- This allows users to delete their own draft reports only

-- Policy: Enable delete for own draft reports
CREATE POLICY "Enable delete for own draft reports"
ON deeds_reports
FOR DELETE
TO authenticated
USING (
  auth.uid() = user_id
  AND status = 'draft'
);

-- Optional: If you also need to handle deed_entries deletion
-- (Though CASCADE should handle this automatically)
CREATE POLICY "Enable delete for own report entries"
ON deed_entries
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM deeds_reports
    WHERE deeds_reports.id = deed_entries.report_id
    AND deeds_reports.user_id = auth.uid()
    AND deeds_reports.status = 'draft'
  )
);
