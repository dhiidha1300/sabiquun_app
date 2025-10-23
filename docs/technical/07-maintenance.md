# Maintenance & Support

## Overview

This document outlines the ongoing maintenance tasks, support channels, backup strategies, monitoring practices, and update procedures necessary to keep the Good Deeds Tracking App running smoothly and reliably. Regular maintenance ensures optimal performance, security, and user satisfaction.

## Regular Maintenance Tasks

### Daily Tasks

**Automated (Cron Jobs):**

1. **Penalty Calculation** (12:00 PM)
   - Calculate penalties for users who missed yesterday's deadline
   - Update user statistics and balances
   - Check auto-deactivation thresholds
   - Send penalty notifications
   - Log any calculation errors

2. **Draft Cleanup** (12:30 PM)
   - Delete expired draft reports (past grace period)
   - Free up storage space
   - Log cleanup statistics

3. **Database Backup** (Daily via Supabase)
   - Automatic daily backups
   - Retained for 30 days
   - Verify backup completion

**Manual Checks:**

- **Monitor Error Logs** (5-10 minutes)
  - Check Sentry for new errors
  - Review critical error alerts
  - Prioritize issues requiring immediate attention

- **Review Pending Approvals** (5 minutes)
  - Check pending user registrations
  - Review flagged content or reports
  - Address urgent admin requests

- **System Health Check** (5 minutes)
  - Verify app is accessible
  - Check API response times
  - Monitor database connections
  - Confirm scheduled jobs ran successfully

### Weekly Tasks

**Every Monday Morning:**

1. **Error Log Review** (30 minutes)
   ```bash
   # Query error logs from past week
   SELECT
     DATE(timestamp) as date,
     level,
     COUNT(*) as count,
     endpoint,
     error_message
   FROM error_logs
   WHERE timestamp >= NOW() - INTERVAL '7 days'
   GROUP BY DATE(timestamp), level, endpoint, error_message
   ORDER BY count DESC;
   ```
   - Analyze error patterns
   - Identify recurring issues
   - Create tickets for bugs requiring fixes
   - Document any workarounds

2. **Performance Metrics Review** (20 minutes)
   - Check Supabase dashboard for slow queries
   - Review API response time averages
   - Monitor database connection pool usage
   - Identify performance bottlenecks
   - Plan optimizations if needed

3. **Pending Actions Review** (15 minutes)
   - Review pending user approvals (waiting >3 days)
   - Check pending payments (waiting >48 hours)
   - Review pending excuses (waiting >24 hours)
   - Send reminders to approvers if needed

4. **User Feedback Review** (20 minutes)
   - Check in-app support requests
   - Review app store reviews (iOS/Android)
   - Monitor social media mentions
   - Respond to user inquiries
   - Log feature requests

### Monthly Tasks

**First Week of Month:**

1. **Database Backup Verification** (30 minutes)
   ```bash
   # Verify backups exist and are valid
   supabase db list-backups

   # Test restore on staging environment
   supabase db restore --backup-id <backup-id> --project-ref staging
   ```
   - Verify automated backups are running
   - Test restore process on staging
   - Document restore time and success
   - Update disaster recovery documentation

2. **Security Audit** (1-2 hours)
   - Review user roles and permissions
   - Check for inactive admin accounts
   - Audit recent admin actions (audit_logs)
   - Scan for potential security vulnerabilities
   - Review rate limiting effectiveness
   - Check for failed login attempts patterns

   ```sql
   -- Check for suspicious login patterns
   SELECT
     email,
     COUNT(*) as failed_attempts,
     MAX(attempted_at) as last_attempt
   FROM auth_logs
   WHERE success = false
     AND attempted_at >= NOW() - INTERVAL '30 days'
   GROUP BY email
   HAVING COUNT(*) > 10
   ORDER BY failed_attempts DESC;
   ```

3. **Database Query Optimization** (1-2 hours)
   ```sql
   -- Identify slow queries
   SELECT
     query,
     calls,
     total_exec_time,
     mean_exec_time,
     max_exec_time
   FROM pg_stat_statements
   WHERE mean_exec_time > 100 -- queries taking >100ms
   ORDER BY total_exec_time DESC
   LIMIT 20;
   ```
   - Review slow queries using `pg_stat_statements`
   - Add indexes where beneficial
   - Optimize complex queries
   - Update materialized views if used
   - Test optimizations on staging first

4. **Dependency Updates** (30-60 minutes)
   ```bash
   # Check for outdated Flutter packages
   flutter pub outdated

   # Update packages (non-breaking)
   flutter pub upgrade --minor-versions

   # Test after updates
   flutter test
   flutter build apk --release
   ```
   - Update Flutter SDK if stable release available
   - Update Flutter packages (non-breaking changes)
   - Update backend dependencies (npm packages)
   - Test thoroughly after updates
   - Deploy updates via CI/CD pipeline

5. **Analytics Reports Review** (1 hour)
   - Generate monthly analytics report
   - Review user engagement metrics
   - Analyze feature usage statistics
   - Identify trends (growth, retention, churn)
   - Present findings to stakeholders

   **Key Metrics:**
   - Daily Active Users (DAU)
   - Monthly Active Users (MAU)
   - Report submission rate
   - Payment approval time
   - User retention rate
   - Average penalty balance
   - Excuse approval rate

6. **Storage and Archive** (30 minutes)
   ```sql
   -- Archive old data (runs automatically via cron)
   -- Manual verification:
   SELECT
     table_name,
     pg_size_pretty(pg_total_relation_size(table_name::regclass)) as size
   FROM (
     VALUES
       ('reports'), ('payments'), ('penalties'),
       ('audit_logs'), ('notifications')
   ) AS t(table_name);
   ```
   - Verify automated archiving ran successfully
   - Archive audit logs older than 1 year
   - Archive notification logs older than 90 days
   - Clean up old profile photos (deleted users)
   - Export archived data to cold storage if needed

### Quarterly Tasks

**Every 3 Months:**

1. **User Feedback Synthesis** (2-3 hours)
   - Compile all user feedback from quarter
   - Identify common themes and pain points
   - Categorize feature requests by priority
   - Create user satisfaction report
   - Present findings to product team

2. **Feature Prioritization** (2-4 hours)
   - Review backlog of feature requests
   - Prioritize based on:
     - User demand
     - Business value
     - Technical complexity
     - Resource availability
   - Create roadmap for next quarter
   - Assign features to sprints/milestones

3. **Performance Optimization** (4-8 hours)
   - Conduct thorough performance audit
   - Profile app on various devices
   - Optimize memory usage
   - Reduce app size if needed
   - Improve cold start time
   - Optimize network requests
   - Implement caching strategies

4. **Security Updates** (2-4 hours)
   - Update SSL certificates (if self-managed)
   - Review and update security policies
   - Conduct penetration testing (or schedule external audit)
   - Update password policies if needed
   - Review GDPR/privacy compliance
   - Rotate API keys and secrets

5. **Disaster Recovery Drill** (2-3 hours)
   - Simulate database failure scenario
   - Practice restore from backup
   - Test failover procedures
   - Update disaster recovery documentation
   - Time the recovery process
   - Identify improvements to procedure

6. **Code Quality Review** (4-6 hours)
   - Review code quality metrics
   - Address technical debt
   - Refactor problematic code sections
   - Update documentation
   - Improve test coverage for critical paths
   - Remove deprecated code

### Annual Tasks

**Once Per Year:**

1. **Comprehensive Security Audit** (external)
   - Hire security firm for penetration testing
   - Review all findings
   - Address critical vulnerabilities
   - Document security improvements

2. **Technology Stack Review**
   - Evaluate current technology choices
   - Research newer alternatives
   - Plan major upgrades if beneficial
   - Consider Flutter SDK major version upgrades

3. **Legal and Compliance Review**
   - Review terms of service
   - Update privacy policy if needed
   - Ensure GDPR compliance
   - Review data retention policies

4. **Team Training**
   - Flutter/Dart updates and best practices
   - Security awareness training
   - New tools and technologies
   - Incident response procedures

## Support Channels

### In-App Support

**Contact Admin Button:**
- Available in user profile/settings
- Sends email to admin support address
- Includes user info and device details
- Auto-creates support ticket

**Implementation:**
```dart
void contactSupport() async {
  final user = await getCurrentUser();
  final deviceInfo = await getDeviceInfo();

  final emailBody = '''
  Support Request from Good Deeds App

  User: ${user.name} (${user.email})
  User ID: ${user.id}
  Account Status: ${user.accountStatus}

  Device: ${deviceInfo.model}
  OS: ${deviceInfo.osVersion}
  App Version: ${deviceInfo.appVersion}

  Message:
  [User will type their message here]
  ''';

  await launchEmail(
    to: 'support@gooddeeds.app',
    subject: 'Support Request - Good Deeds App',
    body: emailBody,
  );
}
```

**FAQ Section:**
- Searchable knowledge base
- Common questions and answers
- Video tutorials (optional)
- Updated based on support tickets

**Rules & Policies Page:**
- System rules and guidelines
- Penalty calculation explanation
- Payment procedures
- Excuse policy
- Available to all users (even pending approval)

### External Support

**Email Support:**
- **Address**: support@gooddeeds.app
- **Response Time**: 24-48 hours (business days)
- **Escalation**: Critical issues < 4 hours

**Email Template Responses:**

```markdown
# New User Welcome
Subject: Welcome to Good Deeds App!

Dear [Name],

Thank you for registering with Good Deeds App. Your account is currently pending admin approval.

You will receive a notification once your account is approved. This typically takes 1-2 business days.

In the meantime, you can review our rules and policies in the app.

Best regards,
Good Deeds Support Team

---

# Account Approved
Subject: Your Good Deeds Account is Approved!

Dear [Name],

Great news! Your Good Deeds account has been approved.

You can now log in and start tracking your daily deeds.

Getting Started:
1. Log in to the app
2. Submit your first daily report
3. Review the 10 default deeds
4. Check your statistics dashboard

If you have any questions, don't hesitate to contact us.

Best regards,
Good Deeds Support Team
```

**Support Ticket System:**
- Use help desk software (e.g., Zendesk, Freshdesk)
- Categorize tickets by type:
  - Technical issue
  - Feature request
  - Payment inquiry
  - Account issue
  - General question
- Track resolution time and satisfaction

### Admin Support

**Internal Communication:**
- Slack/Discord channel for internal team
- Dedicated channel for critical alerts
- On-call rotation for emergencies

**Critical Issue Escalation:**
1. **Severity 1 (Critical)**: App down, data loss
   - Response: Immediate (< 1 hour)
   - Notification: Call/SMS to on-call admin

2. **Severity 2 (High)**: Major feature broken, security issue
   - Response: < 4 hours
   - Notification: Email + Slack alert

3. **Severity 3 (Medium)**: Minor bug, workaround available
   - Response: 1-2 business days
   - Notification: Email

4. **Severity 4 (Low)**: Feature request, cosmetic issue
   - Response: Next sprint/release
   - Notification: Backlog ticket

## Backup Strategy

### Automated Backups

**Supabase Automated Backups:**
- **Frequency**: Daily
- **Retention**: 30 days (Pro tier)
- **Type**: Full database backup
- **Storage**: Supabase managed storage
- **Cost**: Included in Supabase Pro plan

**Backup Schedule:**
```
Daily:   02:00 AM UTC (automatic)
Weekly:  Sunday 04:00 AM (automatic)
Monthly: 1st of month 04:00 AM (automatic)
```

### Manual Backups

**Weekly Manual Backup:**
```bash
#!/bin/bash
# weekly_backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/weekly"
BUCKET="gooddeeds-backups"

# Export database
supabase db dump -f "$BACKUP_DIR/db_backup_$DATE.sql"

# Compress backup
gzip "$BACKUP_DIR/db_backup_$DATE.sql"

# Upload to cloud storage (AWS S3, Google Cloud Storage, etc.)
aws s3 cp "$BACKUP_DIR/db_backup_$DATE.sql.gz" \
  "s3://$BUCKET/weekly/db_backup_$DATE.sql.gz"

# Clean up local backups older than 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Weekly backup completed: db_backup_$DATE.sql.gz"
```

**Schedule with cron:**
```bash
# Run every Sunday at 4:00 AM
0 4 * * 0 /path/to/weekly_backup.sh >> /var/log/weekly_backup.log 2>&1
```

### Backup Retention Policy

| Backup Type | Retention Period | Storage Location |
|-------------|------------------|------------------|
| Daily | 30 days | Supabase |
| Weekly | 12 weeks | Cloud Storage |
| Monthly | 12 months | Cloud Storage |
| Annual | 7 years | Cold Storage |

### Backup Verification

**Monthly Verification Test:**
```bash
# Test restore on staging environment
#!/bin/bash

LATEST_BACKUP=$(supabase db list-backups --json | jq -r '.[0].id')

echo "Testing restore of backup: $LATEST_BACKUP"

# Restore to staging
supabase db restore \
  --backup-id $LATEST_BACKUP \
  --project-ref staging

# Verify data integrity
psql $STAGING_DB_URL << EOF
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM reports;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM penalties;
EOF

echo "Backup verification completed"
```

## Recovery Plan

### Database Recovery Procedures

**Scenario 1: Accidental Data Deletion**

```bash
# 1. Identify when data was deleted
# 2. Find nearest backup before deletion
# 3. Restore to temporary database
supabase db restore --backup-id <backup-id> --project-ref temp

# 4. Export deleted data
pg_dump -t specific_table temp_db > recovered_data.sql

# 5. Import to production
psql $PROD_DB_URL < recovered_data.sql
```

**Scenario 2: Complete Database Failure**

```bash
# 1. Create new Supabase project
supabase projects create --name gooddeeds-recovery

# 2. Restore from latest backup
supabase db restore \
  --backup-id <latest-backup-id> \
  --project-ref gooddeeds-recovery

# 3. Update app environment variables
# Update SUPABASE_URL and keys in .env.production

# 4. Deploy updated app configuration

# 5. Verify data integrity and functionality
```

**Scenario 3: Corrupted Database**

```bash
# 1. Put app in maintenance mode
# 2. Stop all write operations
# 3. Restore from last known good backup
# 4. Replay transaction logs (if available)
# 5. Verify data consistency
# 6. Resume normal operations
```

### Designated Backup Admin

**Primary Contact:**
- Name: [Admin Name]
- Email: admin@gooddeeds.app
- Phone: [Phone Number]
- Role: Database Administrator

**Secondary Contact (Backup):**
- Name: [Backup Admin Name]
- Email: backup-admin@gooddeeds.app
- Phone: [Phone Number]
- Role: Technical Lead

**Emergency Access:**
- Keep encrypted copies of credentials in secure location
- Document access procedures
- Regular drills to ensure familiarity

## Monitoring and Analytics

### Error Monitoring

**Sentry Setup:**
```dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
      options.environment = EnvironmentConfig.environment.toString();
      options.tracesSampleRate = 0.1; // 10% of transactions
      options.beforeSend = (event, hint) {
        // Filter sensitive data
        if (event.user != null) {
          event.user = event.user!.copyWith(email: '[REDACTED]');
        }
        return event;
      };
    },
    appRunner: () => runApp(MyApp()),
  );
}
```

**Alert Rules:**
- **Critical Errors**: Immediate notification to Slack/email
- **High Error Rate**: Alert if >10 errors/minute
- **New Error Type**: Notify when new error first occurs
- **Performance Degradation**: Alert if response time >2x normal

### Performance Monitoring

**Supabase Dashboard Metrics:**
- Database CPU usage
- Memory usage
- Connection count
- Slow query log
- Storage usage

**Application Metrics:**
- API response times
- App crash rate
- Network errors
- User session duration
- Feature usage statistics

### User Analytics

**Firebase Analytics Events:**
```dart
// Track key events
await FirebaseAnalytics.instance.logEvent(
  name: 'report_submitted',
  parameters: {
    'deed_total': 8.5,
    'submission_time': DateTime.now().toString(),
    'membership_status': user.membershipStatus,
  },
);
```

**Key Metrics to Track:**
- Daily/Monthly Active Users
- Report submission rate
- Average deed completion
- Payment frequency
- Feature adoption rates
- User retention cohorts

## Update and Patch Procedures

### Minor Updates (Bug Fixes)

**Process:**
1. **Develop Fix**: Create hotfix branch from main
2. **Test**: Run automated tests + manual verification
3. **Version Bump**: Increment patch version (1.2.3 → 1.2.4)
4. **Build**: Create release builds for iOS/Android
5. **Deploy**: Submit to app stores (fast-track review if critical)
6. **Monitor**: Watch error rates and user feedback

**Timeline**: 1-3 days for critical bugs

### Major Updates (New Features)

**Process:**
1. **Plan**: Review feature requirements and design
2. **Develop**: Implement in feature branch
3. **Test**: Comprehensive testing (unit, integration, E2E)
4. **Beta**: Release to beta testers (TestFlight/Internal testing)
5. **Collect Feedback**: Iterate based on feedback
6. **Version Bump**: Increment minor version (1.2.3 → 1.3.0)
7. **Deploy**: Full production release
8. **Announce**: Notify users via in-app announcement

**Timeline**: 2-4 weeks per major feature

### Database Updates

**Schema Changes:**
```bash
# 1. Create migration
supabase migration new add_new_column

# 2. Test locally
supabase db reset
flutter test

# 3. Apply to staging
supabase db push --project-ref staging

# 4. Verify on staging
# Run integration tests

# 5. Schedule production deployment
# During low-traffic window (2-4 AM)

# 6. Apply to production
supabase db push --project-ref production

# 7. Monitor for errors
```

### Rollback Procedure

**App Rollback:**
- Google Play: Use "Halt rollout" and rollback to previous version
- App Store: Expedited review for critical fixes, or remove from sale temporarily

**Database Rollback:**
```bash
# Revert migration
supabase migration revert

# Or restore from backup
supabase db restore --backup-id <pre-migration-backup>
```

## Maintenance Windows

### Scheduled Maintenance

**Regular Windows:**
- **Frequency**: Quarterly
- **Duration**: 2 hours maximum
- **Time**: Sunday 2:00-4:00 AM (lowest traffic)
- **Notification**: 1 week advance notice

**Maintenance Mode:**
```dart
// Show maintenance screen
class MaintenanceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Scheduled Maintenance',
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 8),
            Text('We\'ll be back online shortly.'),
            Text('Estimated time: 2:00-4:00 AM'),
          ],
        ),
      ),
    );
  }
}
```

### Emergency Maintenance

**Unscheduled Downtime:**
- Notify users via push notification ASAP
- Update app store description with status
- Post updates on social media/website
- Provide regular status updates
- Document incident for post-mortem

## Incident Response

### Incident Severity Levels

**P0 - Critical (< 1 hour response)**
- Complete app outage
- Data breach/security incident
- Data loss

**P1 - High (< 4 hours)**
- Major feature unavailable
- Significant performance degradation
- Payment processing down

**P2 - Medium (< 1 business day)**
- Minor feature broken
- Performance issues for subset of users
- Non-critical bug with workaround

**P3 - Low (Next sprint)**
- Cosmetic issues
- Feature requests
- Minor inconveniences

### Post-Incident Review

**After Every P0/P1 Incident:**
1. **Timeline**: Document incident timeline
2. **Root Cause**: Identify what caused the issue
3. **Impact**: Quantify user impact
4. **Response**: Evaluate response effectiveness
5. **Lessons**: What was learned?
6. **Action Items**: Preventive measures for future

---

## Related Documentation

- [06-deployment.md](./06-deployment.md) - Deployment procedures
- [05-testing.md](./05-testing.md) - Testing strategies
- [08-edge-cases.md](./08-edge-cases.md) - Error handling

---

**Last Updated**: 2025-10-22
**Version**: 1.0
