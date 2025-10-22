# Sabiquun App - Good Deeds Tracking Application

A comprehensive Flutter mobile application for tracking daily Islamic good deeds with a financial accountability system.

## Project Overview

**Purpose:** Track daily Islamic good deeds with financial accountability system

**Tech Stack:**
- **Frontend:** Flutter (iOS & Android)
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Email Service:** Mailgun (configurable by admin)
- **File Storage:** Supabase Storage
- **Export Formats:** PDF & Excel

## Core Concept

- Users track 10 daily deeds with customizable targets
- Missing deeds incur financial penalties (5,000 shillings per deed)
- Penalty per 0.1 deed = 500 shillings
- Grace period until 12 PM next day
- Admin approval system for new users
- Multiple user roles with distinct permissions

## Documentation Structure

### 📋 Planning & Requirements
- [Project Overview](docs/planning/01-project-overview.md) - Application purpose, goals, and core concepts
- [User Roles & Permissions](docs/planning/02-user-roles.md) - Detailed role-based access control
- [User Status & Membership](docs/planning/03-user-status.md) - Membership tiers and account status

### 🎯 Core Features
- [Deed System](docs/features/01-deed-system.md) - Daily deed tracking, templates, and reporting
- [Penalty System](docs/features/02-penalty-system.md) - Calculation, accumulation, and management
- [Excuse System](docs/features/03-excuse-system.md) - Excuse types, submission, and approval
- [Payment System](docs/features/04-payment-system.md) - Payment methods, submission, and FIFO application
- [Notification System](docs/features/05-notification-system.md) - Push, email, and in-app notifications

### 🎨 User Interface
- [Authentication Screens](docs/ui-ux/01-authentication.md) - Login, signup, password reset
- [User Screens](docs/ui-ux/02-user-screens.md) - Home, reports, deed breakdown, payments, excuses
- [Supervisor Screens](docs/ui-ux/03-supervisor-screens.md) - User reports, leaderboard, analytics
- [Cashier Screens](docs/ui-ux/04-cashier-screens.md) - Payment review and balance management
- [Admin Screens](docs/ui-ux/05-admin-screens.md) - User management, system settings, content management

### 🗄️ Database & Backend
- [Database Schema](docs/database/01-schema.md) - Complete table definitions and relationships
- [Business Logic](docs/database/02-business-logic.md) - Calculations and core algorithms
- [API Endpoints](docs/database/03-api-endpoints.md) - REST API specification

### 🛠️ Technical Documentation
- [Architecture](docs/technical/01-architecture.md) - System architecture and design patterns
- [Authentication & Security](docs/technical/02-authentication.md) - Security implementation
- [State Management](docs/technical/03-state-management.md) - Flutter state management approach
- [Offline Support](docs/technical/04-offline-support.md) - Offline-first capabilities
- [Testing Strategy](docs/technical/05-testing.md) - Unit, integration, and E2E testing
- [Deployment & Hosting](docs/technical/06-deployment.md) - Infrastructure and CI/CD
- [Maintenance & Support](docs/technical/07-maintenance.md) - Ongoing maintenance procedures

### 📦 Additional Resources
- [Edge Cases & Error Handling](docs/technical/08-edge-cases.md) - Comprehensive edge case handling
- [Future Enhancements](docs/planning/04-future-enhancements.md) - Post-MVP feature roadmap
- [Implementation Checklist](docs/planning/05-checklist.md) - Pre-development checklist

## Quick Statistics

- **User Roles:** 4 (User, Supervisor, Cashier, Admin)
- **Database Tables:** 24
- **Default Daily Deeds:** 10 (5 Fara'id, 5 Sunnah)
- **Notification Types:** 17+
- **UI Screens:** 30+
- **API Endpoints:** 50+

## Key Business Rules

| Rule | Value |
|------|-------|
| Daily Deed Target | 10 deeds (configurable) |
| Penalty per Deed | 5,000 shillings |
| Penalty per 0.1 Deed | 500 shillings |
| Grace Period | 12 hours (12 PM next day) |
| Training Period | 30 days (New members, no penalties) |
| Auto-Deactivation Threshold | 500,000 shillings |
| Payment Application | FIFO (oldest penalties first) |

## Database Tables Summary

<details>
<summary>View all 24 tables</summary>

1. `users` - User accounts and profiles
2. `deed_templates` - Configurable deed definitions
3. `deeds_reports` - Daily deed submissions
4. `deed_entries` - Individual deed values per report
5. `penalties` - Penalty records
6. `payments` - Payment submissions
7. `penalty_payments` - Links payments to penalties (FIFO)
8. `excuses` - Excuse requests
9. `rest_days` - System-wide rest days
10. `settings` - System configuration
11. `notification_templates` - Configurable notification templates
12. `notification_schedules` - Scheduled notification rules
13. `notifications_log` - Notification history
14. `audit_logs` - System audit trail
15. `password_reset_tokens` - Password reset tokens
16. `user_sessions` - Active user sessions
17. `user_statistics` - Aggregated user metrics
18. `leaderboard` - Rankings by period
19. `payment_methods` - Configurable payment options
20. `special_tags` - Achievement badges
21. `user_tags` - User achievement assignments
22. `app_content` - CMS for rules and policies
23. `announcements` - System announcements
24. `user_announcement_dismissals` - Dismissed announcements tracking

</details>

## Development Workflow

### Getting Started

1. Review the [Project Overview](docs/planning/01-project-overview.md)
2. Understand [User Roles & Permissions](docs/planning/02-user-roles.md)
3. Study the [Database Schema](docs/database/01-schema.md)
4. Review the [API Endpoints](docs/database/03-api-endpoints.md)
5. Check the [Implementation Checklist](docs/planning/05-checklist.md)

### Implementation Order

1. **Database Setup** → Create Supabase project and run migrations
2. **Authentication** → Implement auth system with role-based access
3. **Core Report System** → Build deed reporting functionality
4. **Penalty Calculation** → Implement automated penalty logic
5. **Payment System** → Build payment submission and approval
6. **Admin Dashboard** → Create management interfaces
7. **Notifications** → Implement push and email notifications
8. **Testing** → Comprehensive testing at all levels
9. **Beta Launch** → Limited user testing
10. **Production Launch** → Full release

## Technology Requirements

### Development Tools
- Flutter SDK (latest stable)
- Dart 3.0+
- Android Studio / VS Code
- Xcode (for iOS development)
- Git

### Third-Party Services
- Supabase account
- Firebase account (for FCM)
- Mailgun account
- Apple Developer account (for iOS)
- Google Play Developer account (for Android)

## Environment Configuration

```bash
# Development
SUPABASE_URL=https://dev-project.supabase.co
SUPABASE_ANON_KEY=dev_anon_key
MAILGUN_API_KEY=dev_mailgun_key
FCM_SERVER_KEY=dev_fcm_key
APP_ENV=development

# Production
SUPABASE_URL=https://prod-project.supabase.co
SUPABASE_ANON_KEY=prod_anon_key
MAILGUN_API_KEY=prod_mailgun_key
FCM_SERVER_KEY=prod_fcm_key
APP_ENV=production
```

## Support & Contact

- **Documentation Issues:** Create an issue in the repository
- **Technical Questions:** Refer to relevant documentation sections
- **Feature Requests:** See [Future Enhancements](docs/planning/04-future-enhancements.md)

## License

[Specify License]

---

**Status:** Documentation Complete - Ready for Implementation

Last Updated: 2025-10-22
