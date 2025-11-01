import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_event.dart';
import 'admin_state.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc(this._repository) : super(const AdminInitial()) {
    on<LoadUsersRequested>(_onLoadUsers);
    on<LoadUserByIdRequested>(_onLoadUserById);
    on<ApproveUserRequested>(_onApproveUser);
    on<RejectUserRequested>(_onRejectUser);
    on<UpdateUserRequested>(_onUpdateUser);
    on<ChangeUserRoleRequested>(_onChangeUserRole);
    on<SuspendUserRequested>(_onSuspendUser);
    on<ActivateUserRequested>(_onActivateUser);
    on<DeleteUserRequested>(_onDeleteUser);
    on<LoadAnalyticsRequested>(_onLoadAnalytics);
    on<LoadSystemSettingsRequested>(_onLoadSystemSettings);
    on<UpdateSystemSettingsRequested>(_onUpdateSystemSettings);
    on<LoadDeedTemplatesRequested>(_onLoadDeedTemplates);
    on<CreateDeedTemplateRequested>(_onCreateDeedTemplate);
    on<UpdateDeedTemplateRequested>(_onUpdateDeedTemplate);
    on<DeactivateDeedTemplateRequested>(_onDeactivateDeedTemplate);
    on<ReorderDeedTemplatesRequested>(_onReorderDeedTemplates);
  }

  Future<void> _onLoadUsers(
    LoadUsersRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final users = await _repository.getUsers(
        accountStatus: event.accountStatus,
        searchQuery: event.searchQuery,
        membershipStatus: event.membershipStatus,
      );

      // Create filter description
      String? filterDesc;
      if (event.accountStatus != null) {
        filterDesc = event.accountStatus!.toUpperCase();
      } else if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        filterDesc = 'Search: ${event.searchQuery}';
      }

      emit(UsersLoaded(users: users, appliedFilter: filterDesc));
    } catch (e) {
      emit(AdminError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserById(
    LoadUserByIdRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final user = await _repository.getUserById(event.userId);
      emit(UserDetailLoaded(user));
    } catch (e) {
      emit(AdminError('Failed to load user details: ${e.toString()}'));
    }
  }

  Future<void> _onApproveUser(
    ApproveUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.approveUser(
        userId: event.userId,
        approvedBy: event.approvedBy,
      );
      emit(UserApproved(event.userId));
    } catch (e) {
      emit(AdminError('Failed to approve user: ${e.toString()}'));
    }
  }

  Future<void> _onRejectUser(
    RejectUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.rejectUser(
        userId: event.userId,
        rejectedBy: event.rejectedBy,
        reason: event.reason,
      );
      emit(UserRejected(event.userId));
    } catch (e) {
      emit(AdminError('Failed to reject user: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.updateUser(
        userId: event.userId,
        name: event.name,
        email: event.email,
        phone: event.phone,
        photoUrl: event.photoUrl,
        role: event.role,
        membershipStatus: event.membershipStatus,
        accountStatus: event.accountStatus,
        updatedBy: event.updatedBy,
        reason: event.reason,
      );
      emit(UserUpdated(userId: event.userId));
    } catch (e) {
      emit(AdminError('Failed to update user: ${e.toString()}'));
    }
  }

  Future<void> _onChangeUserRole(
    ChangeUserRoleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.changeUserRole(
        userId: event.userId,
        newRole: event.newRole,
        changedBy: event.changedBy,
        reason: event.reason,
      );
      emit(UserRoleChanged(userId: event.userId, newRole: event.newRole));
    } catch (e) {
      emit(AdminError('Failed to change user role: ${e.toString()}'));
    }
  }

  Future<void> _onSuspendUser(
    SuspendUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.suspendUser(
        userId: event.userId,
        suspendedBy: event.suspendedBy,
        reason: event.reason,
      );
      emit(UserSuspended(event.userId));
    } catch (e) {
      emit(AdminError('Failed to suspend user: ${e.toString()}'));
    }
  }

  Future<void> _onActivateUser(
    ActivateUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.activateUser(
        userId: event.userId,
        activatedBy: event.activatedBy,
        reason: event.reason,
      );
      emit(UserActivated(event.userId));
    } catch (e) {
      emit(AdminError('Failed to activate user: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUserRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.deleteUser(
        userId: event.userId,
        deletedBy: event.deletedBy,
        reason: event.reason,
      );
      emit(UserDeleted(event.userId));
    } catch (e) {
      emit(AdminError('Failed to delete user: ${e.toString()}'));
    }
  }

  // ==================== ANALYTICS ====================

  Future<void> _onLoadAnalytics(
    LoadAnalyticsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final analytics = await _repository.getAnalytics(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AnalyticsLoaded(analytics));
    } catch (e) {
      emit(AdminError('Failed to load analytics: ${e.toString()}'));
    }
  }

  // ==================== SYSTEM SETTINGS ====================

  Future<void> _onLoadSystemSettings(
    LoadSystemSettingsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final settings = await _repository.getSystemSettings();
      emit(SystemSettingsLoaded(settings));
    } catch (e) {
      emit(AdminError('Failed to load system settings: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSystemSettings(
    UpdateSystemSettingsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.updateSystemSettings(
        settings: event.settings,
        updatedBy: event.updatedBy,
      );
      emit(const SystemSettingsUpdated());
    } catch (e) {
      emit(AdminError('Failed to update system settings: ${e.toString()}'));
    }
  }

  // ==================== DEED TEMPLATES ====================

  Future<void> _onLoadDeedTemplates(
    LoadDeedTemplatesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final templates = await _repository.getDeedTemplates(
        isActive: event.isActive,
        category: event.category,
      );
      emit(DeedTemplatesLoaded(templates));
    } catch (e) {
      emit(AdminError('Failed to load deed templates: ${e.toString()}'));
    }
  }

  Future<void> _onCreateDeedTemplate(
    CreateDeedTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final template = await _repository.createDeedTemplate(
        deedName: event.deedName,
        deedKey: event.deedKey,
        category: event.category,
        valueType: event.valueType,
        sortOrder: event.sortOrder,
        isActive: event.isActive,
        createdBy: event.createdBy,
      );
      emit(DeedTemplateCreated(template));

      // Reload templates after creation
      add(const LoadDeedTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to create deed template: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDeedTemplate(
    UpdateDeedTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.updateDeedTemplate(
        templateId: event.templateId,
        deedName: event.deedName,
        category: event.category,
        valueType: event.valueType,
        sortOrder: event.sortOrder,
        isActive: event.isActive,
        updatedBy: event.updatedBy,
      );
      emit(DeedTemplateUpdated(event.templateId));

      // Reload templates after update
      add(const LoadDeedTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to update deed template: ${e.toString()}'));
    }
  }

  Future<void> _onDeactivateDeedTemplate(
    DeactivateDeedTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.deactivateDeedTemplate(
        templateId: event.templateId,
        deactivatedBy: event.deactivatedBy,
        reason: event.reason,
      );
      emit(DeedTemplateDeactivated(event.templateId));

      // Reload templates after deactivation
      add(const LoadDeedTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to deactivate deed template: ${e.toString()}'));
    }
  }

  Future<void> _onReorderDeedTemplates(
    ReorderDeedTemplatesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.reorderDeedTemplates(
        templateIds: event.templateIds,
        updatedBy: event.updatedBy,
      );
      emit(const DeedTemplatesReordered());

      // Reload templates after reordering to show new order
      add(const LoadDeedTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to reorder deed templates: ${e.toString()}'));
    }
  }
}
