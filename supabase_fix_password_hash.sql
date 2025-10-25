-- ============================================
-- FIX: Password Hash Column Issue
-- ============================================
-- Since we're using Supabase Auth, we don't need password_hash
-- in the public.users table. We'll make it nullable.

-- ============================================
-- OPTION 1 (RECOMMENDED): Make password_hash nullable
-- ============================================

-- Make password_hash column nullable
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- Set a default value for existing records if any
UPDATE users SET password_hash = NULL WHERE password_hash = '';

-- ============================================
-- Now update the create_user_profile function
-- ============================================

DROP FUNCTION IF EXISTS public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT);

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

  -- Insert the user record (password_hash is now nullable)
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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;

-- ============================================
-- VERIFICATION
-- ============================================

-- Check that password_hash is now nullable
SELECT column_name, is_nullable, data_type
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'password_hash';

-- Expected output: is_nullable should be 'YES'

-- ============================================
-- ALTERNATIVE OPTION 2: Keep NOT NULL but use placeholder
-- ============================================
-- If you want to keep password_hash as NOT NULL, uncomment below:

/*
-- Revert to NOT NULL
ALTER TABLE users ALTER COLUMN password_hash SET NOT NULL;

-- Update function to use placeholder
DROP FUNCTION IF EXISTS public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT);

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
  IF EXISTS (SELECT 1 FROM users WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'User profile already exists';
  END IF;

  INSERT INTO users (id, email, password_hash, name, phone, photo_url, role, account_status)
  VALUES (
    p_user_id,
    p_email,
    'AUTH_MANAGED', -- Placeholder since Supabase Auth manages passwords
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

GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.create_user_profile(UUID, TEXT, TEXT, TEXT, TEXT) TO authenticated;
*/