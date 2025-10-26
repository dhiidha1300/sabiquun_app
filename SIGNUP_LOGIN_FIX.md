# Signup/Login Issue - Diagnosis & Fix

## What Happened

✅ **Signup worked!** User was created in `public.users` table
❌ **Login failed** with "Invalid login credentials"

## Root Cause

Supabase has **two separate user tables**:

1. **`auth.users`** - Managed by Supabase Auth (handles authentication/passwords)
2. **`public.users`** - Your custom table (stores profile data)

The user exists in `public.users` but might not exist in `auth.users`, OR email confirmation is required.

---

## Diagnosis Steps

### Step 1: Check if user exists in auth.users

Run this in **Supabase SQL Editor**:

```sql
-- Check auth.users table
SELECT
  id,
  email,
  email_confirmed_at,
  confirmed_at,
  created_at
FROM auth.users
WHERE email = 'bullaale33@gmail.com';
```

**Expected Results:**

- **If 1 row returned**: User exists in auth, check `email_confirmed_at`
  - If `email_confirmed_at` is NULL → Email confirmation required
  - If `email_confirmed_at` has a date → Email confirmed, password might be wrong

- **If 0 rows returned**: User doesn't exist in auth.users → Signup partially failed

### Step 2: Check Supabase Email Confirmation Settings

1. Go to **Supabase Dashboard** → **Authentication** → **Email Templates**
2. Check if **"Confirm signup"** is enabled
3. Go to **Settings** → **Auth** → Check **"Enable email confirmations"**

---

## Solutions

### Solution A: If Email Confirmation is Required

**Option 1: Disable email confirmation (for testing)**

1. Go to **Supabase Dashboard** → **Authentication** → **Providers** → **Email**
2. Uncheck **"Confirm email"**
3. Try signup again with a new email

**Option 2: Manually confirm the email in database**

```sql
-- Manually confirm email for existing user
UPDATE auth.users
SET
  email_confirmed_at = NOW(),
  confirmed_at = NOW()
WHERE email = 'bullaale33@gmail.com';
```

Then try logging in again.

---

### Solution B: If User Doesn't Exist in auth.users

This means `auth.signUp()` failed silently. Let's fix the signup process:

**Update the Flutter code to check for errors:**

```dart
// In auth_remote_datasource.dart
Future<UserModel> signUp({...}) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    // ADD THIS: Check for signup errors
    if (response.session == null) {
      // Email confirmation might be required
      print('⚠️ Session is null - email confirmation may be required');
    }

    // Continue with profile creation...
```

---

### Solution C: Test with a Fresh Signup

The easiest way to test:

1. **Disable email confirmation** in Supabase Dashboard (Authentication → Providers → Email)
2. **Delete the existing user** from both tables:

```sql
-- Delete from public.users
DELETE FROM public.users WHERE email = 'bullaale33@gmail.com';

-- Delete from auth.users (if exists)
DELETE FROM auth.users WHERE email = 'bullaale33@gmail.com';
```

3. **Sign up again** with the same email
4. **Try logging in immediately**

---

## Quick Fix for Your Current User

If you just want to make the current user work:

### Option 1: Manually confirm email (if user exists in auth.users)

```sql
UPDATE auth.users
SET
  email_confirmed_at = NOW(),
  confirmed_at = NOW()
WHERE email = 'bullaale33@gmail.com';
```

### Option 2: Create auth user manually (if user doesn't exist in auth.users)

Unfortunately, you can't create auth.users directly. You need to:

1. Delete the user from public.users
2. Sign up again through the app
3. This time it will create both records

---

## Recommended Action Plan

1. **Run the diagnostic SQL** to check if user exists in `auth.users`
2. **Check email confirmation settings** in Supabase Dashboard
3. **Choose the appropriate solution** based on the diagnosis
4. **For future signups**: Consider disabling email confirmation during development

---

## Prevention for Future

To avoid this issue:

### Update signup to handle email confirmation:

```dart
Future<UserModel> signUp({...}) async {
  try {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    // Check if email confirmation is required
    if (response.session == null) {
      throw Exception(
        'Email confirmation required. Please check your email to verify your account.',
      );
    }

    // Create profile only if session exists
    final userData = await _supabase.rpc('create_user_profile', params: {
      'p_user_id': response.user!.id,
      'p_email': email,
      'p_name': fullName,
      'p_phone': phoneNumber,
      'p_photo_url': profilePhotoUrl,
    });

    return UserModel.fromJson(userData as Map<String, dynamic>);
  } catch (e) {
    // Handle errors...
  }
}
```

Let me know what you find after running the diagnostic queries!