# Fix: Excuse Deletion Not Working - RLS Policy Issue

## Problem
Users cannot delete their pending excuses because the RLS (Row Level Security) policies are missing for the `excuses` table.

## Solution
A new migration file has been created with comprehensive RLS policies for the excuses table.

## How to Apply the Fix

### Option 1: Using Supabase Dashboard (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the entire contents of: `supabase/migrations/20250120_excuses_rls_policies.sql`
5. Click **Run** to execute the migration
6. You should see a success message

### Option 2: Using Supabase CLI

If you have Supabase CLI installed:

```bash
# Navigate to project root
cd d:\sabiquun_app

# Apply the migration
supabase db push
```

## What This Migration Does

The migration creates RLS policies for the `excuses` table with the following permissions:

### User Permissions
- **View**: Users can view only their own excuses
- **Insert**: Users can create new excuses
- **Update**: Users can update only their **pending** excuses
- **Delete**: Users can delete only their **pending** excuses ✅ (This fixes the issue!)

### Supervisor Permissions
- **View**: Supervisors can view all excuses
- **Update**: Supervisors can approve/reject excuses

### Admin Permissions
- **Full Access**: Admins have complete CRUD access to all excuses

## Testing After Migration

1. **Login as a regular user**
2. **Go to Excuses History page**
3. **Submit a new excuse** (it should appear immediately)
4. **Try to delete the pending excuse** - It should now work! ✅
5. **Try to delete an approved/rejected excuse** - This should fail with "Only pending excuses can be deleted" message

## Key Policy Details

The delete policy ensures:
```sql
USING (
  auth.uid() = user_id      -- User owns the excuse
  AND status = 'pending'     -- Only pending excuses
);
```

This means:
- Users can only delete **their own** excuses
- Users can only delete excuses with **pending** status
- Approved or rejected excuses cannot be deleted by users
- The app-level validation in `excuse_remote_datasource.dart` provides additional safety

## Rollback (If Needed)

If you need to rollback this migration:

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

## Additional Notes

- The migration is idempotent (can be run multiple times safely)
- It drops existing policies before creating new ones
- All policies are well-documented with comments
- The policies follow the principle of least privilege
