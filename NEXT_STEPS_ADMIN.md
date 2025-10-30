# Next Steps: Complete Admin Implementation

## Current Status
✅ Payment dropdown issue - FIXED
✅ Domain layer (entities & repository interface) - COMPLETE
⏳ Data layer - TODO
⏳ Presentation layer - TODO
⏳ Integration - TODO

## Quick Implementation Steps

### Phase 1: Data Layer (Priority: HIGH)

The data layer needs to be implemented. Based on the existing patterns in `features/penalties` and `features/payments`, here's what needs to be created:

#### Files to Create:
1. `lib/features/admin/data/models/` - 6 model files
2. `lib/features/admin/data/datasources/admin_remote_datasource.dart`
3. `lib/features/admin/data/repositories/admin_repository_impl.dart`

**Refer to**: `ADMIN_SYSTEM_IMPLEMENTATION.md` for complete code templates

### Phase 2: Presentation - BLoC (Priority: HIGH)

#### Files to Create:
1. `lib/features/admin/presentation/bloc/admin_event.dart` - 15+ events
2. `lib/features/admin/presentation/bloc/admin_state.dart` - 15+ states
3. `lib/features/admin/presentation/bloc/admin_bloc.dart` - Event handlers

### Phase 3: Presentation - UI (Priority: MEDIUM)

#### Main Pages to Create (8 pages):
1. **user_management_page.dart** - Multi-tab dashboard (Pending/Active/Suspended/Deactivated)
2. **user_edit_page.dart** - Edit user details, change role/status
3. **system_settings_page.dart** - Multi-tab settings (General/Payment/Notifications)
4. **deed_management_page.dart** - List/add/edit/reorder deed templates
5. **analytics_dashboard_page.dart** - Comprehensive metrics & statistics
6. **audit_log_page.dart** - Filterable audit trail
7. **notification_management_page.dart** - Edit notification templates
8. **rest_days_management_page.dart** - Calendar view of rest days

#### Widgets to Create:
- `user_card.dart` - User list item with actions
- `user_stats_card.dart` - Statistics display
- `settings_section.dart` - Settings group widget
- `deed_template_card.dart` - Deed item with drag handle
- `analytics_metric_card.dart` - Metric display card
- `audit_log_entry.dart` - Log entry with expandable details

### Phase 4: Integration (Priority: HIGH)

#### 1. Update Dependency Injection
File: `lib/core/di/injection.dart`

Add:
```dart
// Admin datasources
final adminRemoteDataSource = AdminRemoteDataSource(supabaseClient);

// Admin repository
final adminRepository = AdminRepositoryImpl(adminRemoteDataSource);

// Admin BLoC
final adminBloc = AdminBloc(adminRepository);
```

#### 2. Update App Router
File: `lib/core/navigation/app_router.dart`

Add routes:
```dart
GoRoute(
  path: '/admin/users',
  builder: (context, state) => const UserManagementPage(),
),
GoRoute(
  path: '/admin/user-edit/:id',
  builder: (context, state) => UserEditPage(userId: state.pathParameters['id']!),
),
GoRoute(
  path: '/admin/settings',
  builder: (context, state) => const SystemSettingsPage(),
),
// ... add remaining 5 routes
```

#### 3. Update Home Page
Replace placeholder navigation with real routes:
- User Management: `/admin/users`
- Analytics: `/admin/analytics`
- Settings: `/admin/settings`
- Audit Log: `/admin/audit-log`

### Phase 5: Code Generation & Testing

#### Run Build Runner:
```bash
cd sabiquun_app
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Fix Compilation Errors:
```bash
flutter analyze
```

#### Test the App:
```bash
flutter run
```

## Simplified Implementation Strategy

### Option 1: Implement Incrementally (Recommended)
1. Start with **User Management** only
   - Create models for UserManagementEntity
   - Create datasource methods for user operations
   - Create BLoC events/states for user management
   - Create user_management_page.dart
   - Test thoroughly

2. Then add **Analytics Dashboard**
   - Models for AnalyticsEntity
   - Datasource for analytics
   - BLoC for analytics
   - analytics_dashboard_page.dart

3. Then add **System Settings**
4. Finally add remaining features

### Option 2: Minimal Viable Admin (MVP)
Create a single unified admin page with:
- User list with basic actions (approve/reject/suspend)
- Simple analytics cards showing key metrics
- Basic settings form
- Skip audit logs, notifications, rest days for now

### Option 3: Use Detailed Guide
Follow `ADMIN_SYSTEM_IMPLEMENTATION.md` step-by-step with all code examples provided.

## Database Permissions Check

Before implementing, verify these Supabase tables exist and have proper RLS policies for admin role:
- ✅ `users`
- ✅ `settings`
- ✅ `deed_templates`
- ✅ `audit_logs`
- ✅ `notification_templates`
- ✅ `rest_days`

## Key Implementation Notes

### 1. Follow Existing Patterns
Use these as templates:
- `lib/features/penalties/` - Complete reference
- `lib/features/payments/` - Another complete example
- `lib/features/deeds/` - Deed-specific patterns

### 2. Model Creation Pattern
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/your_entity.dart';

part 'your_model.freezed.dart';
part 'your_model.g.dart';

@freezed
class YourModel with _$YourModel {
  const factory YourModel({
    required String id,
    // ... fields
  }) = _YourModel;

  factory YourModel.fromJson(Map<String, dynamic> json) =>
      _$YourModelFromJson(json);
}

extension YourModelX on YourModel {
  YourEntity toEntity() {
    return YourEntity(
      id: id,
      // ... map fields
    );
  }
}
```

### 3. Datasource Pattern
```dart
class AdminRemoteDataSource {
  final SupabaseClient _supabase;

  AdminRemoteDataSource(this._supabase);

  Future<List<UserManagementModel>> getUsers({String? accountStatus}) async {
    try {
      var query = _supabase.from('users').select('''
        *,
        user_statistics(*),
        penalties(amount, paid_amount, status)
      ''');

      if (accountStatus != null) {
        query = query.eq('account_status', accountStatus);
      }

      final response = await query;
      // ... process response
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }
}
```

### 4. BLoC Pattern
```dart
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc(this._repository) : super(const AdminInitial()) {
    on<LoadUsersRequested>(_onLoadUsers);
    on<ApproveUserRequested>(_onApproveUser);
    // ... register handlers
  }

  Future<void> _onLoadUsers(
    LoadUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final users = await _repository.getUsers(
        accountStatus: event.accountStatus,
      );
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}
```

### 5. Page Pattern
```dart
class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadUsersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            return _buildUsersList(state.users);
          } else if (state is AdminError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

## Testing Checklist

- [ ] Can load users list
- [ ] Can approve pending user
- [ ] Can reject pending user
- [ ] Can edit user details
- [ ] Can change user role
- [ ] Can suspend user
- [ ] Analytics dashboard loads
- [ ] Settings can be viewed
- [ ] Settings can be updated
- [ ] All navigation works
- [ ] Error states handled
- [ ] Loading states shown
- [ ] Confirmation dialogs work
- [ ] Audit logs created

## Time Estimates

- **Minimal MVP (Option 2)**: 4-6 hours
- **User Management Only (Option 1, Step 1)**: 6-8 hours
- **Full Implementation (Option 1 or 3)**: 20-25 hours

## Resources

- **Detailed Guide**: `ADMIN_SYSTEM_IMPLEMENTATION.md` (600+ lines with code examples)
- **UI Documentation**: `docs/ui-ux/05-admin-screens.md` (complete UI specs)
- **Domain Layer**: `lib/features/admin/domain/` (✅ COMPLETE)
- **Existing Patterns**: `lib/features/penalties/`, `lib/features/payments/`

---

**Status**: Ready to implement data + presentation layers
**Priority**: User Management > Analytics > Settings > Others
**Approach**: Recommend Option 1 (incremental) for production quality

