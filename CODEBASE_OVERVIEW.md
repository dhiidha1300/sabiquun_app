# Sabiquun App - Codebase Overview

## Project Summary

**Project Type:** Flutter Mobile Application (iOS & Android)
**Backend:** Supabase (PostgreSQL + Auth)
**Purpose:** Islamic Good Deeds Tracking with Financial Accountability System
**Architecture:** Clean Architecture with BLoC State Management
**Total Dart Files:** 34

---

## 1. PROJECT STRUCTURE

### Directory Layout
```
lib/
├── core/                    # Core functionality (global)
│   ├── config/             # Environment configuration
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error definitions
│   ├── navigation/         # Routing configuration
│   ├── theme/              # UI theme & colors
│   └── utils/              # Validation utilities
├── features/               # Feature modules
│   ├── auth/               # Authentication feature (implemented)
│   │   ├── data/           # Data layer (models, repositories, datasources)
│   │   ├── domain/         # Domain layer (entities, repositories interface)
│   │   └── presentation/   # Presentation layer (BLoC, pages)
│   └── home/               # Home/Dashboard feature (partial)
│       └── pages/
├── shared/                 # Shared components
│   ├── services/           # Shared services (permissions, storage)
│   └── widgets/            # Reusable UI widgets
└── main.dart              # App entry point
```

---

## 2. DEPENDENCIES & TECH STACK

### Key Dependencies
- **State Management:** `flutter_bloc: ^8.1.5`, `bloc: ^8.1.4`
- **Backend:** `supabase_flutter: ^2.5.0`
- **Navigation:** `go_router: ^14.2.0`
- **Security:** `flutter_secure_storage: ^9.2.2`, `jwt_decoder: ^2.0.1`
- **Networking:** `dio: ^5.4.3+1`
- **Data Processing:** `freezed_annotation: ^2.4.1`, `json_annotation: ^4.9.0`
- **Form Validation:** `formz: ^0.7.0`
- **UI:** `flutter_svg: ^2.0.10+1`, `cached_network_image: ^3.3.1`
- **Local Storage:** `shared_preferences: ^2.2.3`
- **Date/Time:** `intl: ^0.19.0`
- **Media:** `image_picker: ^1.1.2`

---

## 3. EXISTING DATABASE MODELS & SCHEMAS

### Core User System

**UserEntity** (Domain Layer)
```dart
- id: String
- email: String
- fullName: String
- phoneNumber: String?
- profilePhotoUrl: String?
- role: UserRole (enum)
- accountStatus: AccountStatus (enum)
- createdAt: DateTime?
- lastLoginAt: DateTime?
```

**UserModel** (Data Layer - freezed)
- Maps database fields: `name` → `fullName`, `phone` → `phoneNumber`, `photo_url` → `profilePhotoUrl`
- Includes `toEntity()` and `fromEntity()` conversion methods
- JSON serialization via `freezed` and `json_serializable`

### User Role System
```dart
enum UserRole {
  user('user', 'User'),
  supervisor('supervisor', 'Supervisor'),
  cashier('cashier', 'Cashier'),
  admin('admin', 'Admin')
}
```

Methods:
- `isElevated` - supervisor, cashier, admin have elevated privileges
- `isAdmin`, `isSupervisor`, `isCashier`, `isNormalUser` - role checks

### Account Status System
```dart
enum AccountStatus {
  pending('pending', 'Pending Approval'),
  active('active', 'Active'),
  suspended('suspended', 'Suspended'),
  autoDeactivated('auto_deactivated', 'Auto-Deactivated'),
  deleted('deleted', 'Deleted')
}
```

Methods:
- `canAccessApp` - only `active` status allows access

### Database Tables (From Schema)
The system uses 24 PostgreSQL tables:

**Core Tables:**
1. `users` - User accounts with role, membership status, account status
2. `deed_templates` - 10 configurable daily Islamic deeds
3. `deeds_reports` - Daily deed submission reports
4. `deed_entries` - Individual deed values within reports

**Financial Tables:**
5. `penalties` - Calculated financial penalties
6. `payments` - Payment submissions
7. `penalty_payments` - FIFO mapping of payments to penalties

**Management Tables:**
8. `excuses` - Excuse requests for missing deeds
9. `rest_days` - System-wide rest days calendar
10. `settings` - System configuration

**Communication Tables:**
11. `notification_templates` - Configurable notification templates
12. `notification_schedules` - Scheduled notifications
13. `notifications_log` - Notification history

**Analytics & Tracking:**
14. `audit_logs` - All privileged actions
15. `user_sessions` - Active user sessions
16. `user_statistics` - Aggregated user metrics
17. `leaderboard` - User rankings

**Content & Other:**
18. `special_tags` - Achievement badges
19. `user_tags` - User achievement assignments
20. `payment_methods` - Configurable payment options
21. `app_content` - CMS for rules/policies
22. `announcements` - System announcements
23. `user_announcement_dismissals` - Dismissal tracking
24. `password_reset_tokens` - Password reset tokens

---

## 4. AUTHENTICATION IMPLEMENTATION

### Architecture Pattern: Clean Architecture with BLoC

**Layers:**
1. **Data Layer** (`data/`)
   - `AuthRemoteDataSource` - Supabase API calls
   - `AuthRepositoryImpl` - Implements AuthRepository interface
   - `UserModel` - Data transfer object with JSON serialization

2. **Domain Layer** (`domain/`)
   - `AuthRepository` - Abstract interface
   - `UserEntity` - Domain model
   - `AuthResult` - Success/failure wrapper with error types

3. **Presentation Layer** (`presentation/`)
   - `AuthBloc` - State management
   - `AuthEvent` - User actions
   - `AuthState` - UI states
   - Auth Pages (LoginPage, SignUpPage, etc.)

### Authentication Events Handled
```dart
AuthCheckRequested        // On app startup
LoginRequested           // Email + password login
SignUpRequested          // User registration
LogoutRequested          // User logout
PasswordResetRequested   // Forgot password
PasswordUpdateRequested  // Password reset with token
TokenRefreshRequested    // Token refresh
ProfileUpdateRequested   // Update user profile
```

### Authentication States
```dart
AuthInitial              // Initial state
AuthLoading              // Processing auth request
Authenticated(user)      // Logged in with user data
Unauthenticated          // Not logged in
AuthError(message)       // Auth failed
AccountPendingApproval   // New account awaiting admin approval
PasswordResetEmailSent   // Password reset email sent
```

### Key Features
- **Supabase Integration:**
  - Uses `supabase_flutter` for auth and database
  - Email/password authentication
  - Secure token management
  - RPC function for user profile creation (bypasses RLS)

- **Session Management:**
  - Access token lifetime: 24 hours
  - Refresh token lifetime: 30 days
  - Secure storage via `flutter_secure_storage`
  - Token refresh buffer: 1 hour

- **Account Status Workflow:**
  - New users default to "pending" status
  - Cannot access app until admin approves
  - Shows "PendingApprovalPage" after signup
  - Supervisors and cashiers cannot approve users (admin only)

### Error Handling
```dart
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyInUse,
  weakPassword,
  accountPending,
  accountSuspended,
  accountDeactivated,
  networkError,
  serverError,
  tokenExpired,
  unknown,
}
```

---

## 5. ROLE-BASED ACCESS CONTROL (RBAC)

### PermissionService Implementation
Located in `shared/services/permission_service.dart`

**Core Structure:**
```dart
class PermissionService {
  final UserEntity? currentUser;
  UserRole? get currentRole => currentUser?.role;
  
  // Permission methods grouped by feature
}
```

### Permission Categories

**1. Report Permissions**
- `canSubmitReport()` - All authenticated users
- `canViewOwnReports()` - All authenticated users
- `canViewAllReports()` - Supervisor, Admin
- `canEditSubmittedReport()` - Admin only
- `canDeleteReport()` - Admin only

**2. Excuse Permissions**
- `canSubmitExcuse()` - All users
- `canApproveExcuse()` - Supervisor, Admin
- `canRejectExcuse()` - Supervisor, Admin

**3. Payment Permissions**
- `canSubmitPayment()` - All users
- `canViewOwnPayments()` - All users
- `canViewAllPayments()` - Cashier, Admin
- `canApprovePayment()` - Cashier, Admin
- `canRejectPayment()` - Cashier, Admin

**4. Penalty Permissions**
- `canViewOwnPenalties()` - All users
- `canViewAllPenalties()` - Cashier, Admin
- `canAdjustPenalties()` - Cashier, Admin
- `canWaivePenalties()` - Admin only

**5. User Management Permissions**
- `canApproveUsers()` - Admin only
- `canSuspendUsers()` - Admin only
- `canChangeUserRoles()` - Admin only
- `canDeleteUsers()` - Admin only
- `canViewUserList()` - Supervisor, Cashier, Admin

**6. Analytics Permissions**
- `canViewOwnAnalytics()` - All users
- `canViewUserAnalytics()` - Supervisor, Admin
- `canViewFinancialAnalytics()` - Cashier, Admin
- `canViewSystemAnalytics()` - Supervisor, Cashier, Admin

**7. Admin/System Settings Permissions**
- `canConfigureDeedTemplates()` - Admin
- `canConfigurePenalties()` - Admin
- `canManageRestDays()` - Admin
- `canManagePaymentMethods()` - Admin
- `canConfigureSystemSettings()` - Admin

**8. Utility Methods**
- `hasAnyRole(List<UserRole>)` - Check multiple roles
- `canAccessFeature(String)` - String-based feature access
- `hasElevatedPrivileges()` - Quick elevation check

### Role Hierarchy Matrix
| Feature | User | Supervisor | Cashier | Admin |
|---------|------|-----------|---------|-------|
| Submit Reports | ✅ | ✅ | ✅ | ✅ |
| View All Reports | ❌ | ✅ | ❌ | ✅ |
| View All Payments | ❌ | ❌ | ✅ | ✅ |
| Approve Users | ❌ | ❌ | ❌ | ✅ |
| System Settings | ❌ | ❌ | ❌ | ✅ |

---

## 6. UI STRUCTURE & NAVIGATION

### Router Configuration
Located in `core/navigation/app_router.dart`

**Navigation Using GoRouter:**
```dart
Routes:
/login              - LoginPage
/signup             - SignUpPage
/forgot-password    - ForgotPasswordPage
/reset-password     - ResetPasswordPage
/pending-approval   - PendingApprovalPage
/home               - HomePage
```

**Route Guard Logic:**
- Authenticated users redirected away from auth pages
- Pending approval users can only access `/pending-approval`
- Unauthenticated users redirected to `/login`
- Auth state changes trigger router refresh via `GoRouterRefreshStream`

### Existing Pages

**1. LoginPage (`features/auth/presentation/pages/login_page.dart`)**
- Email and password input
- "Remember me" checkbox
- Login error handling with SnackBar
- Validates input before submission
- Routes to `/home` on success or `/pending-approval` if pending

**2. PendingApprovalPage**
- Shows pending approval message
- Displays support email contact
- "View Rules & Policies" button (future feature)
- Logout button
- Support contact information

**3. HomePage (`features/home/pages/home_page.dart`)**
- Welcome message with user's full name
- User profile menu in AppBar with:
  - User name, email, role badge
  - Profile, Settings, Logout options
- Role-based feature cards in GridView:
  - "My Reports" (all users)
  - "Today's Deeds" (all users)
  - "Payments" (all users)
  - "Excuses" (all users)
  - "User Management" (admin only)
  - "Analytics" (supervisor+)
  - "Payment Review" (cashier+)

**4. Additional Auth Pages (Partial Implementation)**
- `signup_page.dart`
- `forgot_password_page.dart`
- `reset_password_page.dart`

### UI Themes & Colors

**Color Scheme** (`core/theme/app_colors.dart`):
- **Primary:** Islamic Green (#2E7D32)
- **Accent:** Orange (#FF9800)
- **Role Colors:**
  - Admin: Purple (#9C27B0)
  - Supervisor: Blue (#2196F3)
  - Cashier: Orange (#FF9800)
  - User: Green (#4CAF50)
- **Account Status Colors:**
  - Pending: Orange (#FFA726)
  - Active: Green (#4CAF50)
  - Suspended: Red (#E53935)
  - Deactivated: Grey (#9E9E9E)

### Reusable Widgets
Located in `shared/widgets/`:
- `CustomButton` - Styled action button
- `CustomTextField` - Form input field
- `CustomOutlinedButton` - Outline button variant
- `PasswordStrengthIndicator` - Password validation UI
- `LoadingOverlay` - Loading indicator overlay

---

## 7. STATE MANAGEMENT: BLoC Pattern

### Implementation Details
- **BLoC Library:** `flutter_bloc: ^8.1.5`
- **Pattern:** Event-driven state management
- **Injection:** Dependency injection in `core/di/injection.dart`
- **Equatable:** Used for state and event comparison

### BLoC Structure for Auth
```
AuthBloc
├── Receives: AuthEvent (abstract)
│   ├── AuthCheckRequested
│   ├── LoginRequested
│   ├── SignUpRequested
│   ├── LogoutRequested
│   ├── PasswordResetRequested
│   ├── PasswordUpdateRequested
│   ├── TokenRefreshRequested
│   └── ProfileUpdateRequested
├── Emits: AuthState (abstract)
│   ├── AuthInitial
│   ├── AuthLoading
│   ├── Authenticated(user)
│   ├── Unauthenticated
│   ├── AuthError(message)
│   ├── AccountPendingApproval(email)
│   └── PasswordResetEmailSent(email)
└── Handlers:
    ├── _onAuthCheckRequested()
    ├── _onLoginRequested()
    ├── _onSignUpRequested()
    ├── _onLogoutRequested()
    ├── _onPasswordResetRequested()
    ├── _onPasswordUpdateRequested()
    ├── _onTokenRefreshRequested()
    └── _onProfileUpdateRequested()
```

### Integration Pattern
```dart
// In main.dart
BlocProvider.value(
  value: Injection.authBloc,
  child: MaterialApp.router(
    routerConfig: AppRouter(context.read<AuthBloc>()).router,
  ),
)

// In pages
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is Authenticated) {
      // Show authenticated content
    }
  },
)

BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Authenticated) {
      context.go('/home');
    }
  },
)
```

---

## 8. DEPENDENCY INJECTION

### Setup Location
`core/di/injection.dart` - Simple service locator pattern

### Initialized Components
```dart
static Future<void> init() async {
  // 1. Validate environment configuration
  EnvConfig.validateConfig();
  
  // 2. Initialize Supabase
  _supabase = await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );
  
  // 3. Initialize Secure Storage
  _secureStorage = SecureStorageService.instance();
  
  // 4. Initialize Data Sources
  _authRemoteDataSource = AuthRemoteDataSource(_supabase);
  
  // 5. Initialize Repositories
  _authRepository = AuthRepositoryImpl(
    remoteDataSource: _authRemoteDataSource,
    storageService: _secureStorage,
  );
  
  // 6. Initialize BLoCs
  _authBloc = AuthBloc(authRepository: _authRepository);
}
```

### Accessor Methods
```dart
static SupabaseClient get supabase => _supabase;
static SecureStorageService get secureStorage => _secureStorage;
static AuthRepository get authRepository => _authRepository;
static AuthBloc get authBloc => _authBloc;
```

---

## 9. SERVICES LAYER

### SecureStorageService
```dart
- saveAccessToken(String)
- getAccessToken(): String?
- saveRefreshToken(String)
- getRefreshToken(): String?
- saveTokens(accessToken, refreshToken)
- deleteAccessToken()
- deleteRefreshToken()
- deleteAllTokens()
- hasTokens(): bool
- write(key, value)
- read(key): String?
- delete(key)
- containsKey(key): bool
```

### PermissionService
(See section 5 for detailed permissions)

---

## 10. ENVIRONMENT & CONFIGURATION

### Environment Setup
Located in `core/config/env_config.dart`

**Required .env variables:**
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Anonymous Supabase API key

**App Constants** (`core/constants/app_constants.dart`):
```dart
Token Lifetime:
- accessTokenLifetime: 24 hours
- refreshTokenLifetime: 30 days
- tokenRefreshBuffer: 1 hour

Password Requirements:
- minPasswordLength: 8
- maxPasswordLength: 128

Timeouts:
- apiTimeout: 30 seconds
- uploadTimeout: 5 minutes

Pagination:
- defaultPageSize: 20
- maxPageSize: 100
```

---

## 11. EXISTING DEED/REPORT FUNCTIONALITY

### Current Status
**Partially Implemented:**
- Home page shows deed-related feature cards
- PermissionService has report-related methods
- Database schema supports full deed functionality

### Deed Feature Card UI
```dart
_FeatureCard(
  icon: Icons.library_books,
  title: 'My Reports',
  color: AppColors.primary,
  onTap: () {},  // TODO: Implement
)

_FeatureCard(
  icon: Icons.event_note,
  title: 'Today\'s Deeds',
  color: AppColors.accent,
  onTap: () {},  // TODO: Implement
)
```

### Available Permissions (Not Yet Used)
```dart
canSubmitReport()
canViewOwnReports()
canViewAllReports()       // Supervisor, Admin
canEditSubmittedReport()  // Admin
canDeleteReport()         // Admin
```

### Database Support
The database schema fully supports deeds:
- 10 default deed templates (Fajr, Duha, Dhuhr, Juz of Quran, Asr, Sunnah Prayers, Maghrib, Isha, Athkar, Witr)
- Daily deed report submissions
- Deed entry tracking (individual values)
- Binary (0/1) and fractional (0.0-1.0) value types
- Category tracking (Fara'id and Sunnah)

---

## 12. SECURITY FEATURES

### Authentication Security
- **JWT Tokens:** Managed by Supabase Auth
- **Secure Storage:** Flutter Secure Storage with platform-specific encryption
  - Android: Encrypted SharedPreferences
  - iOS: Keychain (first_unlock accessibility)
- **Password Requirements:** Min 8 chars, max 128 chars
- **Token Refresh:** Automatic refresh before expiration (1 hour buffer)

### Access Control
- **Role-Based:** Enforced at both frontend and backend
- **Backend Validation:** API calls validated against user role
- **Frontend UI:** Features hidden based on permissions (but backend enforces)
- **Audit Logging:** All privileged actions logged (admin only)

### Account Protection
- **Account Status:** Pending → Active → Suspended/Auto-Deactivated
- **Account Approval:** Admin-only approval for new users
- **Session Management:** Active session tracking
- **Auto-Deactivation:** Triggered by penalty threshold

---

## 13. SUMMARY TABLE: WHAT'S IMPLEMENTED VS. PLANNED

| Component | Status | Details |
|-----------|--------|---------|
| **Authentication** | ✅ Complete | Login, signup, password reset, account approval |
| **Role System** | ✅ Complete | 4 roles with permission checking |
| **User Management** | ✅ Partial | UserEntity, UserModel, profile updates |
| **Deed System** | ⏳ Planned | UI in place, backend schema ready |
| **Penalty System** | ⏳ Planned | Schema ready, calculation logic needed |
| **Payment System** | ⏳ Planned | Schema ready, submission/approval flow needed |
| **Excuse System** | ⏳ Planned | Schema ready, approval flow needed |
| **Analytics/Reports** | ⏳ Planned | Permission structure ready |
| **Notifications** | ⏳ Planned | Schema ready, FCM integration needed |
| **Leaderboard** | ⏳ Planned | Schema ready, ranking logic needed |
| **Admin Dashboard** | ⏳ Planned | Permission structure ready |
| **Supervisor Dashboard** | ⏳ Planned | Permission structure ready |
| **Cashier Dashboard** | ⏳ Planned | Permission structure ready |

---

## 14. INTEGRATION POINTS FOR ROLE-BASED ACCESS

### Where to Add RBAC Enforcement
1. **Route Protection:** Already implemented via `GoRouter.redirect()` with auth checks
2. **UI Components:** Use `PermissionService` to conditionally show features
3. **API Calls:** Backend validates role via JWT claims
4. **Feature Screens:** Check permissions before showing UI elements
5. **Navigation:** Guard routes based on `authState.user.role`

### Example Pattern
```dart
// In HomePage
final permissions = PermissionService(user);

if (permissions.canViewAllReports()) {
  // Show supervisor analytics
}

if (permissions.canApprovePayment()) {
  // Show payment approval button
}
```

---

## 15. KEY FILES REFERENCE

### Essential Files for Understanding RBAC
1. `/lib/core/constants/user_role.dart` - Role enum
2. `/lib/shared/services/permission_service.dart` - All permission logic
3. `/lib/features/auth/domain/entities/user_entity.dart` - User with role
4. `/lib/core/navigation/app_router.dart` - Route guards
5. `/lib/features/home/pages/home_page.dart` - Role-based UI example

### Authentication Implementation
1. `/lib/features/auth/presentation/bloc/auth_bloc.dart` - State management
2. `/lib/features/auth/data/datasources/auth_remote_datasource.dart` - Supabase integration
3. `/lib/features/auth/data/repositories/auth_repository_impl.dart` - Business logic
4. `/lib/core/di/injection.dart` - Dependency setup

### Configuration
1. `/lib/core/config/env_config.dart` - Environment variables
2. `/lib/core/constants/app_constants.dart` - Global constants
3. `/lib/core/theme/app_colors.dart` - Color scheme
4. `/pubspec.yaml` - Dependencies

---

## RECOMMENDATIONS

### For Implementing Deed Reports
1. Create `features/deed` module with similar structure to `features/auth`
2. Implement `DeedReportBloc` for state management
3. Create data models: `DeedReportModel`, `DeedEntryModel`
4. Implement permission checks using `PermissionService`
5. Create dedicated UI screens for deed submission

### For Role-Based Access
1. Continue using `PermissionService` for all permission checks
2. Add `@RequireAuth` or `@RequireRole` annotations for pages
3. Implement middleware in data layer to pass JWT tokens
4. Add audit logging for all state changes

### For Future Features
1. Implement remaining RBAC-guarded features following the same pattern
2. Add comprehensive error handling for permission denied scenarios
3. Implement proper logging for security audits
4. Add analytics integration for feature usage

