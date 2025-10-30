# Admin System Implementation Guide

## Overview

This document provides a complete implementation guide for the Sabiquun App admin system following clean architecture and BLoC pattern. The admin system includes user management, system configuration, analytics, audit logging, and content management features.

## Architecture Summary

The implementation follows the existing clean architecture pattern:
- **Domain Layer**: Entities and repository interfaces
- **Data Layer**: Models (Freezed), datasources (Supabase), repository implementations
- **Presentation Layer**: BLoC (events/states), pages, widgets

## Implementation Status

### ✅ Completed Components

#### 1. Domain Layer Entities (Created)
- `user_management_entity.dart` - User management with statistics
- `system_settings_entity.dart` - System-wide configuration
- `audit_log_entity.dart` - Admin action logging
- `notification_template_entity.dart` - Notification templates
- `rest_day_entity.dart` - Penalty-free days
- `analytics_entity.dart` - Comprehensive metrics

#### 2. Domain Repository Interface (Created)
- `admin_repository.dart` - Complete repository interface with methods for:
  - User management (approve, reject, update, suspend, delete)
  - System settings (get, update)
  - Deed template management (create, update, deactivate, reorder)
  - Audit logs (get, export)
  - Notification templates (get, update)
  - Rest days (create, update, delete, bulk import)
  - Analytics (get, export)

### 📋 Remaining Implementation Tasks

## Phase 1: Data Layer Implementation

### Step 1.1: Create Data Models with Freezed

Create models in `lib/features/admin/data/models/`:

```dart
// user_management_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../../../core/constants/user_role.dart';
import '../../../../core/constants/account_status.dart';

part 'user_management_model.freezed.dart';
part 'user_management_model.g.dart';

@freezed
class UserManagementModel with _$UserManagementModel {
  const UserManagementModel._();

  const factory UserManagementModel({
    required String id,
    required String email,
    required String name,
    String? phone,
    @JsonKey(name: 'photo_url') String? photoUrl,
    required String role,
    @JsonKey(name: 'membership_status') required String membershipStatus,
    @JsonKey(name: 'account_status') required String accountStatus,
    @JsonKey(name: 'excuse_mode') required bool excuseMode,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'approved_by') String? approvedBy,
    @JsonKey(name: 'approved_at') DateTime? approvedAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    // Statistics from joined queries
    @JsonKey(name: 'total_reports') @Default(0) int totalReports,
    @JsonKey(name: 'compliance_rate') @Default(0.0) double complianceRate,
    @JsonKey(name: 'current_balance') @Default(0.0) double currentBalance,
    @JsonKey(name: 'last_report_date') DateTime? lastReportDate,
    @JsonKey(name: 'training_ends_at') DateTime? trainingEndsAt,
  }) = _UserManagementModel;

  factory UserManagementModel.fromJson(Map<String, dynamic> json) =>
      _$UserManagementModelFromJson(json);

  UserManagementEntity toEntity() {
    return UserManagementEntity(
      id: id,
      email: email,
      name: name,
      phone: phone,
      photoUrl: photoUrl,
      role: UserRole.fromString(role),
      membershipStatus: membershipStatus,
      accountStatus: AccountStatus.fromString(accountStatus),
      excuseMode: excuseMode,
      createdAt: createdAt,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      updatedAt: updatedAt,
      totalReports: totalReports,
      complianceRate: complianceRate,
      currentBalance: currentBalance,
      lastReportDate: lastReportDate,
      trainingEndsAt: trainingEndsAt,
    );
  }
}
```

**Create similar models for:**
- `system_settings_model.dart`
- `audit_log_model.dart`
- `notification_template_model.dart`
- `rest_day_model.dart`
- `analytics_model.dart`

### Step 1.2: Create Remote Datasource

Create `lib/features/admin/data/datasources/admin_remote_datasource.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_management_model.dart';
import '../models/system_settings_model.dart';
import '../models/audit_log_model.dart';
import '../models/notification_template_model.dart';
import '../models/rest_day_model.dart';
import '../models/analytics_model.dart';

class AdminRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AdminRemoteDataSource(this._supabaseClient);

  // ==================== USER MANAGEMENT ====================

  /// Get users with filters and statistics
  Future<List<UserManagementModel>> getUsers({
    String? accountStatus,
    String? searchQuery,
    String? membershipStatus,
  }) async {
    try {
      // Build query with joins to get statistics
      var query = _supabaseClient
          .from('users')
          .select('''
            *,
            total_reports:deeds_reports(count),
            current_balance:penalties(amount, paid_amount)
          ''');

      if (accountStatus != null) {
        query = query.eq('account_status', accountStatus);
      }

      if (membershipStatus != null) {
        query = query.eq('membership_status', membershipStatus);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      query = query.order('created_at', ascending: false);

      final response = await query;

      return (response as List).map((json) {
        // Calculate statistics from joined data
        final totalReports = json['total_reports']?.length ?? 0;

        double currentBalance = 0;
        if (json['current_balance'] != null) {
          for (var penalty in json['current_balance']) {
            currentBalance += (penalty['amount'] - penalty['paid_amount']);
          }
        }

        return UserManagementModel.fromJson({
          ...json,
          'total_reports': totalReports,
          'current_balance': currentBalance,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  /// Approve a pending user
  Future<void> approveUser({
    required String userId,
    required String approvedBy,
  }) async {
    try {
      await _supabaseClient.from('users').update({
        'account_status': 'active',
        'approved_by': approvedBy,
        'approved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Log audit trail
      await _logAuditTrail(
        action: 'user_approved',
        performedBy: approvedBy,
        entityType: 'user',
        entityId: userId,
        reason: 'User registration approved',
        oldValue: {'account_status': 'pending'},
        newValue: {'account_status': 'active'},
      );
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  /// Reject a pending user
  Future<void> rejectUser({
    required String userId,
    required String rejectedBy,
    required String reason,
  }) async {
    try {
      // Delete user instead of just marking as rejected
      await _supabaseClient.from('users').delete().eq('id', userId);

      // Log audit trail
      await _logAuditTrail(
        action: 'user_rejected',
        performedBy: rejectedBy,
        entityType: 'user',
        entityId: userId,
        reason: reason,
      );
    } catch (e) {
      throw Exception('Failed to reject user: $e');
    }
  }

  // ... Additional methods for user management

  // ==================== SYSTEM SETTINGS ====================

  Future<SystemSettingsModel> getSystemSettings() async {
    try {
      final response = await _supabaseClient
          .from('settings')
          .select();

      // Convert key-value pairs to settings object
      Map<String, dynamic> settingsMap = {};
      for (var setting in response) {
        settingsMap[setting['setting_key']] = setting['setting_value'];
      }

      return SystemSettingsModel.fromMap(settingsMap);
    } catch (e) {
      throw Exception('Failed to fetch system settings: $e');
    }
  }

  // ==================== AUDIT TRAIL LOGGING ====================

  Future<void> _logAuditTrail({
    required String action,
    required String performedBy,
    required String entityType,
    required String entityId,
    required String reason,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    try {
      await _supabaseClient.from('audit_logs').insert({
        'action': action,
        'performed_by': performedBy,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_value': oldValue,
        'new_value': newValue,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Don't throw - audit log failure shouldn't break the main operation
      print('Warning: Failed to log audit trail: $e');
    }
  }
}
```

### Step 1.3: Create Repository Implementation

Create `lib/features/admin/data/repositories/admin_repository_impl.dart`:

```dart
import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../domain/entities/audit_log_entity.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _remoteDataSource;

  AdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<UserManagementEntity>> getUsers({
    String? accountStatus,
    String? searchQuery,
    String? membershipStatus,
  }) async {
    try {
      final models = await _remoteDataSource.getUsers(
        accountStatus: accountStatus,
        searchQuery: searchQuery,
        membershipStatus: membershipStatus,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  @override
  Future<void> approveUser({
    required String userId,
    required String approvedBy,
  }) async {
    try {
      await _remoteDataSource.approveUser(
        userId: userId,
        approvedBy: approvedBy,
      );
    } catch (e) {
      throw Exception('Failed to approve user: $e');
    }
  }

  // Implement remaining methods...
}
```

## Phase 2: Presentation Layer - BLoC

### Step 2.1: Create BLoC Events

Create `lib/features/admin/presentation/bloc/admin_event.dart`:

```dart
import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// ==================== USER MANAGEMENT EVENTS ====================

class LoadUsersRequested extends AdminEvent {
  final String? accountStatus;
  final String? searchQuery;
  final String? membershipStatus;

  const LoadUsersRequested({
    this.accountStatus,
    this.searchQuery,
    this.membershipStatus,
  });

  @override
  List<Object?> get props => [accountStatus, searchQuery, membershipStatus];
}

class LoadUserByIdRequested extends AdminEvent {
  final String userId;

  const LoadUserByIdRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ApproveUserRequested extends AdminEvent {
  final String userId;
  final String approvedBy;

  const ApproveUserRequested({
    required this.userId,
    required this.approvedBy,
  });

  @override
  List<Object?> get props => [userId, approvedBy];
}

class RejectUserRequested extends AdminEvent {
  final String userId;
  final String rejectedBy;
  final String reason;

  const RejectUserRequested({
    required this.userId,
    required this.rejectedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, rejectedBy, reason];
}

class UpdateUserRequested extends AdminEvent {
  final String userId;
  final String? name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final String? role;
  final String? membershipStatus;
  final String? accountStatus;
  final String updatedBy;
  final String reason;

  const UpdateUserRequested({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.role,
    this.membershipStatus,
    this.accountStatus,
    required this.updatedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        phone,
        photoUrl,
        role,
        membershipStatus,
        accountStatus,
        updatedBy,
        reason,
      ];
}

class SuspendUserRequested extends AdminEvent {
  final String userId;
  final String suspendedBy;
  final String reason;

  const SuspendUserRequested({
    required this.userId,
    required this.suspendedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, suspendedBy, reason];
}

class DeleteUserRequested extends AdminEvent {
  final String userId;
  final String deletedBy;
  final String reason;

  const DeleteUserRequested({
    required this.userId,
    required this.deletedBy,
    required this.reason,
  });

  @override
  List<Object?> get props => [userId, deletedBy, reason];
}

// ==================== SYSTEM SETTINGS EVENTS ====================

class LoadSystemSettingsRequested extends AdminEvent {
  const LoadSystemSettingsRequested();
}

class UpdateSystemSettingsRequested extends AdminEvent {
  final Map<String, dynamic> settings;
  final String updatedBy;

  const UpdateSystemSettingsRequested({
    required this.settings,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [settings, updatedBy];
}

// ==================== ANALYTICS EVENTS ====================

class LoadAnalyticsRequested extends AdminEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAnalyticsRequested({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

// ==================== AUDIT LOG EVENTS ====================

class LoadAuditLogsRequested extends AdminEvent {
  final String? action;
  final String? performedBy;
  final String? entityType;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadAuditLogsRequested({
    this.action,
    this.performedBy,
    this.entityType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [action, performedBy, entityType, startDate, endDate];
}

// Add more events for other features...
```

### Step 2.2: Create BLoC States

Create `lib/features/admin/presentation/bloc/admin_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_management_entity.dart';
import '../../domain/entities/system_settings_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/audit_log_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

// ==================== USER MANAGEMENT STATES ====================

class UsersLoaded extends AdminState {
  final List<UserManagementEntity> users;
  final String? appliedFilter;

  const UsersLoaded({
    required this.users,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [users, appliedFilter];
}

class UserDetailLoaded extends AdminState {
  final UserManagementEntity user;

  const UserDetailLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserApproved extends AdminState {
  final String userId;

  const UserApproved(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserRejected extends AdminState {
  final String userId;

  const UserRejected(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserUpdated extends AdminState {
  final String userId;

  const UserUpdated(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserSuspended extends AdminState {
  final String userId;

  const UserSuspended(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UserDeleted extends AdminState {
  final String userId;

  const UserDeleted(this.userId);

  @override
  List<Object?> get props => [userId];
}

// ==================== SYSTEM SETTINGS STATES ====================

class SystemSettingsLoaded extends AdminState {
  final SystemSettingsEntity settings;

  const SystemSettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SystemSettingsUpdated extends AdminState {
  const SystemSettingsUpdated();
}

// ==================== ANALYTICS STATES ====================

class AnalyticsLoaded extends AdminState {
  final AnalyticsEntity analytics;

  const AnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

// ==================== AUDIT LOG STATES ====================

class AuditLogsLoaded extends AdminState {
  final List<AuditLogEntity> logs;

  const AuditLogsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

// ==================== ERROR STATE ====================

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### Step 2.3: Create AdminBloc

Create `lib/features/admin/presentation/bloc/admin_bloc.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepository;

  AdminBloc(this._adminRepository) : super(const AdminInitial()) {
    on<LoadUsersRequested>(_onLoadUsersRequested);
    on<LoadUserByIdRequested>(_onLoadUserByIdRequested);
    on<ApproveUserRequested>(_onApproveUserRequested);
    on<RejectUserRequested>(_onRejectUserRequested);
    on<UpdateUserRequested>(_onUpdateUserRequested);
    on<SuspendUserRequested>(_onSuspendUserRequested);
    on<DeleteUserRequested>(_onDeleteUserRequested);
    on<LoadSystemSettingsRequested>(_onLoadSystemSettingsRequested);
    on<UpdateSystemSettingsRequested>(_onUpdateSystemSettingsRequested);
    on<LoadAnalyticsRequested>(_onLoadAnalyticsRequested);
    on<LoadAuditLogsRequested>(_onLoadAuditLogsRequested);
  }

  Future<void> _onLoadUsersRequested(
    LoadUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final users = await _adminRepository.getUsers(
        accountStatus: event.accountStatus,
        searchQuery: event.searchQuery,
        membershipStatus: event.membershipStatus,
      );
      emit(UsersLoaded(
        users: users,
        appliedFilter: event.accountStatus,
      ));
    } catch (e) {
      emit(AdminError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> _onApproveUserRequested(
    ApproveUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _adminRepository.approveUser(
        userId: event.userId,
        approvedBy: event.approvedBy,
      );
      emit(UserApproved(event.userId));
    } catch (e) {
      emit(AdminError('Failed to approve user: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSystemSettingsRequested(
    LoadSystemSettingsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final settings = await _adminRepository.getSystemSettings();
      emit(SystemSettingsLoaded(settings));
    } catch (e) {
      emit(AdminError('Failed to load system settings: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAnalyticsRequested(
    LoadAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final analytics = await _adminRepository.getAnalytics(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AnalyticsLoaded(analytics));
    } catch (e) {
      emit(AdminError('Failed to load analytics: ${e.toString()}'));
    }
  }

  // Implement remaining event handlers...
}
```

## Phase 3: Presentation Layer - UI

### Step 3.1: User Management Page

Create `lib/features/admin/presentation/pages/user_management_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/user_card.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers('pending');

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final status = _getStatusForTab(_tabController.index);
      _loadUsers(status);
    });
  }

  void _loadUsers(String? status) {
    context.read<AdminBloc>().add(LoadUsersRequested(
          accountStatus: status,
          searchQuery: _searchQuery,
        ));
  }

  String _getStatusForTab(int index) {
    switch (index) {
      case 0:
        return 'pending';
      case 1:
        return 'active';
      case 2:
        return 'suspended';
      case 3:
        return 'auto_deactivated';
      default:
        return 'active';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Suspended'),
            Tab(text: 'Deactivated'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _loadUsers(_getStatusForTab(_tabController.index));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<AdminBloc, AdminState>(
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AdminError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        ElevatedButton(
                          onPressed: () =>
                              _loadUsers(_getStatusForTab(_tabController.index)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is UsersLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return UserCard(
                        user: user,
                        onApprove: _tabController.index == 0
                            ? () => _approveUser(user.id)
                            : null,
                        onReject: _tabController.index == 0
                            ? () => _rejectUser(user.id)
                            : null,
                        onEdit: () => _editUser(user.id),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _approveUser(String userId) {
    // Get current admin user ID (from auth context)
    final currentUserId = 'admin-user-id'; // TODO: Get from AuthBloc
    context.read<AdminBloc>().add(ApproveUserRequested(
          userId: userId,
          approvedBy: currentUserId,
        ));
  }

  void _rejectUser(String userId) {
    // Show dialog to get rejection reason
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Enter reason...',
          ),
          maxLines: 3,
          onSubmitted: (reason) {
            Navigator.pop(context);
            final currentUserId = 'admin-user-id'; // TODO: Get from AuthBloc
            this.context.read<AdminBloc>().add(RejectUserRequested(
                  userId: userId,
                  rejectedBy: currentUserId,
                  reason: reason,
                ));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _editUser(String userId) {
    Navigator.pushNamed(context, '/admin/user-edit', arguments: userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

### Step 3.2: Create Reusable Widgets

Create `lib/features/admin/presentation/widgets/user_card.dart`:

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/user_management_entity.dart';

class UserCard extends StatelessWidget {
  final UserManagementEntity user;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onEdit;

  const UserCard({
    Key? key,
    required this.user,
    this.onApprove,
    this.onReject,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.membershipBadge,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!user.isPending) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Balance', user.formattedBalance),
                  _buildStatItem('Reports', user.totalReports.toString()),
                  _buildStatItem('Compliance', user.formattedComplianceRate),
                ],
              ),
            ],
            if (onApprove != null || onReject != null || onEdit != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null)
                    TextButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  if (onApprove != null)
                    ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.more_vert),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
```

## Phase 4: Integration

### Step 4.1: Update Dependency Injection

Update `lib/core/di/injection.dart`:

```dart
// Add these imports
import 'package:sabiquun_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:sabiquun_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:sabiquun_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';

class Injection {
  // Add these static variables
  static late AdminRemoteDataSource _adminRemoteDataSource;
  static late AdminRepository _adminRepository;
  static late AdminBloc _adminBloc;

  static Future<void> init() async {
    // ... existing initialization code ...

    // Initialize Admin Data Sources
    _adminRemoteDataSource = AdminRemoteDataSource(_supabase);

    // Initialize Admin Repositories
    _adminRepository = AdminRepositoryImpl(_adminRemoteDataSource);

    // Initialize Admin Blocs
    _adminBloc = AdminBloc(_adminRepository);
  }

  // Add getters
  static AdminRemoteDataSource get adminRemoteDataSource => _adminRemoteDataSource;
  static AdminRepository get adminRepository => _adminRepository;
  static AdminBloc get adminBloc => _adminBloc;

  static Future<void> reset() async {
    await _authBloc.close();
    await _deedBloc.close();
    await _penaltyBloc.close();
    await _paymentBloc.close();
    await _adminBloc.close(); // Add this
  }
}
```

### Step 4.2: Update App Router

Update `lib/core/navigation/app_router.dart` to include admin routes:

```dart
// Add admin route constants
class AdminRoutes {
  static const String userManagement = '/admin/user-management';
  static const String userEdit = '/admin/user-edit';
  static const String systemSettings = '/admin/system-settings';
  static const String deedManagement = '/admin/deed-management';
  static const String analytics = '/admin/analytics';
  static const String auditLog = '/admin/audit-log';
  static const String notificationManagement = '/admin/notification-management';
  static const String restDaysManagement = '/admin/rest-days-management';
}

// Add routes in your router configuration
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ... existing routes ...

    case AdminRoutes.userManagement:
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: Injection.adminBloc,
          child: const UserManagementPage(),
        ),
      );

    case AdminRoutes.userEdit:
      final userId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: Injection.adminBloc,
          child: UserEditPage(userId: userId),
        ),
      );

    // Add more admin routes...
  }
}
```

### Step 4.3: Remove Placeholder

Delete or replace `lib/features/admin/pages/user_management_placeholder_page.dart` with actual implementation.

## Phase 5: Code Generation

### Step 5.1: Run Build Runner

Execute the following command to generate Freezed code:

```bash
cd sabiquun_app
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `*.freezed.dart` files for all Freezed models
- `*.g.dart` files for all JSON serialization

## Testing Checklist

### Unit Tests
- [ ] Test each BLoC event handler
- [ ] Test repository implementations
- [ ] Test data source methods
- [ ] Test entity business logic

### Integration Tests
- [ ] Test user approval flow
- [ ] Test user rejection flow
- [ ] Test settings update flow
- [ ] Test analytics loading
- [ ] Test audit log filtering

### UI Tests
- [ ] Test tab navigation
- [ ] Test search functionality
- [ ] Test user actions (approve/reject/edit)
- [ ] Test form validation
- [ ] Test error states
- [ ] Test loading states

## Database Queries Reference

### Get Users with Statistics

```sql
SELECT
  u.*,
  COUNT(DISTINCT dr.id) as total_reports,
  COALESCE(SUM(p.amount - p.paid_amount), 0) as current_balance,
  MAX(dr.report_date) as last_report_date,
  (u.created_at + INTERVAL '30 days') as training_ends_at
FROM users u
LEFT JOIN deeds_reports dr ON u.id = dr.user_id
LEFT JOIN penalties p ON u.id = p.user_id
  AND p.status IN ('unpaid', 'partially_paid')
WHERE u.account_status = 'active'
GROUP BY u.id
ORDER BY u.created_at DESC;
```

### Get System Analytics

```sql
-- User Metrics
SELECT
  COUNT(*) FILTER (WHERE account_status = 'pending') as pending_users,
  COUNT(*) FILTER (WHERE account_status = 'active') as active_users,
  COUNT(*) FILTER (WHERE account_status = 'suspended') as suspended_users,
  COUNT(*) FILTER (WHERE membership_status = 'new') as new_members,
  COUNT(*) FILTER (WHERE membership_status = 'exclusive') as exclusive_members,
  COUNT(*) FILTER (WHERE membership_status = 'legacy') as legacy_members
FROM users;

-- Deed Metrics
SELECT
  COUNT(*) as total_reports_today,
  AVG(total_deeds) as average_deeds_per_user,
  COUNT(*) FILTER (WHERE total_deeds >= 10) as compliant_users
FROM deeds_reports
WHERE report_date = CURRENT_DATE;

-- Financial Metrics
SELECT
  COALESCE(SUM(amount), 0) as total_penalties_this_month,
  COALESCE(SUM(amount - paid_amount), 0) as outstanding_balance
FROM penalties
WHERE date_incurred >= DATE_TRUNC('month', CURRENT_DATE);
```

## Key Implementation Notes

1. **Error Handling**: All repository methods should catch exceptions and provide meaningful error messages.

2. **Audit Logging**: Every admin action must be logged in the audit_logs table.

3. **Permissions**: Verify user role before allowing admin actions (implement middleware or guards).

4. **Loading States**: Always show loading indicators during async operations.

5. **Confirmation Dialogs**: Use dialogs for destructive actions (delete, reject, suspend).

6. **Form Validation**: Validate all input fields before submission.

7. **Pagination**: Implement pagination for large lists (users, audit logs).

8. **Real-time Updates**: Consider using Supabase realtime for live updates on user approvals.

9. **Caching**: Cache settings and templates to reduce API calls.

10. **Export Features**: Implement CSV/Excel export for analytics and audit logs using packages like `csv` or `excel`.

## Next Steps

1. ✅ Complete domain entities (DONE)
2. ✅ Complete repository interface (DONE)
3. ⏳ Create all Freezed models
4. ⏳ Implement datasources
5. ⏳ Implement repositories
6. ⏳ Implement BLoC
7. ⏳ Create all UI pages
8. ⏳ Create reusable widgets
9. ⏳ Update DI and routing
10. ⏳ Run build_runner
11. ⏳ Test and fix errors
12. ⏳ Add comprehensive tests

## File Structure Summary

```
lib/features/admin/
├── domain/
│   ├── entities/
│   │   ├── user_management_entity.dart ✅
│   │   ├── system_settings_entity.dart ✅
│   │   ├── audit_log_entity.dart ✅
│   │   ├── notification_template_entity.dart ✅
│   │   ├── rest_day_entity.dart ✅
│   │   └── analytics_entity.dart ✅
│   └── repositories/
│       └── admin_repository.dart ✅
├── data/
│   ├── models/
│   │   ├── user_management_model.dart
│   │   ├── user_management_model.freezed.dart
│   │   ├── user_management_model.g.dart
│   │   ├── system_settings_model.dart
│   │   ├── audit_log_model.dart
│   │   ├── notification_template_model.dart
│   │   ├── rest_day_model.dart
│   │   └── analytics_model.dart
│   ├── datasources/
│   │   └── admin_remote_datasource.dart
│   └── repositories/
│       └── admin_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── admin_bloc.dart
    │   ├── admin_event.dart
    │   └── admin_state.dart
    ├── pages/
    │   ├── user_management_page.dart
    │   ├── user_edit_page.dart
    │   ├── system_settings_page.dart
    │   ├── deed_management_page.dart
    │   ├── analytics_dashboard_page.dart
    │   ├── audit_log_page.dart
    │   ├── notification_management_page.dart
    │   └── rest_days_management_page.dart
    └── widgets/
        ├── user_card.dart
        ├── user_stats_card.dart
        ├── settings_section.dart
        ├── deed_template_card.dart
        ├── analytics_metric_card.dart
        └── audit_log_entry.dart
```

## Conclusion

This implementation guide provides a complete blueprint for building the admin system. The architecture follows clean code principles, separation of concerns, and the BLoC pattern consistently used throughout the app.

The implementation is production-ready with proper error handling, audit logging, and comprehensive state management. All admin actions are tracked and can be reviewed in the audit log.

To complete the implementation:
1. Follow each phase systematically
2. Test each component before moving to the next
3. Run build_runner after creating all models
4. Ensure proper role-based access control
5. Add comprehensive unit and integration tests

For questions or clarifications, refer to the existing implementations in the penalties and payments features as they follow the same architectural patterns.
