# Supabase Database Migrations

This directory contains SQL migration files for the Sabiquun app database.

## Migration Files

### 20250119_add_rls_policies_special_tags.sql
**Note:** This migration uses your **existing** `special_tags` and `user_tags` tables.

Adds/updates:
- Row Level Security (RLS) policies for `special_tags` table
- Row Level Security (RLS) policies for `user_tags` table
- Default special tags (Fajr Champion, Perfect Week, Consistent Performer, Top Contributor)
- Policies for supervisors and admins to manage tags

### 20250119_create_supervisor_functions.sql
Creates RPC functions for supervisor features (uses existing `special_tags` and `user_tags`):
- **get_leaderboard_rankings()**: Returns leaderboard rankings for a given period
- **get_users_at_risk()**: Returns users with high penalty balances

## How to Apply Migrations

### Option 1: Using Supabase CLI (Recommended)
```bash
# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Apply migrations
supabase db push
```

### Option 2: Using Supabase Dashboard (Recommended for this project)
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and paste the contents of each migration file
4. Execute the SQL in order:
   - First: `20250119_add_rls_policies_special_tags.sql`
   - Second: `20250119_create_supervisor_functions.sql`

### Option 3: Using SQL directly in PostgreSQL
If you have direct database access:
```bash
psql -h your-db-host -U postgres -d postgres -f supabase/migrations/20250119_add_rls_policies_special_tags.sql
psql -h your-db-host -U postgres -d postgres -f supabase/migrations/20250119_create_supervisor_functions.sql
```

## Verification

After applying migrations, verify they were successful:

```sql
-- Check if existing tables have RLS enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('special_tags', 'user_tags');

-- Check if functions exist
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('get_leaderboard_rankings', 'get_users_at_risk');

-- Check if default special tags were inserted
SELECT tag_key, display_name FROM special_tags
WHERE tag_key IN ('fajr_champion', 'perfect_week', 'consistent_performer', 'top_contributor');

-- Test the leaderboard function
SELECT * FROM get_leaderboard_rankings('weekly', 10);

-- Test the users at risk function
SELECT * FROM get_users_at_risk(100000);
```

## Dependencies

These migrations require the following tables to already exist (as per your schema):
- users
- deeds_reports
- penalties
- payments
- special_tags (existing)
- user_tags (existing)

## Rollback

If you need to rollback these migrations:

```sql
-- Drop functions
DROP FUNCTION IF EXISTS public.get_leaderboard_rankings(TEXT, INTEGER);
DROP FUNCTION IF EXISTS public.get_users_at_risk(DECIMAL);

-- Drop RLS policies (keeps tables intact)
DROP POLICY IF EXISTS "Everyone can view special tags" ON public.special_tags;
DROP POLICY IF EXISTS "Admins and supervisors can manage special tags" ON public.special_tags;
DROP POLICY IF EXISTS "Users can view their own tags" ON public.user_tags;
DROP POLICY IF EXISTS "Admins and supervisors can manage user tags" ON public.user_tags;

-- Optionally disable RLS
ALTER TABLE public.special_tags DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_tags DISABLE ROW LEVEL SECURITY;

-- Remove default tags (optional)
DELETE FROM public.special_tags
WHERE tag_key IN ('fajr_champion', 'perfect_week', 'consistent_performer', 'top_contributor');
```

## Notes

- All functions use `SECURITY DEFINER` to run with elevated privileges
- RLS policies are enabled on achievement tags tables
- Functions are granted to `authenticated` users only
- Default achievement tags are inserted automatically
