-- ============================================
-- BEST SOLUTION: RPC Function Approach
-- ============================================
-- This creates a database function that your Flutter app will call
-- The function runs with elevated privileges and bypasses RLS

-- ============================================
-- STEP 1: Clean up
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
-- STEP 2: Create RPC function for user creation
-- ============================================

CREATE OR REPLACE FUNCTION public.create_user_profile(
  p_name TEXT,
  p_phone TEXT DEFAULT NULL,
  p_photo_url TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_data JSON;
BEGIN
  -- Check that the user is authenticated
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Check if user profile already exists
  IF EXISTS (SELECT 1 FROM users WHERE id = auth.uid()) THEN
    RAISE EXCEPTION 'User profile already exists';
  END IF;

  -- Insert the user record
  INSERT INTO users (id, email, name, phone, photo_url, role, account_status)
  VALUES (
    auth.uid(),
    auth.email(),
    p_name,
    p_phone,
    p_photo_url,
    'user',
    'pending'
  )
  RETURNING row_to_json(users.*) INTO user_data;

  RETURN user_data;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile(TEXT, TEXT, TEXT) TO authenticated;

-- ============================================
-- STEP 3: Re-enable RLS
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

-- No INSERT or DELETE policies needed

-- ============================================
-- VERIFICATION
-- ============================================

-- Check policies
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'users';

-- Check function
SELECT proname, prosecdef
FROM pg_proc
WHERE proname = 'create_user_profile';

-- ============================================
-- TEST THE FUNCTION (After you sign up with Supabase Auth)
-- ============================================
-- SELECT public.create_user_profile('John Doe', '1234567890', NULL);