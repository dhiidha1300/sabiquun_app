-- Row Level Security Policies for Sabiquun App
-- Run this in your Supabase SQL Editor

-- ============================================
-- USERS TABLE POLICIES
-- ============================================

-- Enable RLS on users table (if not already enabled)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own data" ON users;
DROP POLICY IF EXISTS "Admins can view all users" ON users;
DROP POLICY IF EXISTS "Allow signup inserts" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Admins can update all users" ON users;
DROP POLICY IF EXISTS "Admins can delete users" ON users;

-- SELECT Policies
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Admins can view all users"
  ON users FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'supervisor', 'cashier')
    )
  );

-- INSERT Policy (Critical for signup!)
-- Allow authenticated users to insert their own record during signup
CREATE POLICY "Allow signup inserts"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- UPDATE Policies
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    -- Users cannot change their own role or account_status
    AND role = (SELECT role FROM users WHERE id = auth.uid())
    AND account_status = (SELECT account_status FROM users WHERE id = auth.uid())
  );

CREATE POLICY "Admins can update all users"
  ON users FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- DELETE Policy
CREATE POLICY "Admins can delete users"
  ON users FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- OTHER TABLES (if RLS is enabled)
-- ============================================

-- If you have RLS enabled on other tables, you'll need policies for them too.
-- Here are some common ones:

-- DEEDS_REPORTS
ALTER TABLE deeds_reports ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own reports" ON deeds_reports;
DROP POLICY IF EXISTS "Supervisors can view all reports" ON deeds_reports;
DROP POLICY IF EXISTS "Users can insert own reports" ON deeds_reports;
DROP POLICY IF EXISTS "Users can update own reports" ON deeds_reports;

CREATE POLICY "Users can view own reports"
  ON deeds_reports FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Supervisors can view all reports"
  ON deeds_reports FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'supervisor')
    )
  );

CREATE POLICY "Users can insert own reports"
  ON deeds_reports FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reports"
  ON deeds_reports FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DEED_ENTRIES
ALTER TABLE deed_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can insert own deed entries" ON deed_entries;
DROP POLICY IF EXISTS "Users can update own deed entries" ON deed_entries;

CREATE POLICY "Users can view own deed entries"
  ON deed_entries FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM deeds_reports
      WHERE deeds_reports.id = deed_entries.report_id
      AND deeds_reports.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own deed entries"
  ON deed_entries FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM deeds_reports
      WHERE deeds_reports.id = deed_entries.report_id
      AND deeds_reports.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own deed entries"
  ON deed_entries FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM deeds_reports
      WHERE deeds_reports.id = deed_entries.report_id
      AND deeds_reports.user_id = auth.uid()
    )
  );

-- PENALTIES
ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own penalties" ON penalties;
DROP POLICY IF EXISTS "Cashiers can view all penalties" ON penalties;

CREATE POLICY "Users can view own penalties"
  ON penalties FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Cashiers can view all penalties"
  ON penalties FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'cashier', 'supervisor')
    )
  );

-- PAYMENTS
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own payments" ON payments;
DROP POLICY IF EXISTS "Users can insert own payments" ON payments;
DROP POLICY IF EXISTS "Cashiers can view all payments" ON payments;
DROP POLICY IF EXISTS "Cashiers can update payments" ON payments;

CREATE POLICY "Users can view own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Cashiers can view all payments"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'cashier')
    )
  );

CREATE POLICY "Cashiers can update payments"
  ON payments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'cashier')
    )
  );

-- EXCUSES
ALTER TABLE excuses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own excuses" ON excuses;
DROP POLICY IF EXISTS "Users can insert own excuses" ON excuses;
DROP POLICY IF EXISTS "Supervisors can view all excuses" ON excuses;
DROP POLICY IF EXISTS "Supervisors can update excuses" ON excuses;

CREATE POLICY "Users can view own excuses"
  ON excuses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own excuses"
  ON excuses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Supervisors can view all excuses"
  ON excuses FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'supervisor')
    )
  );

CREATE POLICY "Supervisors can update excuses"
  ON excuses FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role IN ('admin', 'supervisor')
    )
  );

-- ============================================
-- PUBLIC READ TABLES (No authentication required)
-- ============================================

-- DEED_TEMPLATES (Everyone can read, only admins can modify)
ALTER TABLE deed_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view deed templates" ON deed_templates;
DROP POLICY IF EXISTS "Admins can insert deed templates" ON deed_templates;
DROP POLICY IF EXISTS "Admins can update deed templates" ON deed_templates;
DROP POLICY IF EXISTS "Admins can delete deed templates" ON deed_templates;

CREATE POLICY "Anyone can view deed templates"
  ON deed_templates FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can insert deed templates"
  ON deed_templates FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update deed templates"
  ON deed_templates FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can delete deed templates"
  ON deed_templates FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
    AND is_system_default = false  -- Cannot delete system defaults
  );

-- REST_DAYS (Everyone can read)
ALTER TABLE rest_days ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view rest days" ON rest_days;
DROP POLICY IF EXISTS "Admins can manage rest days" ON rest_days;

CREATE POLICY "Anyone can view rest days"
  ON rest_days FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage rest days"
  ON rest_days FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- SETTINGS (Everyone can read, only admins can modify)
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view settings" ON settings;
DROP POLICY IF EXISTS "Admins can update settings" ON settings;

CREATE POLICY "Anyone can view settings"
  ON settings FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can update settings"
  ON settings FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Run these to verify policies are set correctly:
-- SELECT * FROM pg_policies WHERE tablename = 'users';
-- SELECT * FROM pg_policies WHERE tablename = 'deeds_reports';
-- SELECT * FROM pg_policies WHERE tablename = 'payments';
