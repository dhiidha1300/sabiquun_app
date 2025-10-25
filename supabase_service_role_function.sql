-- ============================================
-- ALTERNATIVE: Use service role with explicit user_id
-- ============================================
-- This version accepts the user_id as a parameter
-- More flexible for signup scenarios

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

-- Drop existing function
DROP FUNCTION IF EXISTS public.create_user_profile(TEXT, TEXT, TEXT);

-- ============================================
-- STEP 2: Create new RPC function with user_id parameter
-- ============================================

CREATE OR REPLACE FUNCTION public.create_user_profile(
  p_user_id UUID,
  p_email TEXT,
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
  -- Check if user profile already exists
  IF EXISTS (SELECT 1 FROM users WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'User profile already exists';
  END IF;

  -- Insert the user record
  INSERT INTO users (id, email, name, phone, photo_url, role, account_status)
  VALUES (
    p_user_id,
    p_email,
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

-- Grant execute permission to anon and authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- ============================================
-- STEP 3: Re-enable RLS
-- ============================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- SELECT: Allow all users to read user records
CREATE POLICY "allow_select_users"
ON users FOR SELECT
USING (true);

-- UPDATE: Allow authenticated users to update their own record
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
SELECT
  proname,
  prosecdef,
  pg_get_function_arguments(oid) as arguments
FROM pg_proc
WHERE proname = 'create_user_profile';