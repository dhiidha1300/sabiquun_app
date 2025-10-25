-- ============================================
-- SOLUTION: Use Supabase Auth Trigger
-- ============================================
-- This approach uses a database trigger to automatically create
-- the user profile when Supabase Auth creates a user.
-- This is the RECOMMENDED Supabase pattern for handling user profiles.

-- ============================================
-- STEP 1: Clean up existing policies and disable RLS temporarily
-- ============================================
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON users;
DROP POLICY IF EXISTS "Enable insert for signup" ON users;
DROP POLICY IF EXISTS "Enable update for users based on uid" ON users;
DROP POLICY IF EXISTS "users_select_policy" ON users;
DROP POLICY IF EXISTS "users_insert_policy" ON users;
DROP POLICY IF EXISTS "users_update_policy" ON users;
DROP POLICY IF EXISTS "allow_select_users" ON users;
DROP POLICY IF EXISTS "allow_insert_own_user" ON users;
DROP POLICY IF EXISTS "allow_update_own_user" ON users;

-- ============================================
-- STEP 2: Create function to handle new user creation
-- ============================================
-- This function will be triggered by Supabase Auth

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a new row into public.users
  -- using the id and email from auth.users
  INSERT INTO public.users (id, email, name, role, account_status)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    'user',
    'pending'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- STEP 3: Create trigger on auth.users
-- ============================================
-- This trigger fires after a new user is created in auth.users

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- STEP 4: Re-enable RLS with policies
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- SELECT: Allow authenticated users to read user records
CREATE POLICY "allow_select_users"
ON users FOR SELECT
TO authenticated
USING (true);

-- UPDATE: Allow users to update their own record
CREATE POLICY "allow_update_own_user"
ON users FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- DELETE: No policy (disabled)

-- Note: No INSERT policy needed because the trigger handles it

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
  policyname,
  cmd as operation
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;

-- Verify trigger exists
SELECT
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';