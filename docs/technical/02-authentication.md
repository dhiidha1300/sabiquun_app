# Authentication & Security

## Overview

The Good Deeds Tracking App implements a robust authentication and security system using JWT tokens, role-based access control, and industry best practices. This document covers authentication flows, authorization mechanisms, and security implementations.

---

## Authentication System

### JWT Token Implementation

#### Token Structure

```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "role": "user",
  "account_status": "active",
  "iat": 1634567890,
  "exp": 1634654290
}
```

#### Token Types

1. **Access Token**
   - **Lifetime**: 24 hours
   - **Purpose**: API authentication
   - **Storage**: Memory (Flutter) / Secure Storage (persistent sessions)
   - **Transmission**: Bearer token in Authorization header

2. **Refresh Token**
   - **Lifetime**: 30 days
   - **Purpose**: Obtain new access tokens
   - **Storage**: Secure encrypted storage
   - **Rotation**: New refresh token issued on use

#### Token Flow

```
User Login
    ↓
Credentials sent to Supabase Auth
    ↓
Supabase validates credentials
    ↓
Generate Access Token (24h) & Refresh Token (30d)
    ↓
Client stores tokens securely
    ↓
Access Token used for API requests
    ↓
Before expiration (e.g., 1h remaining)
    ↓
Client sends Refresh Token
    ↓
Supabase issues new Access + Refresh tokens
    ↓
Old tokens invalidated
```

### Authentication Implementation

#### Flutter Client

```dart
class AuthService {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Store tokens securely
        await _secureStorage.write(
          key: 'access_token',
          value: response.session!.accessToken,
        );
        await _secureStorage.write(
          key: 'refresh_token',
          value: response.session!.refreshToken,
        );

        return AuthResponse.success(response.user!);
      }

      return AuthResponse.error('Login failed');
    } on AuthException catch (e) {
      return AuthResponse.error(e.message);
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _secureStorage.deleteAll();
  }

  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _supabase.auth.refreshSession();
      if (response.session != null) {
        await _secureStorage.write(
          key: 'access_token',
          value: response.session!.accessToken,
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
```

#### API Request Interceptor

```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final AuthService _authService;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        // Retry original request
        final options = err.requestOptions;
        final token = await _storage.read(key: 'access_token');
        options.headers['Authorization'] = 'Bearer $token';

        try {
          final response = await Dio().request(
            options.path,
            options: Options(
              method: options.method,
              headers: options.headers,
            ),
            data: options.data,
          );
          handler.resolve(response);
        } catch (e) {
          handler.reject(err);
        }
      } else {
        // Refresh failed, logout user
        await _authService.logout();
        handler.reject(err);
      }
    } else {
      handler.next(err);
    }
  }
}
```

---

## Role-Based Access Control (RBAC)

### User Roles

| Role | Description |
|------|-------------|
| **user** | Normal user with basic permissions |
| **supervisor** | Can view all reports, approve excuses, manage leaderboard |
| **cashier** | Can manage payments and adjust penalties |
| **admin** | Full system access and configuration |

### Permission Matrix

| Endpoint/Feature | User | Supervisor | Cashier | Admin |
|-----------------|------|------------|---------|-------|
| **Reports** |
| Submit Report | ✅ | ✅ | ✅ | ✅ |
| View Own Reports | ✅ | ✅ | ✅ | ✅ |
| View All Reports | ❌ | ✅ | ❌ | ✅ |
| Edit Own Draft | ✅ | ✅ | ✅ | ✅ |
| Edit Submitted Report | ❌ | ❌ | ❌ | ✅ |
| **Payments** |
| Submit Payment | ✅ | ✅ | ✅ | ✅ |
| View Own Payments | ✅ | ✅ | ✅ | ✅ |
| View All Payments | ❌ | ❌ | ✅ | ✅ |
| Approve Payment | ❌ | ❌ | ✅ | ✅ |
| Reject Payment | ❌ | ❌ | ✅ | ✅ |
| Adjust Balance Manually | ❌ | ❌ | ✅ | ✅ |
| **Excuses** |
| Submit Excuse | ✅ | ✅ | ✅ | ✅ |
| View Own Excuses | ✅ | ✅ | ✅ | ✅ |
| Approve Excuse | ❌ | ✅ | ❌ | ✅ |
| Reject Excuse | ❌ | ✅ | ❌ | ✅ |
| **User Management** |
| Manage Users | ❌ | ❌ | ❌ | ✅ |
| Approve Registration | ❌ | ❌ | ❌ | ✅ |
| Suspend/Reactivate Users | ❌ | ❌ | ❌ | ✅ |
| Change User Roles | ❌ | ❌ | ❌ | ✅ |
| **System Configuration** |
| Edit Deed Templates | ❌ | ❌ | ❌ | ✅ |
| Manage Settings | ❌ | ❌ | ❌ | ✅ |
| Manage Rest Days | ❌ | ❌ | ❌ | ✅ |
| Configure Notifications | ❌ | ❌ | ❌ | ✅ |
| **Analytics** |
| View Own Analytics | ✅ | ✅ | ✅ | ✅ |
| View All Analytics | ❌ | ✅ | ❌ | ✅ |
| View Payment Analytics | ❌ | ❌ | ✅ | ✅ |
| View Audit Logs | ❌ | ❌ | ❌ | ✅ |
| **Notifications** |
| Send Manual Notification | ❌ | ✅ | ❌ | ✅ |

### Authorization Implementation

#### Backend (Supabase Row Level Security)

```sql
-- Example: Users can only view their own reports
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

-- Only users with 'cashier' or 'admin' role can approve payments
CREATE POLICY cashier_approve_payments ON payments
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role IN ('cashier', 'admin')
    )
  );

-- Only admins can delete users
CREATE POLICY admin_delete_users ON users
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE id = auth.uid()
      AND role = 'admin'
    )
  );
```

#### Flutter Client

```dart
class PermissionService {
  final UserRole _currentUserRole;

  bool canViewAllReports() {
    return _currentUserRole == UserRole.supervisor ||
           _currentUserRole == UserRole.admin;
  }

  bool canApprovePayment() {
    return _currentUserRole == UserRole.cashier ||
           _currentUserRole == UserRole.admin;
  }

  bool canApproveExcuse() {
    return _currentUserRole == UserRole.supervisor ||
           _currentUserRole == UserRole.admin;
  }

  bool canManageUsers() {
    return _currentUserRole == UserRole.admin;
  }

  bool canEditSubmittedReport() {
    return _currentUserRole == UserRole.admin;
  }

  bool canConfigureSystem() {
    return _currentUserRole == UserRole.admin;
  }
}

// Usage in UI
Widget build(BuildContext context) {
  final permissionService = context.read<PermissionService>();

  return Scaffold(
    body: Column(
      children: [
        if (permissionService.canViewAllReports())
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/all-reports'),
            child: Text('View All Reports'),
          ),
        if (permissionService.canManageUsers())
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/user-management'),
            child: Text('Manage Users'),
          ),
      ],
    ),
  );
}
```

---

## Session Management

### Session Lifecycle

```
1. User Login
   ↓
2. Session Created (24h access token, 30d refresh token)
   ↓
3. Session Active
   ↓
4a. User Activity → Extend Session (via token refresh)
   ↓
4b. User Inactive → Session Expires → Logout
   ↓
5. User Logout → Session Destroyed
```

### Session Storage

```dart
class SessionManager {
  final FlutterSecureStorage _storage;
  Timer? _refreshTimer;

  Future<void> startSession(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);

    // Schedule token refresh before expiration
    _scheduleTokenRefresh();
  }

  void _scheduleTokenRefresh() {
    // Refresh 1 hour before expiration
    const refreshInterval = Duration(hours: 23);
    _refreshTimer = Timer(refreshInterval, () async {
      await _refreshToken();
    });
  }

  Future<void> endSession() async {
    _refreshTimer?.cancel();
    await _storage.deleteAll();
  }

  Future<bool> isSessionValid() async {
    final accessToken = await _storage.read(key: 'access_token');
    if (accessToken == null) return false;

    // Decode JWT and check expiration
    try {
      final jwt = JwtDecoder.decode(accessToken);
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(
        jwt['exp'] * 1000,
      );
      return DateTime.now().isBefore(expirationDate);
    } catch (e) {
      return false;
    }
  }
}
```

---

## Password Security

### Password Requirements

- **Minimum Length**: 8 characters
- **Complexity**: Must contain:
  - At least 1 uppercase letter (A-Z)
  - At least 1 lowercase letter (a-z)
  - At least 1 number (0-9)
  - At least 1 special character (optional but recommended)

### Password Hashing

```dart
// Backend (Supabase handles this automatically with bcrypt)
// Cost factor: 12 (recommended for security vs performance balance)
```

### Password Validation (Frontend)

```dart
class PasswordValidator {
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // Valid
  }

  static double getPasswordStrength(String password) {
    double strength = 0;

    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.1;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.1;

    return strength.clamp(0.0, 1.0);
  }
}
```

### Password Reset Flow

```
User requests password reset
    ↓
POST /api/auth/forgot-password { email }
    ↓
Server generates reset token (1-hour expiration)
    ↓
Email sent with reset link containing token
    ↓
User clicks link → Redirected to app with token
    ↓
User enters new password
    ↓
POST /api/auth/reset-password { token, new_password }
    ↓
Server validates token & updates password
    ↓
User logged in automatically or redirected to login
```

---

## API Authentication

### Request Authentication

All API requests (except auth endpoints) must include:

```http
Authorization: Bearer <access_token>
```

### Authentication Flow

```dart
class ApiClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<Response> get(String path) async {
    final token = await _storage.read(key: 'access_token');

    return await _dio.get(
      path,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  }

  Future<Response> post(String path, dynamic data) async {
    final token = await _storage.read(key: 'access_token');

    return await _dio.post(
      path,
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
```

---

## Security Best Practices

### 1. Secure Storage

```dart
// Use FlutterSecureStorage for sensitive data
final storage = FlutterSecureStorage();

// Store tokens
await storage.write(key: 'access_token', value: token);

// Read tokens
final token = await storage.read(key: 'access_token');

// Delete tokens on logout
await storage.delete(key: 'access_token');
await storage.deleteAll();
```

### 2. HTTPS Only

```dart
// Enforce HTTPS in API client
class ApiConstants {
  static const String baseUrl = 'https://your-project.supabase.co';

  // Never use HTTP in production
  static bool get isSecure => baseUrl.startsWith('https://');
}
```

### 3. Certificate Pinning (Advanced)

```dart
class CertificatePinner {
  static Dio createDioWithPinning() {
    final dio = Dio();

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          // Implement certificate validation
          return _validateCertificate(cert, host);
        };
        return client;
      },
    );

    return dio;
  }

  static bool _validateCertificate(X509Certificate cert, String host) {
    // Verify certificate SHA-256 fingerprint
    const expectedFingerprint = 'YOUR_CERT_FINGERPRINT';
    final certFingerprint = sha256.convert(cert.der).toString();
    return certFingerprint == expectedFingerprint;
  }
}
```

### 4. Input Sanitization

```dart
class InputSanitizer {
  static String sanitizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  static String sanitizeString(String input) {
    // Remove potential XSS characters
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  static String sanitizePhoneNumber(String phone) {
    // Remove all non-numeric characters
    return phone.replaceAll(RegExp(r'\D'), '');
  }
}
```

### 5. Rate Limiting

Implement client-side request throttling:

```dart
class RateLimiter {
  final Map<String, List<DateTime>> _requestHistory = {};
  final int maxRequests;
  final Duration timeWindow;

  RateLimiter({
    this.maxRequests = 100,
    this.timeWindow = const Duration(minutes: 1),
  });

  Future<bool> allowRequest(String endpoint) async {
    final now = DateTime.now();
    final history = _requestHistory[endpoint] ?? [];

    // Remove requests outside time window
    history.removeWhere((time) => now.difference(time) > timeWindow);

    if (history.length >= maxRequests) {
      return false; // Rate limit exceeded
    }

    history.add(now);
    _requestHistory[endpoint] = history;
    return true;
  }
}

// Usage
final rateLimiter = RateLimiter(maxRequests: 10, timeWindow: Duration(minutes: 1));

Future<void> submitPayment() async {
  if (!await rateLimiter.allowRequest('/api/payments')) {
    throw Exception('Too many requests. Please try again later.');
  }

  // Proceed with payment submission
}
```

### 6. Secure Local Database

```dart
// Encrypt sensitive data in local database
class SecureDatabase {
  final EncryptedSembast _database;

  Future<void> initialize() async {
    final encryptionKey = await _getEncryptionKey();
    _database = await EncryptedSembast.open(
      'secure_app_data.db',
      encryptionKey: encryptionKey,
    );
  }

  Future<String> _getEncryptionKey() async {
    final storage = FlutterSecureStorage();
    var key = await storage.read(key: 'db_encryption_key');

    if (key == null) {
      // Generate new encryption key
      key = _generateSecureKey();
      await storage.write(key: 'db_encryption_key', value: key);
    }

    return key;
  }

  String _generateSecureKey() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
```

### 7. Audit Logging

Log all sensitive operations:

```dart
class AuditLogger {
  final SupabaseClient _supabase;

  Future<void> logAction({
    required String action,
    required String entityType,
    required String entityId,
    String? oldValue,
    String? newValue,
    String? reason,
  }) async {
    await _supabase.from('audit_logs').insert({
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'old_value': oldValue,
      'new_value': newValue,
      'reason': reason,
      'performed_at': DateTime.now().toIso8601String(),
    });
  }
}

// Usage
await auditLogger.logAction(
  action: 'Penalty Waived',
  entityType: 'Penalty',
  entityId: penaltyId,
  oldValue: 'unpaid: 5000',
  newValue: 'waived: 0',
  reason: 'User was sick',
);
```

---

## Security Checklist

- [ ] All passwords hashed with bcrypt (cost factor 12)
- [ ] JWT tokens with appropriate expiration times
- [ ] Refresh token rotation implemented
- [ ] Secure storage for tokens (FlutterSecureStorage)
- [ ] HTTPS enforced for all API calls
- [ ] Row-level security (RLS) enabled on all tables
- [ ] Input validation on both client and server
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (input sanitization)
- [ ] Rate limiting implemented
- [ ] Sensitive operations logged in audit trail
- [ ] Certificate pinning for production (optional)
- [ ] Encrypted local database for sensitive data
- [ ] Secure session management
- [ ] Proper error messages (no sensitive info leaked)

---

## Common Security Pitfalls to Avoid

1. **Storing tokens in SharedPreferences** → Use FlutterSecureStorage
2. **Not validating input on server** → Always validate server-side
3. **Exposing sensitive data in logs** → Sanitize logs
4. **Using HTTP in production** → Enforce HTTPS
5. **Not implementing token refresh** → Leads to poor UX
6. **Weak password requirements** → Enforce strong passwords
7. **Not implementing RLS** → Direct database access risks
8. **Storing sensitive data unencrypted** → Encrypt local data

---

## Navigation

- [Previous: System Architecture](./01-architecture.md)
- [Next: State Management](./03-state-management.md)
- [Back to Documentation Index](../README.md)
