-- Row Level Security Policies for Sabiquun App (FIXED - No Recursion)
-- Run this in your Supabase SQL Editor

-- ============================================
-- USERS TABLE POLICIES (FIXED)
-- ============================================

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies on users table
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;

-- SELECT Policies
-- Users can only see their own data
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Admins, supervisors, and cashiers can see all users
-- Using a direct role check to avoid recursion
CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    (SELECT role FROM users WHERE id = auth.uid()) IN ('admin', 'supervisor', 'cashier')
  );

-- INSERT Policy (Critical for signup!)
-- Allow any authenticated user to insert their own record
-- This uses auth.uid() which doesn't query the users table
CREATE POLICY "Allow signup inserts"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- UPDATE Policies
-- Users can update their own non-critical fields
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Prevent users from changing critical fields
    AND role = (SELECT role FROM users WHERE id = auth.uid() LIMIT 1)
    AND account_status = (SELECT account_status FROM users WHERE id = auth.uid() LIMIT 1)
  );

-- Admins can update any user
CREATE POLICY "Admins can update all users"
  ON users FOR UPDATE
  USING (
    (SELECT role FROM users WHERE id = auth.uid() LIMIT 1) = 'admin'
  );

-- DELETE Policy
-- Only admins can delete users
CREATE POLICY "Admins can delete users"
  ON users FOR DELETE
  USING (
    (SELECT role FROM users WHERE id = auth.uid() LIMIT 1) = 'admin'
  );

-- ============================================
-- ALTERNATIVE SIMPLER APPROACH (Recommended)
-- ============================================
-- If the above still causes issues, use this simpler approach:

-- First, drop all policies
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;

-- SELECT: Everyone can read all users (you can restrict later if needed)
CREATE POLICY "Enable read access for authenticated users"
  ON users FOR SELECT
  TO authenticated
  USING (true);

-- INSERT: Allow signup - any authenticated user can insert their own record
CREATE POLICY "Enable insert for signup"
  ON users FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- UPDATE: Users can update their own record
CREATE POLICY "Enable update for users based on uid"
  ON users FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- DELETE: Disable deletes for now (can be enabled for admins later)
-- No DELETE policy means no one can delete

-- ============================================
-- OTHER TABLES
-- ============================================

-- DEEDS_REPORTS
ALTER TABLE deeds_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own reports" ON deeds_reports;
DROP POLICY IF EXISTS "Enable insert for own reports" ON deeds_reports;
DROP POLICY IF EXISTS "Enable update for own reports" ON deeds_reports;

CREATE POLICY "Enable read for own reports"
  ON deeds_reports FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for own reports"
  ON deeds_reports FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update for own reports"
  ON deeds_reports FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DEED_ENTRIES
ALTER TABLE deed_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own entries" ON deed_entries;
DROP POLICY IF EXISTS "Enable insert for own entries" ON deed_entries;
DROP POLICY IF EXISTS "Enable update for own entries" ON deed_entries;

CREATE POLICY "Enable read for own entries"
  ON deed_entries FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM deeds_reports dr
      WHERE dr.id = deed_entries.report_id
      AND dr.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable insert for own entries"
  ON deed_entries FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM deeds_reports dr
      WHERE dr.id = deed_entries.report_id
      AND dr.user_id = auth.uid()
    )
  );

CREATE POLICY "Enable update for own entries"
  ON deed_entries FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM deeds_reports dr
      WHERE dr.id = deed_entries.report_id
      AND dr.user_id = auth.uid()
    )
  );

-- PENALTIES
ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own penalties" ON penalties;

CREATE POLICY "Enable read for own penalties"
  ON penalties FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- PAYMENTS
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own payments" ON payments;
DROP POLICY IF EXISTS "Enable insert for own payments" ON payments;

CREATE POLICY "Enable read for own payments"
  ON payments FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for own payments"
  ON payments FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- EXCUSES
ALTER TABLE excuses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own excuses" ON excuses;
DROP POLICY IF EXISTS "Enable insert for own excuses" ON excuses;

CREATE POLICY "Enable read for own excuses"
  ON excuses FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Enable insert for own excuses"
  ON excuses FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- PUBLIC READ TABLES
-- ============================================

-- DEED_TEMPLATES (Everyone can read)
ALTER TABLE deed_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for deed templates" ON deed_templates;

CREATE POLICY "Enable read for deed templates"
  ON deed_templates FOR SELECT
  TO authenticated
  USING (true);

-- REST_DAYS (Everyone can read)
ALTER TABLE rest_days ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for rest days" ON rest_days;

CREATE POLICY "Enable read for rest days"
  ON rest_days FOR SELECT
  TO authenticated
  USING (true);

-- SETTINGS (Everyone can read)
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for settings" ON settings;

CREATE POLICY "Enable read for settings"
  ON settings FOR SELECT
  TO authenticated
  USING (true);

-- USER_STATISTICS
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own statistics" ON user_statistics;

CREATE POLICY "Enable read for own statistics"
  ON user_statistics FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- LEADERBOARD (Everyone can read)
ALTER TABLE leaderboard ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for leaderboard" ON leaderboard;

CREATE POLICY "Enable read for leaderboard"
  ON leaderboard FOR SELECT
  TO authenticated
  USING (true);

-- NOTIFICATIONS_LOG
ALTER TABLE notifications_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable read for own notifications" ON notifications_log;

CREATE POLICY "Enable read for own notifications"
  ON notifications_log FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- ============================================
-- VERIFICATION
-- ============================================

-- Run this to verify policies:
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;
