# System Architecture & Design Patterns

## Overview

The Good Deeds Tracking App follows a modern, scalable architecture designed for reliability, maintainability, and performance. This document outlines the system architecture, design patterns, and technical decisions.

---

## Technology Stack

### Frontend
- **Framework**: Flutter (Dart)
- **Platform Support**: iOS and Android
- **State Management**: Provider/Riverpod (recommended)
- **Local Storage**: SQLite/Hive for offline capabilities
- **HTTP Client**: Dio or http package
- **Navigation**: Flutter Navigator 2.0

### Backend
- **Database**: PostgreSQL (Supabase-hosted)
- **Authentication**: Supabase Auth (JWT-based)
- **File Storage**: Supabase Storage
- **Edge Functions**: Supabase Edge Functions (Deno runtime)
- **Real-time**: Supabase Realtime (WebSocket)

### Third-Party Services
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Email Service**: Mailgun (configurable)
- **Analytics**: Supabase Analytics or Firebase Analytics

---

## System Architecture

### Three-Tier Architecture

The application follows a classic three-tier architecture:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│      (Flutter Mobile App - UI)          │
│   - Widgets, Screens, Forms             │
│   - State Management (Provider)         │
│   - Local Caching (SQLite/Hive)         │
└─────────────────────────────────────────┘
              ↓ ↑ HTTPS/REST API
┌─────────────────────────────────────────┐
│         Business Logic Layer            │
│    (Supabase Backend + Edge Functions)  │
│   - Authentication & Authorization      │
│   - Business Rules & Validation         │
│   - Data Processing & Calculations      │
│   - Notification Management             │
└─────────────────────────────────────────┘
              ↓ ↑ SQL Queries
┌─────────────────────────────────────────┐
│           Data Layer                    │
│      (PostgreSQL Database)              │
│   - Data Persistence                    │
│   - Database Triggers                   │
│   - Constraints & Indexes               │
│   - Audit Logging                       │
└─────────────────────────────────────────┘
```

---

## Flutter App Architecture

### Layered Architecture Pattern

The Flutter app is structured in three main layers:

#### 1. **Presentation Layer** (UI)
Handles user interface and user interactions.

```
lib/
├── screens/              # Full-page screens
│   ├── home/
│   ├── reports/
│   ├── payments/
│   └── profile/
├── widgets/              # Reusable UI components
│   ├── common/
│   ├── reports/
│   └── payments/
└── theme/                # App theming and styling
```

#### 2. **Business Logic Layer**
Manages application state and business logic.

```
lib/
├── providers/            # State management (Provider/Riverpod)
│   ├── auth_provider.dart
│   ├── report_provider.dart
│   ├── payment_provider.dart
│   └── settings_provider.dart
├── models/               # Data models (DTOs)
│   ├── user.dart
│   ├── deed_report.dart
│   ├── penalty.dart
│   └── payment.dart
└── services/             # Business logic services
    ├── auth_service.dart
    ├── report_service.dart
    ├── penalty_service.dart
    └── notification_service.dart
```

#### 3. **Data Layer**
Handles data access and persistence.

```
lib/
├── repositories/         # Data repositories
│   ├── user_repository.dart
│   ├── report_repository.dart
│   ├── payment_repository.dart
│   └── settings_repository.dart
├── api/                  # API clients
│   ├── supabase_client.dart
│   ├── api_endpoints.dart
│   └── api_interceptors.dart
└── local_storage/        # Offline storage
    ├── database_helper.dart
    ├── hive_boxes.dart
    └── cache_manager.dart
```

---

## Design Patterns

### 1. **Repository Pattern**

Abstracts data sources (API, local database) from business logic.

```dart
// Abstract repository interface
abstract class ReportRepository {
  Future<List<DeedReport>> getUserReports(String userId);
  Future<DeedReport> createReport(DeedReport report);
  Future<void> updateReport(DeedReport report);
  Future<void> deleteReport(String reportId);
}

// Implementation
class ReportRepositoryImpl implements ReportRepository {
  final SupabaseClient _supabase;
  final LocalDatabase _localDb;

  ReportRepositoryImpl(this._supabase, this._localDb);

  @override
  Future<List<DeedReport>> getUserReports(String userId) async {
    try {
      // Try fetching from API
      final response = await _supabase
          .from('deeds_reports')
          .select()
          .eq('user_id', userId);

      // Cache locally
      await _localDb.cacheReports(response);
      return response.map((e) => DeedReport.fromJson(e)).toList();
    } catch (e) {
      // Fallback to local cache
      return await _localDb.getReports(userId);
    }
  }
}
```

### 2. **Provider Pattern** (State Management)

Manages application state and notifies listeners of changes.

```dart
class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;

  List<DeedReport> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<DeedReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReports(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getUserReports(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitReport(DeedReport report) async {
    await _repository.createReport(report);
    await loadReports(report.userId);
  }
}
```

### 3. **Singleton Pattern**

Ensures single instances of critical services.

```dart
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient client;

  factory SupabaseService() => _instance;

  SupabaseService._internal() {
    client = SupabaseClient(
      'your-supabase-url',
      'your-anon-key',
    );
  }
}
```

### 4. **Factory Pattern**

Creates objects without specifying their exact classes.

```dart
class NotificationFactory {
  static BaseNotification createNotification(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'penalty':
        return PenaltyNotification.fromJson(data);
      case 'payment':
        return PaymentNotification.fromJson(data);
      case 'excuse':
        return ExcuseNotification.fromJson(data);
      case 'reminder':
        return ReminderNotification.fromJson(data);
      default:
        return GenericNotification.fromJson(data);
    }
  }
}
```

### 5. **Observer Pattern**

Used extensively through Flutter's ChangeNotifier and Stream patterns.

```dart
class PenaltyService {
  final StreamController<PenaltyUpdate> _penaltyController =
      StreamController<PenaltyUpdate>.broadcast();

  Stream<PenaltyUpdate> get penaltyStream => _penaltyController.stream;

  void notifyPenaltyUpdate(PenaltyUpdate update) {
    _penaltyController.add(update);
  }

  void dispose() {
    _penaltyController.close();
  }
}
```

---

## Backend Architecture (Supabase)

### Database-First Approach

The backend leverages PostgreSQL's advanced features:

#### Database Triggers
Automated business logic at the database level:

```sql
-- Auto-calculate total deeds when entries are added/updated
CREATE OR REPLACE FUNCTION calculate_report_totals()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE deeds_reports
  SET
    total_deeds = (
      SELECT COALESCE(SUM(deed_value), 0)
      FROM deed_entries
      WHERE report_id = NEW.report_id
    ),
    sunnah_count = (
      SELECT COALESCE(SUM(de.deed_value), 0)
      FROM deed_entries de
      JOIN deed_templates dt ON de.deed_template_id = dt.id
      WHERE de.report_id = NEW.report_id AND dt.category = 'sunnah'
    ),
    faraid_count = (
      SELECT COALESCE(SUM(de.deed_value), 0)
      FROM deed_entries de
      JOIN deed_templates dt ON de.deed_template_id = dt.id
      WHERE de.report_id = NEW.report_id AND dt.category = 'faraid'
    )
  WHERE id = NEW.report_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_report_totals
AFTER INSERT OR UPDATE OR DELETE ON deed_entries
FOR EACH ROW EXECUTE FUNCTION calculate_report_totals();
```

#### Row Level Security (RLS)
Fine-grained access control:

```sql
-- Users can only view their own reports
CREATE POLICY user_view_own_reports ON deeds_reports
  FOR SELECT
  USING (auth.uid() = user_id);

-- Supervisors and Admins can view all reports
CREATE POLICY supervisor_view_all_reports ON deeds_reports
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('supervisor', 'admin')
    )
  );
```

### Edge Functions
Serverless functions for complex operations:

```typescript
// Supabase Edge Function: Calculate Daily Penalties
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // Get all users who didn't submit yesterday's report
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)

  const { data: users } = await supabaseClient
    .from('users')
    .select('id, membership_status, excuse_mode')
    .eq('account_status', 'active')

  // Calculate penalties for each user
  for (const user of users) {
    if (user.membership_status === 'new' || user.excuse_mode) {
      continue // Skip new members and users in excuse mode
    }

    // Check if report exists
    const { data: report } = await supabaseClient
      .from('deeds_reports')
      .select('*')
      .eq('user_id', user.id)
      .eq('report_date', yesterday.toISOString().split('T')[0])
      .single()

    if (!report) {
      // Create penalty
      const penaltyAmount = 10 * 5000 // 10 deeds * 5000 per deed
      await supabaseClient.from('penalties').insert({
        user_id: user.id,
        amount: penaltyAmount,
        date_incurred: yesterday.toISOString().split('T')[0],
        status: 'unpaid'
      })
    } else if (report.total_deeds < 10) {
      // Partial penalty
      const missedDeeds = 10 - report.total_deeds
      const penaltyAmount = missedDeeds * 5000
      await supabaseClient.from('penalties').insert({
        user_id: user.id,
        report_id: report.id,
        amount: penaltyAmount,
        date_incurred: yesterday.toISOString().split('T')[0],
        status: 'unpaid'
      })
    }
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

---

## Folder Structure

### Complete Project Structure

```
sabiquun_app/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── app.dart                   # App configuration
│   │
│   ├── core/                      # Core utilities
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   ├── app_constants.dart
│   │   │   └── color_constants.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── validation_utils.dart
│   │   │   └── formatting_utils.dart
│   │   └── network/
│   │       ├── network_info.dart
│   │       └── connectivity_checker.dart
│   │
│   ├── features/                  # Feature modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── data_sources/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── use_cases/
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       ├── screens/
│   │   │       └── widgets/
│   │   │
│   │   ├── reports/
│   │   ├── payments/
│   │   ├── excuses/
│   │   ├── analytics/
│   │   └── admin/
│   │
│   ├── shared/                    # Shared across features
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   │
│   └── config/                    # App configuration
│       ├── routes/
│       ├── themes/
│       └── env/
│
├── test/                          # Unit tests
├── integration_test/              # Integration tests
├── assets/                        # Static assets
│   ├── images/
│   ├── fonts/
│   └── icons/
│
├── android/                       # Android-specific code
├── ios/                           # iOS-specific code
│
└── pubspec.yaml                   # Dependencies
```

---

## Dependency Management

### Key Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.5
  # OR
  riverpod: ^2.3.0
  flutter_riverpod: ^2.3.0

  # Backend & Auth
  supabase_flutter: ^1.10.0

  # Local Storage
  sqflite: ^2.2.8
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.1.0

  # Networking
  dio: ^5.1.2
  connectivity_plus: ^4.0.1

  # Push Notifications
  firebase_core: ^2.10.0
  firebase_messaging: ^14.4.1

  # UI Components
  flutter_svg: ^2.0.5
  cached_network_image: ^3.2.3
  shimmer: ^3.0.0

  # Forms & Validation
  flutter_form_builder: ^9.0.0
  form_builder_validators: ^9.0.0

  # Date & Time
  intl: ^0.18.1
  timeago: ^3.5.0

  # PDF & Excel Export
  pdf: ^3.10.4
  excel: ^4.0.0

  # Charts
  fl_chart: ^0.62.0

  # Utils
  uuid: ^3.0.7
  logger: ^1.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.5
  flutter_lints: ^2.0.1
```

---

## Communication Flow

### API Request Flow

```
User Action (e.g., Submit Report)
        ↓
UI Widget calls Provider method
        ↓
Provider validates input
        ↓
Provider calls Repository method
        ↓
Repository checks connectivity
        ↓
    ┌─────────┴─────────┐
    ↓                   ↓
Online              Offline
    ↓                   ↓
API Request         Save to Local DB
    ↓                   ↓
Supabase            Queue for Sync
    ↓                   ↓
Database            Return Draft
    ↓
Return Response
    ↓
Update Local Cache
    ↓
Provider updates state
    ↓
UI rebuilds with new data
```

---

## Performance Considerations

### Optimizations

1. **Database Indexing**
   - All foreign keys indexed
   - Commonly queried fields indexed
   - Composite indexes for multi-column queries

2. **API Response Caching**
   - Cache frequently accessed data (deed templates, settings)
   - TTL-based cache invalidation
   - Aggressive caching for offline support

3. **Lazy Loading**
   - Paginate large lists (reports, payments)
   - Load data on demand
   - Implement infinite scroll

4. **Image Optimization**
   - Compress profile photos before upload
   - Use cached_network_image for efficient loading
   - Generate thumbnails for large images

5. **Code Splitting**
   - Feature-based modules
   - Lazy load routes
   - Minimize initial bundle size

---

## Security Architecture

### Defense in Depth

Multiple layers of security:

1. **Network Layer**: HTTPS only, certificate pinning
2. **Application Layer**: Input validation, XSS prevention
3. **Authentication Layer**: JWT tokens, refresh tokens
4. **Authorization Layer**: Role-based access control (RBAC)
5. **Database Layer**: Row-level security, parameterized queries
6. **Storage Layer**: Encrypted local storage, secure key management

---

## Scalability Considerations

### Horizontal Scaling

- **Database**: Supabase handles database scaling
- **Edge Functions**: Auto-scale based on demand
- **Client-side**: Stateless API design enables easy scaling

### Vertical Scaling

- **Database**: Upgrade PostgreSQL instance
- **Storage**: Supabase storage scales automatically
- **Caching**: Implement Redis for session management (future)

---

## Navigation

- [Previous: Project Overview](../project-overview.md)
- [Next: Authentication & Security](./02-authentication.md)
- [Back to Documentation Index](../README.md)
