# Flutter State Management

## Overview

State management is crucial for building responsive, maintainable Flutter applications. This document outlines the recommended state management approach for the Good Deeds Tracking App, covering global state, local state, form management, and caching strategies.

---

## Recommended Approach: Provider (or Riverpod)

### Why Provider?

- **Official recommendation** by the Flutter team
- **Simple and intuitive** API
- **Good performance** with minimal boilerplate
- **Excellent for medium to large apps**
- **Strong community support**
- **Easy to test** and maintain

### Alternative: Riverpod

Riverpod is the evolution of Provider with additional benefits:
- **Compile-safe** (catches errors at compile time)
- **No BuildContext dependency**
- **Better testability**
- **More flexible dependency injection**

Both approaches are valid. Choose based on team familiarity and project requirements.

---

## State Categories

### 1. Global State

Application-wide state that persists across screens:

- User authentication state
- User profile data
- App settings and configuration
- Current membership status
- Penalty balance

### 2. Local State

Screen or widget-specific state:

- Form input values
- UI toggles (dropdowns, modals)
- Loading indicators
- Validation errors
- Tab selections

### 3. Cached State

Data fetched from API and cached locally:

- Deed templates
- User reports (historical)
- Payment history
- Notification list
- Settings configuration

---

## Provider Implementation

### Setup

#### Dependencies (pubspec.yaml)

```yaml
dependencies:
  provider: ^6.0.5
  flutter:
    sdk: flutter
```

#### App Setup (main.dart)

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Global providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),

        // Feature-specific providers
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ExcuseProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        // Proxy providers (depend on other providers)
        ProxyProvider<AuthProvider, ReportProvider>(
          update: (context, auth, previous) =>
              ReportProvider(auth: auth, reportRepository: ReportRepository()),
        ),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## State Providers

### 1. AuthProvider (Authentication State)

```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _storage;

  User? _currentUser;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _status == AuthStatus.authenticated;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isSupervisor => _currentUser?.role == UserRole.supervisor;

  AuthProvider(this._authService, this._storage) {
    _checkAuthStatus();
  }

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      try {
        _currentUser = await _authService.getCurrentUser();
        _status = AuthStatus.authenticated;
      } catch (e) {
        _status = AuthStatus.unauthenticated;
        await _storage.deleteAll();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _currentUser = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile(User updatedUser) async {
    _currentUser = updatedUser;
    notifyListeners();
  }
}

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}
```

### 2. ReportProvider (Deed Reports State)

```dart
class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;

  List<DeedReport> _reports = [];
  DeedReport? _currentDraft;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DeedReport> get reports => _reports;
  DeedReport? get currentDraft => _currentDraft;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReportProvider(this._repository);

  // Load user reports
  Future<void> loadReports(String userId, {bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getUserReports(userId, forceRefresh: forceRefresh);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load or create draft for specific date
  Future<void> loadDraft(String userId, DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentDraft = await _repository.getDraftForDate(userId, date);
      if (_currentDraft == null) {
        // Create new draft
        _currentDraft = DeedReport(
          userId: userId,
          reportDate: date,
          status: ReportStatus.draft,
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update draft deed value
  void updateDeedValue(String deedTemplateId, double value) {
    if (_currentDraft == null) return;

    _currentDraft = _currentDraft!.copyWith(
      deedEntries: {
        ..._currentDraft!.deedEntries,
        deedTemplateId: value,
      },
    );

    // Auto-save draft locally
    _saveDraftLocally();
    notifyListeners();
  }

  // Save draft locally (offline support)
  Future<void> _saveDraftLocally() async {
    if (_currentDraft != null) {
      await _repository.saveDraftLocally(_currentDraft!);
    }
  }

  // Submit report
  Future<bool> submitReport() async {
    if (_currentDraft == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final submitted = await _repository.submitReport(_currentDraft!);
      _reports.insert(0, submitted);
      _currentDraft = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Delete draft
  Future<void> deleteDraft() async {
    if (_currentDraft != null) {
      await _repository.deleteDraft(_currentDraft!.id);
      _currentDraft = null;
      notifyListeners();
    }
  }

  // Calculate total deeds in current draft
  double get currentDraftTotal {
    if (_currentDraft == null) return 0.0;
    return _currentDraft!.deedEntries.values.fold(0.0, (sum, value) => sum + value);
  }
}
```

### 3. PaymentProvider (Payment State)

```dart
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  List<Payment> _payments = [];
  double _currentBalance = 0.0;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Payment> get payments => _payments;
  double get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PaymentProvider(this._repository);

  // Load user payments and balance
  Future<void> loadPayments(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getUserPaymentsWithBalance(userId);
      _payments = data['payments'];
      _currentBalance = data['balance'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit payment
  Future<bool> submitPayment({
    required double amount,
    required String paymentMethod,
    required PaymentType paymentType,
    String? referenceNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final payment = await _repository.submitPayment(
        amount: amount,
        paymentMethod: paymentMethod,
        paymentType: paymentType,
        referenceNumber: referenceNumber,
      );

      _payments.insert(0, payment);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Filter payments by status
  List<Payment> getPaymentsByStatus(PaymentStatus status) {
    return _payments.where((p) => p.status == status).toList();
  }
}
```

### 4. NotificationProvider

```dart
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider(this._repository) {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount--;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();
  }
}
```

---

## Form State Management

### Using Flutter Form Builder

```dart
class ReportFormScreen extends StatefulWidget {
  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Binary deed (checkbox)
          FormBuilderCheckbox(
            name: 'fajr_prayer',
            title: Text('Fajr Prayer'),
            onChanged: (value) {
              reportProvider.updateDeedValue(
                'fajr_prayer_id',
                value == true ? 1.0 : 0.0,
              );
            },
          ),

          // Fractional deed (slider)
          FormBuilderSlider(
            name: 'sunnah_prayers',
            min: 0.0,
            max: 1.0,
            divisions: 10,
            decoration: InputDecoration(labelText: 'Sunnah Prayers'),
            onChanged: (value) {
              reportProvider.updateDeedValue('sunnah_prayers_id', value ?? 0.0);
            },
          ),

          // Total display
          Consumer<ReportProvider>(
            builder: (context, provider, child) {
              return Text(
                'Total Deeds: ${provider.currentDraftTotal.toStringAsFixed(1)} / 10',
                style: Theme.of(context).textTheme.headline6,
              );
            },
          ),

          // Submit button
          ElevatedButton(
            onPressed: reportProvider.isLoading
                ? null
                : () async {
                    if (_formKey.currentState?.saveAndValidate() ?? false) {
                      final success = await reportProvider.submitReport();
                      if (success) {
                        Navigator.pop(context);
                      }
                    }
                  },
            child: reportProvider.isLoading
                ? CircularProgressIndicator()
                : Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
```

---

## Caching Strategy

### Cache Levels

1. **Memory Cache** (Provider state)
   - Short-lived data
   - Cleared on app restart
   - Fast access

2. **Persistent Cache** (Local database)
   - Long-lived data
   - Survives app restarts
   - Offline support

3. **API Cache** (Backend)
   - Server-side caching
   - Reduces database load

### Cache Implementation

```dart
class CacheManager {
  final LocalDatabase _localDb;
  final Map<String, CachedData> _memoryCache = {};

  // Get data with cache
  Future<T> getCachedData<T>({
    required String key,
    required Future<T> Function() fetchFunction,
    Duration ttl = const Duration(minutes: 5),
  }) async {
    // Check memory cache first
    final memoryData = _memoryCache[key];
    if (memoryData != null && !memoryData.isExpired) {
      return memoryData.data as T;
    }

    // Check persistent cache
    final persistentData = await _localDb.getCachedData(key);
    if (persistentData != null) {
      final cacheAge = DateTime.now().difference(persistentData.timestamp);
      if (cacheAge < ttl) {
        // Cache valid, update memory cache and return
        _memoryCache[key] = CachedData(
          data: persistentData.data,
          timestamp: persistentData.timestamp,
          ttl: ttl,
        );
        return persistentData.data as T;
      }
    }

    // Cache miss or expired, fetch fresh data
    final freshData = await fetchFunction();

    // Update both caches
    _memoryCache[key] = CachedData(
      data: freshData,
      timestamp: DateTime.now(),
      ttl: ttl,
    );
    await _localDb.setCachedData(key, freshData);

    return freshData;
  }

  // Clear specific cache
  Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    await _localDb.deleteCachedData(key);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    _memoryCache.clear();
    await _localDb.deleteAllCachedData();
  }
}

class CachedData {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;

  CachedData({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}
```

### Usage Example

```dart
class DeedTemplateProvider extends ChangeNotifier {
  final DeedTemplateRepository _repository;
  final CacheManager _cacheManager;

  List<DeedTemplate> _templates = [];

  Future<void> loadDeedTemplates({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await _cacheManager.clearCache('deed_templates');
    }

    _templates = await _cacheManager.getCachedData(
      key: 'deed_templates',
      fetchFunction: () => _repository.getDeedTemplates(),
      ttl: Duration(hours: 24), // Cache for 24 hours
    );

    notifyListeners();
  }
}
```

---

## State Persistence

### Saving State Across App Restarts

```dart
class PersistentStateProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _darkMode = false;
  String _selectedLanguage = 'en';

  bool get darkMode => _darkMode;
  String get selectedLanguage => _selectedLanguage;

  PersistentStateProvider(this._prefs) {
    _loadState();
  }

  Future<void> _loadState() async {
    _darkMode = _prefs.getBool('dark_mode') ?? false;
    _selectedLanguage = _prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await _prefs.setBool('dark_mode', _darkMode);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    await _prefs.setString('language', language);
    notifyListeners();
  }
}
```

---

## Advanced: Riverpod Alternative

### Basic Riverpod Setup

```dart
// Providers (global scope)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read);
});

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.read);
});

// StateNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Reader read;

  AuthNotifier(this.read) : super(AuthState.initial());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await read(authServiceProvider).login(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    await read(authServiceProvider).logout();
    state = AuthState.unauthenticated();
  }
}

// Usage in widgets
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return DashboardScreen();
    } else {
      return LoginScreen();
    }
  }
}
```

---

## Best Practices

1. **Separate UI from Business Logic**
   - Keep providers focused on state management
   - Move complex logic to services/repositories

2. **Use Immutable State**
   - Use `copyWith()` for state updates
   - Prevents accidental state mutations

3. **Dispose Resources**
   - Implement `dispose()` in providers
   - Cancel streams and timers

4. **Optimize Rebuilds**
   - Use `Selector` or `Consumer` for specific updates
   - Avoid unnecessary `notifyListeners()` calls

5. **Test Providers**
   - Providers should be easily testable
   - Mock repositories for unit testing

6. **Handle Loading States**
   - Always show loading indicators
   - Provide feedback for long operations

7. **Error Handling**
   - Catch and store errors in state
   - Display user-friendly error messages

---

## Performance Tips

### 1. Selective Rebuilds

```dart
// Bad: Rebuilds entire widget tree
Consumer<ReportProvider>(
  builder: (context, provider, child) {
    return ComplexWidget(provider);
  },
);

// Good: Only rebuilds when specific value changes
Selector<ReportProvider, int>(
  selector: (context, provider) => provider.reports.length,
  builder: (context, reportCount, child) {
    return Text('Reports: $reportCount');
  },
);
```

### 2. Lazy Initialization

```dart
// Don't load all data on app start
// Load data when needed
class ReportProvider extends ChangeNotifier {
  List<DeedReport>? _reports; // Nullable

  Future<void> ensureReportsLoaded(String userId) async {
    if (_reports == null) {
      await loadReports(userId);
    }
  }
}
```

### 3. Debouncing Updates

```dart
class SearchProvider extends ChangeNotifier {
  Timer? _debounceTimer;
  String _query = '';

  void updateQuery(String query) {
    _query = query;
    _debounceTimer?.cancel();

    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      _performSearch(_query);
    });
  }

  Future<void> _performSearch(String query) async {
    // Perform search
    notifyListeners();
  }
}
```

---

## Navigation

- [Previous: Authentication & Security](./02-authentication.md)
- [Next: Offline Support](./04-offline-support.md)
- [Back to Documentation Index](../README.md)
