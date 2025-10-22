# User Roles & Permissions

The application implements role-based access control (RBAC) with four distinct user roles.

## Role Hierarchy

```
Admin (Full Access)
├── Cashier (Financial Management)
├── Supervisor (Monitoring & Analytics)
└── Normal User (Basic Features)
```

## 1. Normal User

The default role for all approved users.

### Core Permissions

#### Deed Management
- ✅ Submit daily deed reports (save draft / submit final)
- ✅ View own submission history
- ✅ View detailed deed breakdown by category
- ✅ View personal statistics and progress

#### Excuse Management
- ✅ Toggle excuse mode on/off
- ✅ Submit excuse requests (specify which deeds)
- ✅ View own excuse history and status

#### Payment Management
- ✅ Submit payment claims (full or partial)
- ✅ View own payment history
- ✅ View current penalty balance
- ✅ View penalty breakdown by date

#### General Access
- ✅ View rules and policies (accessible even when pending approval)
- ✅ Receive notifications (deadlines, penalties, payments)
- ✅ Update profile information
- ✅ View own analytics and trends
- ✅ Access notification center

### Restrictions
- ❌ Cannot view other users' data
- ❌ Cannot access admin/supervisor features
- ❌ Cannot modify submitted reports
- ❌ Cannot approve own excuses or payments
- ❌ Cannot access system settings

---

## 2. Supervisor

Focuses on monitoring user compliance and community management. **Cannot access financial data.**

### Inherited Permissions
- All **Normal User** permissions

### Additional Permissions

#### User Monitoring
- ✅ View all users' reports and statistics
- ✅ View compliance metrics by user
- ✅ View deed compliance analytics by category
- ✅ Search and filter user reports

#### Analytics & Reporting
- ✅ Access analytics dashboard
- ✅ View system-wide statistics
- ✅ Export reports (PDF/Excel) for selected users or date ranges
- ✅ Generate compliance reports

#### Leaderboard Management
- ✅ View and manage leaderboard rankings
- ✅ Assign special achievement tags (e.g., "Fajr Champion")
- ✅ Remove special tags
- ✅ Create custom achievement criteria

#### Excuse Management
- ✅ View pending excuse requests
- ✅ Approve or reject excuse requests
- ✅ Provide rejection reasons
- ✅ View excuse history and statistics

#### Communication
- ✅ Send manual reminder notifications to users
- ✅ Send notifications to specific users or groups
- ✅ View notification delivery statistics

### Restrictions
- ❌ **Cannot view payments or financial data**
- ❌ **Cannot approve payments**
- ❌ **Cannot adjust penalty balances**
- ❌ Cannot approve new user registrations
- ❌ Cannot suspend or deactivate users
- ❌ Cannot modify system settings
- ❌ Cannot edit deed templates
- ❌ Cannot access audit logs

### Use Cases
- Monitor community engagement and compliance
- Recognize top performers with achievement badges
- Review and approve legitimate excuses
- Send targeted reminders to users at risk

---

## 3. Cashier

Focuses on financial management and payment processing. Has normal user abilities plus financial oversight.

### Inherited Permissions
- All **Normal User** permissions

### Additional Permissions

#### Payment Management
- ✅ View payment history (all users)
- ✅ View pending payment submissions
- ✅ Approve payment claims
- ✅ Reject payment claims (with reason)
- ✅ Search payments by reference number
- ✅ Filter payments by status, date, user

#### Penalty Management
- ✅ View user penalty balances (all users)
- ✅ View penalty history and details
- ✅ Manually adjust user penalty balances (with reason)
- ✅ Clear penalties (partial or full)
- ✅ View payment status and distribution

#### Financial Reporting
- ✅ View payment analytics and trends
- ✅ Export financial reports
- ✅ View total outstanding balances
- ✅ View payment method distribution

### Restrictions
- ❌ Cannot view non-financial user data comprehensively
- ❌ Cannot approve/reject excuses
- ❌ Cannot manage leaderboard or tags
- ❌ Cannot approve new user registrations
- ❌ Cannot modify system settings
- ❌ Cannot edit deed templates
- ❌ Cannot access full audit logs (only payment-related)

### Use Cases
- Review and verify payment submissions
- Manually clear balances for cash payments
- Monitor outstanding balances
- Generate financial reports for admin

---

## 4. Admin

Has complete system access and control over all features.

### Inherited Permissions
- All **Normal User** permissions
- All **Supervisor** permissions
- All **Cashier** permissions

### Additional Permissions

#### User Management
- ✅ Approve new user registrations
- ✅ Reject user registrations (with reason)
- ✅ Suspend user accounts
- ✅ Reactivate suspended/auto-deactivated accounts
- ✅ Delete user accounts
- ✅ Change user roles
- ✅ Manually upgrade membership status
- ✅ Edit user profile information

#### Deed Template Management
- ✅ Add new deed templates
- ✅ Edit existing deed templates (name, category, value type)
- ✅ Change deed sort order (drag-and-drop)
- ✅ Activate/deactivate deeds
- ✅ View deed usage statistics

#### System Configuration
- ✅ Configure penalty amounts (per deed, per 0.1 deed)
- ✅ Configure grace period duration
- ✅ Configure training period for new members
- ✅ Configure auto-deactivation threshold
- ✅ Configure warning thresholds
- ✅ Manage payment methods (add/edit/remove)
- ✅ Configure notification templates
- ✅ Configure notification schedules
- ✅ Manage rest days calendar

#### Report Management
- ✅ Edit individual deed values in submitted reports
- ✅ Delete reports (with reason, logged in audit)
- ✅ Force recalculation of penalties

#### Analytics & Audit
- ✅ View complete analytics dashboard
- ✅ View all system metrics
- ✅ Access audit logs (all actions)
- ✅ Export comprehensive reports

#### Communication
- ✅ Configure email service (Mailgun credentials)
- ✅ Configure FCM settings
- ✅ Send system-wide announcements
- ✅ Create announcement banners

#### App Version Control
- ✅ Set minimum required app version
- ✅ Force app updates
- ✅ Customize update messages

#### Content Management
- ✅ Edit Rules & Policies content
- ✅ Edit About App content
- ✅ Edit Terms & Conditions
- ✅ Edit Privacy Policy

### Use Cases
- Onboard new users and assign roles
- Configure system behavior and business rules
- Handle edge cases and exceptions
- Monitor system health and usage
- Make strategic decisions based on analytics

---

## Role Assignment

### Default Assignment
- New users: **Normal User** (after admin approval)
- First user: **Admin** (during initial setup)

### Role Elevation
Only **Admin** can elevate user roles:
- Normal User → Supervisor
- Normal User → Cashier
- Normal User → Admin
- Supervisor → Admin
- Cashier → Admin

### Role Demotion
Only **Admin** can demote users:
- Admin → Normal User / Supervisor / Cashier
- Supervisor → Normal User
- Cashier → Normal User

**Note:** Cannot demote the last admin in the system (safety mechanism).

---

## Permission Matrix

| Feature | Normal User | Supervisor | Cashier | Admin |
|---------|-------------|------------|---------|-------|
| **Deed Reports** |
| Submit own reports | ✅ | ✅ | ✅ | ✅ |
| View own reports | ✅ | ✅ | ✅ | ✅ |
| View all user reports | ❌ | ✅ | ❌ | ✅ |
| Edit submitted reports | ❌ | ❌ | ❌ | ✅ |
| **Excuses** |
| Submit excuse | ✅ | ✅ | ✅ | ✅ |
| Approve/reject excuses | ❌ | ✅ | ❌ | ✅ |
| **Payments** |
| Submit payment | ✅ | ✅ | ✅ | ✅ |
| View own payments | ✅ | ✅ | ✅ | ✅ |
| View all payments | ❌ | ❌ | ✅ | ✅ |
| Approve/reject payments | ❌ | ❌ | ✅ | ✅ |
| **Penalties** |
| View own penalties | ✅ | ✅ | ✅ | ✅ |
| View all penalties | ❌ | ❌ | ✅ | ✅ |
| Adjust penalties | ❌ | ❌ | ✅ | ✅ |
| **User Management** |
| Approve new users | ❌ | ❌ | ❌ | ✅ |
| Suspend users | ❌ | ❌ | ❌ | ✅ |
| Change roles | ❌ | ❌ | ❌ | ✅ |
| **Analytics** |
| View own stats | ✅ | ✅ | ✅ | ✅ |
| View user analytics | ❌ | ✅ | ❌ | ✅ |
| View financial analytics | ❌ | ❌ | ✅ | ✅ |
| View system analytics | ❌ | ✅ (non-financial) | ✅ (financial) | ✅ |
| **Leaderboard** |
| View leaderboard | ✅ | ✅ | ✅ | ✅ |
| Manage tags | ❌ | ✅ | ❌ | ✅ |
| **System Settings** |
| Configure deed templates | ❌ | ❌ | ❌ | ✅ |
| Configure penalties | ❌ | ❌ | ❌ | ✅ |
| Configure notifications | ❌ | ❌ | ❌ | ✅ |
| Manage rest days | ❌ | ❌ | ❌ | ✅ |
| **Audit & Logs** |
| View audit logs | ❌ | ❌ | Limited | ✅ |

---

## Security Considerations

### Access Control Implementation
- JWT tokens with role embedded in claims
- Backend validation on every API call
- Frontend UI hides features based on role (but backend enforces)
- Role changes require re-authentication

### Audit Logging
All privileged actions are logged:
- Who performed the action
- What action was performed
- When it was performed
- Why (reason field when applicable)
- Old value vs new value

### Role-Specific Security
- **Supervisor**: Cannot access financial data to prevent conflicts of interest
- **Cashier**: Limited to financial functions, cannot influence leaderboard
- **Admin**: All actions logged, cannot delete audit logs

---

[← Back: Project Overview](01-project-overview.md) | [Next: User Status & Membership →](03-user-status.md)
