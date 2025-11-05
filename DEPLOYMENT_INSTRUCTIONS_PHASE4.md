# Phase 4: Monitoring & Admin Dashboard

## Overview

Phase 4 adds monitoring capabilities to the admin dashboard, allowing administrators to:
- View the status of automated penalty calculation
- See last execution time and results
- Manually trigger penalty calculation if needed
- Monitor system health
- View notification queue status

---

## Step 1: Install Dependencies

### 1.1 Add timeago Package

The `timeago` package has already been added to `pubspec.yaml`. Install it:

```bash
cd d:\sabiquun_app\sabiquun_app
flutter pub get
```

**Expected output:**
```
Running "flutter pub get" in sabiquun_app...
+ timeago 3.7.0
Changed 1 dependency!
```

---

## Step 2: Integrate Monitoring Widget

### 2.1 Add Widget to Admin Home

Open [admin_home_content.dart](d:\sabiquun_app\sabiquun_app\lib\features\home\pages\admin_home_content.dart)

Find the `_buildAnalyticsDashboard()` method and add the monitoring card at the top:

```dart
Widget _buildAnalyticsDashboard() {
  return BlocBuilder<AdminBloc, AdminState>(
    builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Health Section
          Text(
            'System Health',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Penalty Calculation Status Card
          const PenaltyCalculationStatusCard(),
          const SizedBox(height: 20),

          // Analytics Dashboard Title
          Text(
            'Analytics Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // ... existing analytics content ...
        ],
      );
    },
  );
}
```

### 2.2 Import the Widget

Add this import at the top of `admin_home_content.dart`:

```dart
import 'package:sabiquun_app/features/admin/presentation/widgets/penalty_calculation_status_card.dart';
```

---

## Step 3: Test the Monitoring Widget

### 3.1 Run the App

```bash
flutter run
```

### 3.2 Navigate to Admin Dashboard

1. Login as an admin user
2. Go to Home screen
3. Scroll down to "System Health" section
4. You should see the **Penalty Calculation Status Card**

### 3.3 Verify Widget Functions

**Status Indicators:**
- ✅ **Green check** = Last run < 25 hours ago (healthy)
- ⚠️ **Yellow warning** = Last run 25-48 hours ago (warning)
- ❌ **Red error** = Last run > 48 hours ago (critical)
- ❓ **Gray help** = No execution history

**Information Displayed:**
- Last run time (e.g., "2 hours ago")
- Users processed
- Penalties created
- Error count (if any)
- Scheduled time: "Daily at 12:00 PM EAT (9:00 AM UTC)"

**Actions:**
- 🔄 **Refresh button** = Manually trigger penalty calculation

---

## Step 4: Test Manual Trigger

### 4.1 Click Refresh Button

In the admin dashboard, click the refresh icon in the Penalty Calculation Status Card.

### 4.2 Expected Behavior

1. Button shows loading spinner
2. After 2-5 seconds, shows success snackbar:
   ```
   Penalty calculation completed: X users processed, Y penalties created
   ```
3. Card updates with new execution data
4. Last run time updates to "a few seconds ago"

### 4.3 Verify in Database

Open Supabase Dashboard → **SQL Editor**:

```sql
-- Check latest execution
SELECT *
FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 1;

-- Check if any penalties were created
SELECT COUNT(*) as count
FROM penalties
WHERE date_incurred = CURRENT_DATE - INTERVAL '1 day';
```

---

## Step 5: Create Health Check Monitoring

### 5.1 Create Monitoring SQL View

This creates a convenient view for admins to check system health:

```sql
-- Create monitoring view
CREATE OR REPLACE VIEW penalty_system_health AS
SELECT
  -- Last execution info
  (SELECT execution_time FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1) as last_execution,
  (SELECT users_processed FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1) as last_users_processed,
  (SELECT penalties_created FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1) as last_penalties_created,

  -- Health metrics
  EXTRACT(EPOCH FROM (NOW() - (SELECT execution_time FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1))) / 3600 as hours_since_last_run,

  CASE
    WHEN EXTRACT(EPOCH FROM (NOW() - (SELECT execution_time FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1))) / 3600 < 25 THEN 'healthy'
    WHEN EXTRACT(EPOCH FROM (NOW() - (SELECT execution_time FROM penalty_calculation_log ORDER BY execution_time DESC LIMIT 1))) / 3600 < 48 THEN 'warning'
    ELSE 'critical'
  END as health_status,

  -- Statistics
  (SELECT COUNT(*) FROM penalty_calculation_log) as total_executions,
  (SELECT COUNT(*) FROM penalty_calculation_log WHERE result->>'success' = 'true') as successful_executions,
  (SELECT COUNT(*) FROM penalty_calculation_log WHERE result->>'success' = 'false') as failed_executions,

  -- Notification queue stats
  (SELECT COUNT(*) FROM notification_queue WHERE status = 'pending') as pending_notifications,
  (SELECT COUNT(*) FROM notification_queue WHERE status = 'sent') as sent_notifications,
  (SELECT COUNT(*) FROM notification_queue WHERE status = 'failed') as failed_notifications;

-- Grant access
GRANT SELECT ON penalty_system_health TO authenticated;
```

### 5.2 Query the Health View

```sql
SELECT * FROM penalty_system_health;
```

**Example output:**
```
last_execution       | 2025-11-04 09:00:00
last_users_processed | 15
last_penalties_created | 3
hours_since_last_run | 2.5
health_status        | healthy
total_executions     | 10
successful_executions| 10
failed_executions    | 0
pending_notifications| 5
sent_notifications   | 25
failed_notifications | 0
```

---

## Step 6: Create Admin Alert System (Optional)

### 6.1 Create Admin Alerts Table

```sql
-- Table for admin alerts
CREATE TABLE IF NOT EXISTS admin_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type TEXT NOT NULL,
  severity TEXT NOT NULL CHECK (severity IN ('info', 'warning', 'critical')),
  message TEXT NOT NULL,
  resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP,
  resolved_by UUID REFERENCES users(id)
);

CREATE INDEX idx_admin_alerts_severity ON admin_alerts(severity);
CREATE INDEX idx_admin_alerts_resolved ON admin_alerts(resolved);
CREATE INDEX idx_admin_alerts_created_at ON admin_alerts(created_at DESC);

-- Enable RLS
ALTER TABLE admin_alerts ENABLE ROW LEVEL SECURITY;

-- Admins can view all alerts
CREATE POLICY "Admins can view alerts"
  ON admin_alerts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Service role can insert alerts
CREATE POLICY "Service role can insert alerts"
  ON admin_alerts FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Admins can update alerts (mark as resolved)
CREATE POLICY "Admins can update alerts"
  ON admin_alerts FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### 6.2 Create Alert Function

```sql
-- Function to create admin alert
CREATE OR REPLACE FUNCTION create_admin_alert(
  p_type TEXT,
  p_severity TEXT,
  p_message TEXT
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_alert_id UUID;
BEGIN
  INSERT INTO admin_alerts (type, severity, message)
  VALUES (p_type, p_severity, p_message)
  RETURNING id INTO v_alert_id;

  RAISE NOTICE 'Admin alert created: % - %', p_severity, p_message;

  RETURN v_alert_id;
END;
$$;

GRANT EXECUTE ON FUNCTION create_admin_alert(TEXT, TEXT, TEXT) TO service_role;
```

### 6.3 Test Alert Creation

```sql
-- Create test alert
SELECT create_admin_alert(
  'penalty_calculation_failed',
  'critical',
  'Penalty calculation has not run for 50 hours'
);

-- View alerts
SELECT * FROM admin_alerts
ORDER BY created_at DESC;
```

---

## Step 7: Create Notification Queue Monitoring Widget (Optional)

### 7.1 Create Widget File

Create `notification_queue_status_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:sabiquun_app/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationQueueStatusCard extends StatefulWidget {
  const NotificationQueueStatusCard({super.key});

  @override
  State<NotificationQueueStatusCard> createState() =>
      _NotificationQueueStatusCardState();
}

class _NotificationQueueStatusCardState
    extends State<NotificationQueueStatusCard> {
  Map<String, int>? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Get counts for each status
      final pending = await supabase
          .from('notification_queue')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'pending');

      final sent = await supabase
          .from('notification_queue')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'sent');

      final failed = await supabase
          .from('notification_queue')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'failed');

      if (mounted) {
        setState(() {
          _stats = {
            'pending': pending.count ?? 0,
            'sent': sent.count ?? 0,
            'failed': failed.count ?? 0,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        color: AppColors.surface,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final pending = _stats?['pending'] ?? 0;
    final sent = _stats?['sent'] ?? 0;
    final failed = _stats?['failed'] ?? 0;

    return Card(
      color: AppColors.surface,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Notification Queue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, color: AppColors.primary),
                  onPressed: _loadStats,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Pending', pending, AppColors.warning),
                _buildStatColumn('Sent', sent, AppColors.success),
                _buildStatColumn('Failed', failed, AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
```

### 7.2 Add to Admin Dashboard

In `admin_home_content.dart`, add below the Penalty Calculation Status Card:

```dart
const NotificationQueueStatusCard(),
const SizedBox(height: 20),
```

---

## ✅ Phase 4 Complete!

Checklist:
- ✅ timeago package installed
- ✅ Penalty Calculation Status Card created
- ✅ Widget integrated into admin dashboard
- ✅ Manual trigger functionality working
- ✅ Health monitoring view created
- ✅ Admin alerts system created (optional)
- ✅ Notification queue monitoring (optional)

**Next:** Phase 5 - End-to-End Testing

---

## Testing Checklist

### Visual Testing
- [ ] Open admin dashboard
- [ ] Penalty calculation status card visible
- [ ] Status indicator correct (green/yellow/red)
- [ ] Last run time displays correctly
- [ ] Execution statistics shown

### Functional Testing
- [ ] Click refresh button
- [ ] Loading spinner appears
- [ ] Success message shown
- [ ] Card updates with new data
- [ ] Database log updated

### Database Testing
```sql
-- View monitoring data
SELECT * FROM penalty_system_health;

-- View recent executions
SELECT * FROM penalty_calculation_log
ORDER BY execution_time DESC
LIMIT 5;

-- View admin alerts
SELECT * FROM admin_alerts
WHERE resolved = false
ORDER BY created_at DESC;
```

---

## Troubleshooting

### Widget not appearing
**Check:**
- Import added to `admin_home_content.dart`
- Widget added to build method
- `flutter pub get` ran successfully

### "Table doesn't exist" error
**Solution:** Deploy Phase 1 SQL script first
```sql
-- Check table exists
SELECT table_name FROM information_schema.tables
WHERE table_name = 'penalty_calculation_log';
```

### Manual trigger fails
**Check:**
- User has admin role
- Database function deployed (Phase 1)
- Supabase connection working
- Check function logs in Supabase Dashboard

### Status always shows "No execution history"
**Solution:** Run manual trigger once or wait for first automated execution at 12 PM EAT

---

## Maintenance

### Daily Monitoring
Check the admin dashboard daily to ensure:
- Status is green (healthy)
- Last run was within 24 hours
- No failed executions
- Notification queue is processing

### Weekly Review
```sql
-- Weekly execution summary
SELECT
  DATE(execution_time) as date,
  COUNT(*) as executions,
  SUM(users_processed) as total_users,
  SUM(penalties_created) as total_penalties
FROM penalty_calculation_log
WHERE execution_time > CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(execution_time)
ORDER BY date DESC;
```

### Monthly Cleanup
```sql
-- Clean old sent notifications (older than 30 days)
SELECT cleanup_old_notifications();

-- View cleanup result
```
