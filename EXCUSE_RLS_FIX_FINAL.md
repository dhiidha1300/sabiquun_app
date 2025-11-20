# Excuse Deletion Fix - RLS Policies (FINAL VERSION)

## Issue
Users cannot delete their pending excuses. The delete operation shows a success message but doesn't actually delete the record from the database.

## Root Cause
The `excuses` table is missing Row Level Security (RLS) policies, specifically the DELETE policy that allows users to delete their own pending excuses.

## Solution

### Migration File
**File:** `supabase/migrations/20250120_excuses_rls_policies.sql`

This migration has been **corrected** to use the proper `role` column instead of non-existent `is_supervisor`/`is_admin` columns.

### How to Apply

#### Option 1: Supabase Dashboard (Recommended)

1. Open your Supabase project dashboard
2. Navigate to **SQL Editor** in the left sidebar
3. Click **New Query**
4. Open the file: `supabase/migrations/20250120_excuses_rls_policies.sql`
5. Copy the entire contents
6. Paste into the SQL editor
7. Click **Run** (or press Ctrl+Enter)
8. You should see success messages

#### Option 2: Supabase CLI

```bash
cd d:\sabiquun_app
supabase db push
```

## What the Migration Does

Creates 10 RLS policies for the `excuses` table:

### User Policies (Regular Users)
1. **SELECT** - View their own excuses only
2. **INSERT** - Create new excuse requests
3. **UPDATE** - Update only their pending excuses
4. **DELETE** - **Delete only their pending excuses** ✅ (This fixes the issue!)

### Supervisor Policies
5. **SELECT** - View all excuses from all users
6. **UPDATE** - Approve/reject any excuse

### Admin Policies
7. **SELECT** - View all excuses
8. **INSERT** - Create excuses for any user
9. **UPDATE** - Update any excuse
10. **DELETE** - Delete any excuse

## Key Policy (The Fix)

```sql
CREATE POLICY "Users can delete their pending excuses"
ON public.excuses
FOR DELETE
TO authenticated
USING (
  auth.uid() = user_id      -- User owns the excuse
  AND status = 'pending'     -- Only pending status
);
```

## Role Detection

The policies correctly check user roles using:

```sql
-- For supervisors:
WHERE role = 'supervisor'

-- For admins:
WHERE role = 'admin'
```

**Not using** `is_supervisor` or `is_admin` columns (which don't exist).

## Testing After Migration

1. **Login as a regular user**
2. **Navigate to:** Excuses → My Excuses
3. **Create a new excuse** (any type)
4. **Verify it appears** in the list with "Pending" status
5. **Click the delete button** on the pending excuse
6. **Verify:**
   - Success message appears
   - Excuse is removed from the list ✅
   - Database record is actually deleted ✅
7. **Try deleting an approved excuse:** Should fail with "Only pending excuses can be deleted"

## Verification Query

After running the migration, verify policies are in place:

```sql
SELECT
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE tablename = 'excuses'
ORDER BY policyname;
```

You should see 10 policies listed.

## Rollback (If Needed)

```sql
-- Disable RLS
ALTER TABLE public.excuses DISABLE ROW LEVEL SECURITY;

-- Drop all policies
DROP POLICY IF EXISTS "Users can view their own excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can insert their own excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can update their pending excuses" ON public.excuses;
DROP POLICY IF EXISTS "Users can delete their pending excuses" ON public.excuses;
DROP POLICY IF EXISTS "Supervisors can view all excuses" ON public.excuses;
DROP POLICY IF EXISTS "Supervisors can update excuse status" ON public.excuses;
DROP POLICY IF EXISTS "Admins have full access to view excuses" ON public.excuses;
DROP POLICY IF EXISTS "Admins have full access to insert excuses" ON public.excuses;
DROP POLICY IF EXISTS "Admins have full access to update excuses" ON public.excuses;
DROP POLICY IF EXISTS "Admins have full access to delete excuses" ON public.excuses;
```

## Related Files

- **Migration:** `supabase/migrations/20250120_excuses_rls_policies.sql`
- **App Logic:** `lib/features/excuses/data/datasources/excuse_remote_datasource.dart` (lines 80-103)
- **Schema Reference:** `docs/database/01-schema.md`

## Important Notes

✅ **Migration is idempotent** - Safe to run multiple times
✅ **Uses correct `role` column** - Matches actual database schema
✅ **Follows principle of least privilege** - Users can only delete their own pending excuses
✅ **Well documented** - All policies have descriptive comments

---

## Complete Fix Summary

All **8 user issues** have now been addressed:

1. ✅ Today's Deeds Page Styling - Enhanced
2. ✅ Duplicate Submission Error - Fixed
3. ✅ Penalty History Display - Fixed with caching
4. ✅ Excuse Submission Redirect - Fixed
5. ✅ **Delete Excuse Functionality - Fixed with RLS** ⭐
6. ✅ Profile Quick Stats - Integrated with Analytics
7. ✅ Enhanced Analytics Page - New page with charts
8. ✅ Penalty History Loading - Fixed with state management

**Ready for production testing!** 🎉
