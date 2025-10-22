# Application Overview

## Purpose
Track daily Islamic good deeds with financial accountability system

## Tech Stack

### Frontend
- **Framework:** Flutter
- **Platforms:** iOS & Android
- **Export Formats:** PDF & Excel

### Backend
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth
- **File Storage:** Supabase Storage

### Services
- **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Email Service:** Mailgun (configurable by admin)

## Core Concept

### Daily Deed Tracking
- Users track **10 daily deeds** with customizable targets
- System includes **5 Fara'id (obligatory)** and **5 Sunnah (recommended)** deeds
- Admin can add/modify deed templates

### Financial Accountability
- **Missing deeds incur financial penalties**
  - 5,000 shillings per full deed missed
  - 500 shillings per 0.1 deed missed
  - Penalties accumulate until paid

### Grace Period
- Grace period until **12 PM next day** (configurable)
- Reports can be submitted after the day ends until grace period expires
- Penalties calculated automatically after grace period

### User Management
- **Admin approval system** for new user registrations
- **Multiple user roles** with distinct permissions:
  - Normal User
  - Supervisor
  - Cashier
  - Admin

### Membership Tiers
- **New Member (0-30 days):** Training period, no penalties
- **Exclusive Member (1 month - 3 years):** Standard membership
- **Legacy Member (3+ years):** Long-term member recognition

## Key Features

### 1. Deed System
- Binary deeds (0 or 1)
- Fractional deeds (0.0 to 1.0 in 0.1 increments)
- Draft and submit workflow
- Category breakdown (Fara'id vs Sunnah)

### 2. Penalty System
- Automatic calculation based on missed deeds
- Cumulative balance tracking
- Auto-deactivation at 500,000 shillings threshold
- Warning notifications at configurable thresholds

### 3. Excuse System
- Three excuse types: Sickness, Travel, Raining
- Specify which deeds need excuse
- Supervisor/Admin approval workflow
- Retroactive excuse submission

### 4. Payment System
- Multiple payment methods (ZAAD, eDahab, configurable)
- Full or partial payment options
- FIFO application (oldest penalties paid first)
- Admin/Cashier approval workflow

### 5. Notification System
- Push notifications (FCM)
- Email notifications (Mailgun)
- In-app notification center
- Configurable templates and schedules
- 17+ notification types

### 6. Analytics & Reporting
- Individual user statistics
- System-wide analytics dashboard
- Leaderboard (daily/weekly/monthly/all-time)
- Special achievement tags
- Export to PDF/Excel

### 7. Offline Support
- Draft saving offline
- Auto-sync when connection restored
- Offline-first architecture

## Application Goals

### User Goals
- Build consistent daily good deed habits
- Track spiritual progress over time
- Stay accountable through financial commitment
- Compete positively with community members

### Admin Goals
- Monitor community engagement and compliance
- Manage financial accountability system
- Review and approve exceptions
- Generate insights and reports

### System Goals
- Provide reliable, scalable infrastructure
- Ensure data integrity and security
- Maintain audit trail for all actions
- Support offline-first mobile experience

## Success Metrics

### Engagement Metrics
- Daily Active Users (DAU)
- Report submission rate
- Average deeds per user
- Notification engagement rate

### Financial Metrics
- Total penalties incurred
- Total payments received
- Outstanding balance trend
- Payment approval time

### Compliance Metrics
- Overall compliance rate (users meeting daily target)
- Fara'id compliance rate
- Sunnah compliance rate
- Individual deed completion rates

### System Metrics
- Response time (< 500ms target)
- Uptime (99.9% target)
- Error rate
- Notification delivery rate

## Target Audience

### Primary Users
- Practicing Muslims committed to tracking daily good deeds
- Community members seeking spiritual accountability
- Users comfortable with mobile apps and digital payments

### Geographic Focus
- Initial focus: Somalia/Somaliland region (indicated by currency: shillings)
- Language: English (with future plans for Somali and Arabic)

### Technical Requirements
- Smartphone with iOS or Android
- Internet connection (with offline support)
- Mobile money account for payments (ZAAD/eDahab)

## System Requirements

### For Users
- iOS 12+ or Android 6.0+
- 100MB storage space
- Internet connection (intermittent OK)
- Push notification support

### For Admins
- Same as users, plus:
- Larger screen device recommended for dashboard
- Stable internet connection
- Email access for notifications

## Development Approach

### Phased Implementation
1. **Phase 1 - Core MVP**
   - User authentication and approval
   - Daily deed reporting
   - Penalty calculation
   - Basic notifications

2. **Phase 2 - Financial System**
   - Payment submission and approval
   - FIFO payment application
   - Balance management

3. **Phase 3 - Enhanced Features**
   - Excuse system
   - Leaderboard and achievements
   - Analytics dashboard

4. **Phase 4 - Polish & Scale**
   - Performance optimization
   - Advanced notifications
   - Admin tools enhancement

### Technology Choices

#### Why Flutter?
- Cross-platform (iOS & Android) from single codebase
- High performance
- Rich UI components
- Strong offline support
- Good state management options

#### Why Supabase?
- PostgreSQL database (robust, scalable)
- Built-in authentication
- Real-time capabilities
- File storage included
- Easy to use API
- Open source

#### Why FCM?
- Industry standard for push notifications
- Reliable delivery
- Free tier sufficient for MVP
- Well-documented

#### Why Mailgun?
- Reliable email delivery
- Reasonable pricing
- Easy API integration
- Delivery analytics

## Risk Considerations

### Technical Risks
- **Database performance** with large datasets → Mitigate with proper indexing
- **Notification delivery** failures → Implement retry logic and logging
- **Offline sync** conflicts → Use last-write-wins with conflict flagging

### Business Risks
- **User adoption** resistance → Beta testing and user feedback
- **Payment verification** challenges → Manual review process initially
- **Penalty accumulation** leading to user churn → Warning system and grace periods

### Security Risks
- **Unauthorized access** → Role-based access control, JWT tokens
- **Data breaches** → Encryption at rest and in transit
- **Payment fraud** → Manual approval process, audit logging

## Future Considerations

See [Future Enhancements](04-future-enhancements.md) for detailed post-MVP feature roadmap.

Key areas for expansion:
- Mobile money API integration for automatic payment verification
- Social features (groups, sharing, challenges)
- Multi-language support (Somali, Arabic)
- Web dashboard for advanced admin features
- Custom deed categories per user
- Prayer time integration

---

[← Back to Main README](../../README.md) | [Next: User Roles & Permissions →](02-user-roles.md)
