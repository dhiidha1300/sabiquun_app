# Testing Guide - Penalty & Payment Systems

## 🚀 How to Access and Test

### Prerequisites

Before testing, ensure:
1. ✅ Supabase project is set up
2. ✅ Database tables exist
3. ✅ `.env` file is configured
4. ✅ App runs without errors

---

## 📋 Database Setup Required

### 1. Create Required Tables

Run these SQL commands in your Supabase SQL Editor:

```sql
-- 1. Penalties Table
CREATE TABLE IF NOT EXISTS penalties (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  report_id UUID REFERENCES deeds_reports(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  date_incurred DATE NOT NULL,
  status VARCHAR(50) DEFAULT 'unpaid',
  paid_amount DECIMAL(10,2) DEFAULT 0,
  waived_by UUID REFERENCES auth.users(id),
  waived_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_penalties_user_id ON penalties(user_id);
CREATE INDEX idx_penalties_date_incurred ON penalties(date_incurred);
CREATE INDEX idx_penalties_status ON penalties(status);

-- 2. Payment Methods Table
CREATE TABLE IF NOT EXISTS payment_methods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default payment methods
INSERT INTO payment_methods (name, display_name, is_active, sort_order) VALUES
('zaad', 'ZAAD', true, 1),
('edahab', 'eDahab', true, 2)
ON CONFLICT DO NOTHING;

-- 3. Payments Table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL,
  payment_method_id UUID REFERENCES payment_methods(id),
  reference_number VARCHAR(255),
  status VARCHAR(50) DEFAULT 'pending',
  reviewed_by UUID REFERENCES auth.users(id),
  reviewed_at TIMESTAMP,
  rejection_reason TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);

-- 4. Penalty Payments Junction Table (FIFO tracking)
CREATE TABLE IF NOT EXISTS penalty_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
  penalty_id UUID NOT NULL REFERENCES penalties(id) ON DELETE CASCADE,
  amount_applied DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_penalty_payments_payment_id ON penalty_payments(payment_id);
CREATE INDEX idx_penalty_payments_penalty_id ON penalty_payments(penalty_id);

-- 5. Settings Table (for thresholds)
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  key VARCHAR(255) UNIQUE NOT NULL,
  value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings
INSERT INTO settings (key, value, description) VALUES
('penalty_per_deed', '5000', 'Penalty amount per missed deed'),
('auto_deactivation_threshold', '500000', 'Balance threshold for auto-deactivation'),
('first_warning_threshold', '400000', 'First warning threshold'),
('final_warning_threshold', '450000', 'Final warning threshold')
ON CONFLICT (key) DO NOTHING;

-- 6. Audit Logs Table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action VARCHAR(255) NOT NULL,
  performed_by UUID REFERENCES auth.users(id),
  entity_type VARCHAR(100),
  entity_id UUID,
  old_value JSONB,
  new_value JSONB,
  reason TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_performed_by ON audit_logs(performed_by);
CREATE INDEX idx_audit_logs_entity_id ON audit_logs(entity_id);
```

### 2. Set Up RLS Policies

```sql
-- Enable RLS
ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE penalty_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- Penalties Policies
CREATE POLICY "Users can view their own penalties"
  ON penalties FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all penalties"
  ON penalties FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'cashier', 'supervisor')
    )
  );

-- Payments Policies
CREATE POLICY "Users can insert their own payments"
  ON payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own payments"
  ON payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can view all payments"
  ON payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'cashier')
    )
  );

CREATE POLICY "Admins can update payments"
  ON payments FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role IN ('admin', 'cashier')
    )
  );

-- Payment Methods Policies
CREATE POLICY "Anyone can view active payment methods"
  ON payment_methods FOR SELECT
  USING (is_active = true);

-- Penalty Payments Policies
CREATE POLICY "Users can view their penalty payments"
  ON penalty_payments FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM payments
      WHERE payments.id = penalty_payments.payment_id
      AND payments.user_id = auth.uid()
    )
  );
```

### 3. Insert Test Data (Optional)

```sql
-- Insert test penalties for current user
-- Replace 'YOUR_USER_ID' with actual user ID
INSERT INTO penalties (user_id, amount, date_incurred, status, paid_amount) VALUES
('YOUR_USER_ID', 10000, '2025-01-05', 'unpaid', 0),
('YOUR_USER_ID', 15000, '2025-01-08', 'unpaid', 0),
('YOUR_USER_ID', 20000, '2025-01-12', 'unpaid', 0),
('YOUR_USER_ID', 5000, '2025-01-15', 'partially_paid', 2000),
('YOUR_USER_ID', 8000, '2024-12-20', 'paid', 8000);

-- Verify
SELECT * FROM penalties WHERE user_id = 'YOUR_USER_ID' ORDER BY date_incurred;
```

---

## 🧪 Testing Steps

### Test 1: View Penalty History

**From Home Page:**
1. Login to the app
2. You need to navigate to penalty history (currently not linked from home)
3. **Temporary Navigation Option A:** Add a button to home page
4. **Temporary Navigation Option B:** Use direct navigation in code

**Add to Home Page (temporary):**
```dart
// In lib/features/home/pages/home_page.dart
ElevatedButton(
  onPressed: () {
    final userId = 'YOUR_USER_ID'; // Get from auth
    context.push('/penalty-history', extra: userId);
  },
  child: const Text('View Penalties'),
)
```

**Expected Results:**
- ✅ See penalty balance card (color-coded)
- ✅ See list of penalties
- ✅ Warning messages if balance high
- ✅ Filter by status works
- ✅ Date range filter works

---

### Test 2: Submit a Payment

**From Home Page:**
```dart
// Add to home page (temporary)
ElevatedButton(
  onPressed: () {
    final userId = 'YOUR_USER_ID'; // Get from auth
    context.push('/submit-payment', extra: userId);
  },
  child: const Text('Submit Payment'),
)
```

**Steps:**
1. Tap "Submit Payment"
2. View current balance and penalty breakdown
3. Select payment method (ZAAD or eDahab)
4. Choose "Full Payment" or "Partial Payment"
5. Enter amount (if partial)
6. Enter reference number (optional)
7. Tap "Submit Payment"
8. Confirm in dialog

**Expected Results:**
- ✅ Payment submitted successfully
- ✅ Status shows "Pending"
- ✅ Redirected back with success message

---

### Test 3: View Payment History

**From Home Page:**
```dart
// Add to home page (temporary)
ElevatedButton(
  onPressed: () {
    final userId = 'YOUR_USER_ID'; // Get from auth
    context.push('/payment-history', extra: userId);
  },
  child: const Text('Payment History'),
)
```

**Expected Results:**
- ✅ See list of submitted payments
- ✅ Status badges (pending/approved/rejected)
- ✅ Payment details visible
- ✅ Filter by status works

---

### Test 4: Admin - Approve Payment (FIFO Test)

**Setup:**
1. Ensure you have an admin/cashier user
2. Ensure there are unpaid penalties
3. Ensure there's a pending payment

**For Admin UI (Not yet implemented - use SQL):**

```sql
-- Get pending payments
SELECT p.*, u.name as user_name, pm.display_name as payment_method
FROM payments p
JOIN users u ON p.user_id = u.id
LEFT JOIN payment_methods pm ON p.payment_method_id = pm.id
WHERE p.status = 'pending'
ORDER BY p.created_at;

-- Get user's unpaid penalties (FIFO order)
SELECT * FROM penalties
WHERE user_id = 'USER_ID'
AND status IN ('unpaid', 'partially_paid')
ORDER BY date_incurred ASC;

-- Manually approve payment (testing FIFO)
-- This would normally be done through the app by admin
```

**Test FIFO via Code:**
```dart
// For admin user only
context.read<PaymentBloc>().add(
  ApprovePaymentRequested(
    paymentId: 'PAYMENT_ID',
    reviewedBy: 'ADMIN_USER_ID',
  ),
);
```

**Expected FIFO Results:**
```
Before Approval:
- Penalty 1 (Jan 5):  10,000 unpaid
- Penalty 2 (Jan 8):  15,000 unpaid
- Penalty 3 (Jan 12): 20,000 unpaid
Payment Amount: 30,000

After Approval (FIFO):
✓ Penalty 1: 10,000 paid (amount_applied: 10,000)
✓ Penalty 2: 15,000 paid (amount_applied: 15,000)
✓ Penalty 3: 5,000 applied (amount_applied: 5,000, remaining: 15,000)

Verify in DB:
SELECT * FROM penalty_payments WHERE payment_id = 'PAYMENT_ID';
SELECT * FROM penalties WHERE user_id = 'USER_ID' ORDER BY date_incurred;
```

---

### Test 5: Verify FIFO in Database

```sql
-- After approving payment, check:

-- 1. Payment status should be 'approved'
SELECT * FROM payments WHERE id = 'PAYMENT_ID';

-- 2. Penalty_payments records created (FIFO order)
SELECT pp.*, p.date_incurred, p.amount as penalty_amount
FROM penalty_payments pp
JOIN penalties p ON pp.penalty_id = p.id
WHERE pp.payment_id = 'PAYMENT_ID'
ORDER BY p.date_incurred;

-- 3. Penalties updated correctly
SELECT
  date_incurred,
  amount as total,
  paid_amount,
  (amount - paid_amount) as remaining,
  status
FROM penalties
WHERE user_id = 'USER_ID'
ORDER BY date_incurred;

-- 4. Audit logs created
SELECT * FROM audit_logs
WHERE entity_id = 'PAYMENT_ID'
ORDER BY timestamp DESC;
```

---

## 🔧 Quick Integration into Existing Home Page

**Option 1: Add Temporary Navigation Buttons**

```dart
// lib/features/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sabiquun'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final userId = state.user.id;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome, ${state.user.fullName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  // PENALTY SYSTEM ACCESS
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/penalty-history', extra: userId);
                    },
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('View Penalty History'),
                  ),
                  const SizedBox(height: 16),

                  // PAYMENT SUBMISSION
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/submit-payment', extra: userId);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Submit Payment'),
                  ),
                  const SizedBox(height: 16),

                  // PAYMENT HISTORY
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/payment-history', extra: userId);
                    },
                    icon: const Icon(Icons.history),
                    label: const Text('Payment History'),
                  ),
                  const SizedBox(height: 32),

                  // Existing navigation buttons
                  OutlinedButton(
                    onPressed: () {
                      context.push('/today-deeds');
                    },
                    child: const Text('Submit Today\'s Deeds'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      context.push('/my-reports');
                    },
                    child: const Text('My Reports'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

**Option 2: Use Navigation from Anywhere**

```dart
// In any widget where you have access to userId
final userId = context.read<AuthBloc>().state is Authenticated
  ? (context.read<AuthBloc>().state as Authenticated).user.id
  : null;

if (userId != null) {
  // Navigate to penalty history
  context.push('/penalty-history', extra: userId);

  // Or submit payment
  context.push('/submit-payment', extra: userId);

  // Or payment history
  context.push('/payment-history', extra: userId);
}
```

---

## 📊 Testing Checklist

### User Flow
- [ ] User can view penalty balance
- [ ] User can see penalty breakdown
- [ ] User can filter penalties by status
- [ ] User can filter penalties by date
- [ ] User can submit full payment
- [ ] User can submit partial payment
- [ ] User can view payment history
- [ ] User receives feedback on submission

### Admin Flow (Manual SQL Testing)
- [ ] Admin can see pending payments
- [ ] Admin can approve payment
- [ ] FIFO logic applies correctly
- [ ] Penalty statuses update
- [ ] Penalty_payments records created
- [ ] Audit logs created

### FIFO Verification
- [ ] Oldest penalty paid first
- [ ] Partial payments tracked correctly
- [ ] Multiple penalties can be paid in one payment
- [ ] Remaining balance calculated correctly
- [ ] Junction table has correct records

### Edge Cases
- [ ] Payment amount > total balance (handled)
- [ ] Zero balance (no penalties shown)
- [ ] All penalties paid (shows success)
- [ ] Payment rejected (balance unchanged)
- [ ] Warning thresholds display correctly

---

## 🐛 Common Issues

### Issue 1: "User not authenticated"
**Solution:** Ensure you're logged in and AuthBloc state is `Authenticated`

### Issue 2: "No penalties found"
**Solution:** Insert test data using SQL above, or create penalties via deed reporting

### Issue 3: "Payment methods not showing"
**Solution:** Check if payment_methods table has active records:
```sql
SELECT * FROM payment_methods WHERE is_active = true;
```

### Issue 4: RLS Policy Errors
**Solution:** Verify RLS policies are created and user has correct role in users table

### Issue 5: Navigation errors
**Solution:** Ensure userId is being passed correctly:
```dart
final userId = (context.read<AuthBloc>().state as Authenticated).user.id;
context.push('/penalty-history', extra: userId);
```

---

## 🎯 Next Steps After Testing

1. **Integrate into Home Screen properly** (next conversation)
2. **Add admin payment review UI** (if needed)
3. **Add receipt PDF generation**
4. **Add push notifications**
5. **Add pagination for large lists**
6. **Add unit tests for FIFO logic**

---

## 📞 Need Help?

**Common Queries:**

**Q: How do I get the current user's ID?**
```dart
final state = context.read<AuthBloc>().state;
if (state is Authenticated) {
  final userId = state.user.id;
  // Use userId
}
```

**Q: How do I test FIFO without admin UI?**
A: Use SQL to manually approve payments (shown above) or create admin test account

**Q: Can I modify the FIFO logic?**
A: Yes, it's in `lib/features/payments/data/datasources/payment_remote_datasource.dart` lines 150-240

**Q: Where are the BLoCs registered?**
A: In `lib/main.dart` - MultiBlocProvider includes PenaltyBloc and PaymentBloc

---

**Happy Testing! 🚀**

Last Updated: October 27, 2025
