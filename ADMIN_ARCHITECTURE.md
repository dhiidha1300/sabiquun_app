# Admin System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        ADMIN SYSTEM                              │
│                     (Clean Architecture)                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌───────────────┐   ┌───────────────┐   ┌──────────────────┐  │
│  │   UI Pages    │   │    Widgets    │   │    AdminBloc     │  │
│  │   (8 pages)   │◄──┤  (Reusable)   │◄──┤   (State Mgmt)   │  │
│  │               │   │               │   │                  │  │
│  │ • User Mgmt   │   │ • UserCard    │   │ • Events (15+)   │  │
│  │ • Settings    │   │ • StatsCard   │   │ • States (15+)   │  │
│  │ • Analytics   │   │ • MetricCard  │   │ • Handlers       │  │
│  │ • Audit Log   │   │ • LogEntry    │   │                  │  │
│  └───────────────┘   └───────────────┘   └──────────────────┘  │
│                                                     │             │
└─────────────────────────────────────────────────────┼─────────────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────┐   ┌──────────────────────────┐   │
│  │       Entities           │   │  Repository Interface    │   │
│  │    (Pure Dart)           │   │    (Abstract Contract)   │   │
│  │                          │   │                          │   │
│  │ • UserManagementEntity   │   │ • getUsers()             │   │
│  │ • SystemSettingsEntity   │   │ • approveUser()          │   │
│  │ • AuditLogEntity         │   │ • getSystemSettings()    │   │
│  │ • NotificationTemplate   │   │ • updateSettings()       │   │
│  │ • RestDayEntity          │   │ • getAnalytics()         │   │
│  │ • AnalyticsEntity        │   │ • getAuditLogs()         │   │
│  └──────────────────────────┘   └──────────────────────────┘   │
│                                                     │             │
└─────────────────────────────────────────────────────┼─────────────┘
                                                      │
                                                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────┐   ┌────────────────────────────────┐ │
│  │   Repository Impl    │◄──┤  Remote DataSource (Supabase)  │ │
│  │                      │   │                                │ │
│  │ • Maps models to     │   │ • getUsers()                   │ │
│  │   entities           │   │ • approveUser()                │ │
│  │ • Handles errors     │   │ • rejectUser()                 │ │
│  │ • Calls datasource   │   │ • updateUser()                 │ │
│  └──────────────────────┘   │ • getSystemSettings()          │ │
│                              │ • updateSettings()             │ │
│  ┌──────────────────────┐   │ • getAnalytics()               │ │
│  │   Data Models        │   │ • getAuditLogs()               │ │
│  │   (Freezed + JSON)   │   │ • _logAuditTrail()            │ │
│  │                      │   └────────────────────────────────┘ │
│  │ • UserManagementModel│                                       │
│  │ • SystemSettingsModel│                                       │
│  │ • AuditLogModel      │                                       │
│  │ • ...                │                                       │
│  └──────────────────────┘                                       │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │    SUPABASE     │
                    │   (PostgreSQL)  │
                    │                 │
                    │ • users         │
                    │ • settings      │
                    │ • penalties     │
                    │ • audit_logs    │
                    │ • ...           │
                    └─────────────────┘
```

## Data Flow Diagrams

### User Approval Flow

```
┌──────────┐
│   User   │
│  Clicks  │
│ "Approve"│
└────┬─────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  UserManagementPage                     │
│  - Shows confirmation dialog            │
│  - Gets current admin ID                │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  context.read<AdminBloc>().add(         │
│    ApproveUserRequested(                │
│      userId: '...',                     │
│      approvedBy: '...'                  │
│    )                                    │
│  )                                      │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  AdminBloc._onApproveUserRequested()    │
│  - Emits AdminLoading                   │
│  - Calls repository.approveUser()       │
│  - Emits UserApproved or AdminError     │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  AdminRepositoryImpl.approveUser()      │
│  - Calls datasource.approveUser()       │
│  - Handles errors                       │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  AdminRemoteDataSource.approveUser()    │
│  1. Update user status in Supabase      │
│  2. Call _logAuditTrail()               │
│  3. Return success                      │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  Supabase                               │
│  UPDATE users                           │
│  SET account_status = 'active',         │
│      approved_by = '...',               │
│      approved_at = NOW()                │
│  WHERE id = '...'                       │
│                                         │
│  INSERT INTO audit_logs (...)           │
│  VALUES (...)                           │
└────┬────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────┐
│  UI Updates                             │
│  - BlocBuilder rebuilds                 │
│  - Shows success message                │
│  - Removes user from pending list       │
│  - (Optional) Triggers reload           │
└─────────────────────────────────────────┘
```

### Analytics Loading Flow

```
┌──────────────┐
│  Admin opens │
│  Analytics   │
│    Page      │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────┐
│  initState()                     │
│  - Dispatch LoadAnalyticsReq     │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  AdminBloc                       │
│  - Emit AdminLoading             │
│  - Call getAnalytics()           │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  AdminRemoteDataSource           │
│  - Execute multiple queries:     │
│    • User metrics query          │
│    • Deed metrics query          │
│    • Financial metrics query     │
│    • Engagement metrics query    │
│    • Excuse metrics query        │
│  - Combine results               │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Repository transforms to        │
│  AnalyticsEntity                 │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  Bloc emits AnalyticsLoaded      │
└──────┬───────────────────────────┘
       │
       ▼
┌──────────────────────────────────┐
│  UI displays:                    │
│  - User metrics cards            │
│  - Deed statistics               │
│  - Financial overview            │
│  - Engagement graphs             │
│  - Excuse statistics             │
└──────────────────────────────────┘
```

## Component Interactions

### BLoC State Management

```
┌─────────────────────────────────────────────────────────┐
│                      AdminBloc                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Events (User Actions)          States (UI Data)       │
│  ═══════════════════════════════════════════════════   │
│                                                         │
│  LoadUsersRequested        ──►  AdminLoading           │
│                            ──►  UsersLoaded            │
│                            ──►  AdminError             │
│                                                         │
│  ApproveUserRequested      ──►  AdminLoading           │
│                            ──►  UserApproved           │
│                            ──►  AdminError             │
│                                                         │
│  LoadAnalyticsRequested    ──►  AdminLoading           │
│                            ──►  AnalyticsLoaded        │
│                            ──►  AdminError             │
│                                                         │
│  UpdateSettingsRequested   ──►  AdminLoading           │
│                            ──►  SystemSettingsUpdated  │
│                            ──►  AdminError             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Dependency Injection Flow

```
┌─────────────────────────────────────────┐
│           main.dart                     │
│  - Calls Injection.init()               │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│       Injection.init()                  │
├─────────────────────────────────────────┤
│                                         │
│  1. Initialize Supabase Client          │
│     _supabase = await Supabase.init()   │
│                                         │
│  2. Create DataSources                  │
│     _adminRemoteDataSource =            │
│       AdminRemoteDataSource(_supabase)  │
│                                         │
│  3. Create Repositories                 │
│     _adminRepository =                  │
│       AdminRepositoryImpl(              │
│         _adminRemoteDataSource          │
│       )                                 │
│                                         │
│  4. Create Blocs                        │
│     _adminBloc =                        │
│       AdminBloc(_adminRepository)       │
│                                         │
└────────────────┬────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────┐
│      App Widgets Access via:            │
│   Injection.adminBloc                   │
│   Injection.adminRepository             │
│   etc.                                  │
└─────────────────────────────────────────┘
```

## Entity Relationships

```
┌──────────────────────┐
│ UserManagementEntity │
├──────────────────────┤
│ + id                 │
│ + email              │
│ + name               │
│ + role               │
│ + membershipStatus   │
│ + accountStatus      │
│ + totalReports       │◄─────┐
│ + complianceRate     │      │
│ + currentBalance     │◄───┐ │
└──────────────────────┘    │ │
                            │ │
┌──────────────────────┐    │ │
│   PenaltyEntity      │────┘ │
├──────────────────────┤      │
│ + userId             │      │
│ + amount             │      │
│ + paidAmount         │      │
│ + status             │      │
└──────────────────────┘      │
                              │
┌──────────────────────┐      │
│  DeedReportEntity    │──────┘
├──────────────────────┤
│ + userId             │
│ + reportDate         │
│ + totalDeeds         │
│ + status             │
└──────────────────────┘

┌──────────────────────┐
│  AuditLogEntity      │
├──────────────────────┤
│ + action             │
│ + performedBy        │───►  UserManagementEntity
│ + entityType         │
│ + entityId           │───►  Any Entity
│ + oldValue           │
│ + newValue           │
│ + reason             │
│ + timestamp          │
└──────────────────────┘

┌──────────────────────┐
│  AnalyticsEntity     │
├──────────────────────┤
│ + userMetrics        │───►  UserMetrics
│ + deedMetrics        │───►  DeedMetrics
│ + financialMetrics   │───►  FinancialMetrics
│ + engagementMetrics  │───►  EngagementMetrics
│ + excuseMetrics      │───►  ExcuseMetrics
└──────────────────────┘
```

## File Organization

```
features/admin/
│
├── domain/                         ✅ IMPLEMENTED
│   ├── entities/
│   │   ├── user_management_entity.dart
│   │   ├── system_settings_entity.dart
│   │   ├── audit_log_entity.dart
│   │   ├── notification_template_entity.dart
│   │   ├── rest_day_entity.dart
│   │   └── analytics_entity.dart
│   │
│   └── repositories/
│       └── admin_repository.dart
│
├── data/                           ⏳ TO IMPLEMENT
│   ├── models/
│   │   ├── user_management_model.dart
│   │   │   ├── .freezed.dart (generated)
│   │   │   └── .g.dart (generated)
│   │   ├── system_settings_model.dart
│   │   ├── audit_log_model.dart
│   │   ├── notification_template_model.dart
│   │   ├── rest_day_model.dart
│   │   └── analytics_model.dart
│   │
│   ├── datasources/
│   │   └── admin_remote_datasource.dart
│   │
│   └── repositories/
│       └── admin_repository_impl.dart
│
└── presentation/                   ⏳ TO IMPLEMENT
    ├── bloc/
    │   ├── admin_bloc.dart
    │   ├── admin_event.dart
    │   └── admin_state.dart
    │
    ├── pages/
    │   ├── user_management_page.dart
    │   ├── user_edit_page.dart
    │   ├── system_settings_page.dart
    │   ├── deed_management_page.dart
    │   ├── analytics_dashboard_page.dart
    │   ├── audit_log_page.dart
    │   ├── notification_management_page.dart
    │   └── rest_days_management_page.dart
    │
    └── widgets/
        ├── user_card.dart
        ├── user_stats_card.dart
        ├── settings_section.dart
        ├── deed_template_card.dart
        ├── analytics_metric_card.dart
        └── audit_log_entry.dart
```

## Cross-Feature Dependencies

```
                    ┌──────────────┐
                    │    Admin     │
                    │   Feature    │
                    └───────┬──────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│     Auth     │    │  Penalties   │    │   Payments   │
│   Feature    │    │   Feature    │    │   Feature    │
└──────┬───────┘    └──────┬───────┘    └──────┬───────┘
       │                   │                   │
       │ (Get admin user)  │ (Waive/Remove)   │ (View)
       │                   │                   │
       └───────────────────┴───────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   Supabase   │
                    │   Database   │
                    └──────────────┘
```

## State Transition Diagram

```
                    ┌─────────────┐
                    │   Initial   │
                    └──────┬──────┘
                           │
                 User dispatches event
                           │
                           ▼
                    ┌─────────────┐
              ┌─────┤   Loading   ├─────┐
              │     └─────────────┘     │
              │                         │
          Success                    Error
              │                         │
              ▼                         ▼
     ┌─────────────────┐        ┌─────────────┐
     │  Data Loaded    │        │    Error    │
     │  - UsersLoaded  │        │             │
     │  - Settings...  │        │  message    │
     │  - Analytics... │        │             │
     └─────────────────┘        └─────────────┘
              │                         │
              │                         │
              └──────────┬──────────────┘
                         │
                   User action
                         │
                         ▼
                 Back to Loading...
```

## Security Architecture

```
┌────────────────────────────────────────────────┐
│              Security Layers                   │
├────────────────────────────────────────────────┤
│                                                │
│  Layer 1: UI Permission Checks                 │
│  - Hide admin routes from non-admin users      │
│  - Disable action buttons based on role        │
│                                                │
│  Layer 2: BLoC Validation                      │
│  - Verify user role before processing          │
│  - Validate input data                         │
│                                                │
│  Layer 3: Repository Authorization             │
│  - Check permissions before data access        │
│  - Validate entity relationships               │
│                                                │
│  Layer 4: Supabase RLS Policies                │
│  - Row-level security on tables                │
│  - Function-based permission checks            │
│                                                │
│  Layer 5: Audit Logging                        │
│  - Log all admin actions                       │
│  - Track who, what, when, why                  │
│  - Immutable audit trail                       │
│                                                │
└────────────────────────────────────────────────┘
```

## Performance Optimization Strategy

```
┌────────────────────────────────────────────────┐
│          Performance Optimizations             │
├────────────────────────────────────────────────┤
│                                                │
│  1. Database Level                             │
│     • Indexed foreign keys                     │
│     • Composite indexes for queries            │
│     • Materialized views for analytics         │
│                                                │
│  2. API Level                                  │
│     • Pagination for large lists               │
│     • JOINs to reduce round trips              │
│     • Selective column fetching                │
│                                                │
│  3. Repository Level                           │
│     • Cache system settings                    │
│     • Cache deed templates                     │
│     • Debounce search queries                  │
│                                                │
│  4. BLoC Level                                 │
│     • Avoid unnecessary rebuilds               │
│     • Use const constructors                   │
│     • Stream subscriptions cleanup             │
│                                                │
│  5. UI Level                                   │
│     • Lazy load tabs                           │
│     • Virtual scrolling for lists              │
│     • Image caching                            │
│     • Skeleton loading states                  │
│                                                │
└────────────────────────────────────────────────┘
```

## Testing Architecture

```
┌────────────────────────────────────────────────┐
│              Testing Pyramid                   │
├────────────────────────────────────────────────┤
│                                                │
│                   ┌──────┐                     │
│                   │  E2E │  (Manual/Automated) │
│                   └──────┘                     │
│                  ┌────────┐                    │
│                  │ Widget │  (UI Components)   │
│                  └────────┘                    │
│               ┌──────────────┐                 │
│               │ Integration  │  (BLoC + Repo)  │
│               └──────────────┘                 │
│          ┌────────────────────────┐            │
│          │       Unit Tests       │            │
│          │  (Entities, Models,    │            │
│          │   Repositories, BLoC)  │            │
│          └────────────────────────┘            │
│                                                │
└────────────────────────────────────────────────┘

Unit Tests (Most)
  • Entity business logic
  • Model serialization
  • Repository methods
  • BLoC event handlers

Integration Tests (Moderate)
  • Complete user flows
  • State transitions
  • API interactions (mocked)

Widget Tests (Some)
  • Individual widgets
  • Page rendering
  • User interactions

E2E Tests (Few)
  • Critical paths
  • Complete workflows
  • Production scenarios
```

## Deployment Checklist

```
┌────────────────────────────────────────────────┐
│          Pre-Deployment Checklist              │
├────────────────────────────────────────────────┤
│                                                │
│  ✅ Code Quality                               │
│     □ No analyzer warnings                     │
│     □ All tests passing                        │
│     □ Code reviewed                            │
│     □ Documentation complete                   │
│                                                │
│  ✅ Database                                   │
│     □ Migrations applied                       │
│     □ Indexes created                          │
│     □ RLS policies configured                  │
│     □ Audit log table ready                    │
│                                                │
│  ✅ Security                                   │
│     □ Role checks implemented                  │
│     □ Audit logging functioning                │
│     □ Confirmation dialogs in place            │
│     □ Input validation working                 │
│                                                │
│  ✅ Performance                                │
│     □ Queries optimized                        │
│     □ Pagination implemented                   │
│     □ Caching configured                       │
│     □ Load testing done                        │
│                                                │
│  ✅ User Experience                            │
│     □ Loading states visible                   │
│     □ Error messages clear                     │
│     □ Success feedback shown                   │
│     □ Mobile responsive                        │
│                                                │
└────────────────────────────────────────────────┘
```

---

## Quick Reference

**Domain Layer:** Pure business logic, no dependencies
**Data Layer:** Supabase integration, JSON handling
**Presentation Layer:** UI and state management

**Key Pattern:** Entity ← Model ← Supabase
**State Flow:** Event → Bloc → State → UI

**Always Remember:**
1. Audit log every admin action
2. Confirm destructive operations
3. Validate all inputs
4. Handle all errors
5. Test thoroughly

---

*For implementation details, see `ADMIN_SYSTEM_IMPLEMENTATION.md`*
*For quick start, see `ADMIN_QUICK_START.md`*
