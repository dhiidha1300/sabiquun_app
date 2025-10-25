-- ============================================
-- ALTERNATIVE APPROACH: Using a Postgres Function
-- ============================================
-- This approach uses a function with SECURITY DEFINER to bypass RLS during signup

-- ============================================
-- STEP 1: Clean up existing policies
-- ============================================
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

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
-- STEP 2: Create a function to handle user creation
-- ============================================
-- This function runs with elevated privileges (SECURITY DEFINER)
-- and can bypass RLS to insert the user record

CREATE OR REPLACE FUNCTION public.create_user_profile(
  user_id UUID,
  user_email TEXT,
  user_name TEXT,
  user_phone TEXT DEFAULT NULL,
  user_photo_url TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER -- This makes the function run with the privileges of the function owner
SET search_path = public
AS $$
DECLARE
  new_user JSON;
BEGIN
  -- Insert the user record (bypasses RLS because of SECURITY DEFINER)
  INSERT INTO users (id, email, name, phone, photo_url, role, account_status)
  VALUES (
    user_id,
    user_email,
    user_name,
    user_phone,
    user_photo_url,
    'user',
    'pending'
  )
  RETURNING to_json(users.*) INTO new_user;

  RETURN new_user;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile TO authenticated;

-- ============================================
-- STEP 3: Re-enable RLS with simple policies
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- SELECT: Allow all authenticated users to read user records
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

-- DELETE: No delete policy (disabled)

-- Note: No INSERT policy needed because we use the function instead

-- ============================================
-- STEP 4: Test the function (optional)
-- ============================================
-- You can test the function like this:
-- SELECT public.create_user_profile(
--   '123e4567-e89b-12d3-a456-426614174000'::UUID,
--   'test@example.com',
--   'Test User',
--   '1234567890',
--   NULL
-- );

-- ============================================
-- VERIFICATION
-- ============================================
SELECT
  policyname,
  cmd as operation
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'users'
ORDER BY policyname;

-- Check if function exists
SELECT proname, prosecdef
FROM pg_proc
WHERE proname = 'create_user_profile';
