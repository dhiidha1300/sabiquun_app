-- Migration: Add RLS Policies for Excuses Table
-- Description: Enables Row Level Security for excuses table and adds policies
-- Date: 2025-01-20

-- Enable RLS on excuses table
ALTER TABLE public.excuses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any (to ensure clean slate)
DROP POLICY IF EXISTS "Users can view their own excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can insert their own excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can update their pending excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can delete their pending excuses" ON public.excuses;
DROP POLICY IF EXISTS "Supervisors can view all excuses" ON public.excuses;
DROP POLICY IF EXISTS "Supervisors can update excuse status" ON public.excuses;
DROP POLICY IF EXISTS "Admins have full access to excuses" ON public.excuses;

-- ============================================================================
-- User Policies
-- ============================================================================

-- Policy: Users can view their own excuses
CREATE POLICY "Users can view their own excuses"
ON public.excuses
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Policy: Users can insert their own excuses
CREATE POLICY "Users can insert their own excuses"
ON public.excuses
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their pending excuses
CREATE POLICY "Users can update their pending excuses"
ON public.excuses
FOR UPDATE
TO authenticated
USING (
  auth.uid() = user_id
  AND status = 'pending'
)
WITH CHECK (
  auth.uid() = user_id
  AND status = 'pending'
);

-- Policy: Users can delete their pending excuses
CREATE POLICY "Users can delete their pending excuses"
ON public.excuses
FOR DELETE
TO authenticated
USING (
  auth.uid() = user_id
  AND status = 'pending'
);

-- ============================================================================
-- Supervisor Policies
-- ============================================================================

-- Policy: Supervisors can view all excuses
CREATE POLICY "Supervisors can view all excuses"
ON public.excuses
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'supervisor'
  )
);

-- Policy: Supervisors can update excuse status (approve/reject)
CREATE POLICY "Supervisors can update excuse status"
ON public.excuses
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'supervisor'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'supervisor'
  )
);

-- ============================================================================
-- Admin Policies
-- ============================================================================

-- Policy: Admins have full access to excuses (SELECT)
CREATE POLICY "Admins have full access to view excuses"
ON public.excuses
FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- Policy: Admins have full access to excuses (INSERT)
CREATE POLICY "Admins have full access to insert excuses"
ON public.excuses
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- Policy: Admins have full access to excuses (UPDATE)
CREATE POLICY "Admins have full access to update excuses"
ON public.excuses
FOR UPDATE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- Policy: Admins have full access to excuses (DELETE)
CREATE POLICY "Admins have full access to delete excuses"
ON public.excuses
FOR DELETE
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND role = 'admin'
  )
);

-- ============================================================================
-- Add helpful comments
-- ============================================================================
COMMENT ON POLICY "Users can view their own excuses" ON public.excuses IS
  'Allows users to view only their own excuse requests';

COMMENT ON POLICY "Users can insert their own excuses" ON public.excuses IS
  'Allows users to create new excuse requests';

COMMENT ON POLICY "Users can update their pending excuses" ON public.excuses IS
  'Allows users to update only their pending excuses (not approved or rejected)';

COMMENT ON POLICY "Users can delete their pending excuses" ON public.excuses IS
  'Allows users to delete only their pending excuses (not approved or rejected)';

COMMENT ON POLICY "Supervisors can view all excuses" ON public.excuses IS
  'Allows supervisors to view all user excuse requests';

COMMENT ON POLICY "Supervisors can update excuse status" ON public.excuses IS
  'Allows supervisors to approve or reject excuse requests';

COMMENT ON POLICY "Admins have full access to view excuses" ON public.excuses IS
  'Allows admins to view all excuse requests';

COMMENT ON POLICY "Admins have full access to update excuses" ON public.excuses IS
  'Allows admins to update any excuse request';

COMMENT ON POLICY "Admins have full access to delete excuses" ON public.excuses IS
  'Allows admins to delete any excuse request';
