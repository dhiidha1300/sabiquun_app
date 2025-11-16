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
    on<LoadAuditLogsRequested>(_onLoadAuditLogs);
    on<ExportAuditLogsRequested>(_onExportAuditLogs);
    on<LoadExcusesRequested>(_onLoadExcuses);
    on<LoadExcuseByIdRequested>(_onLoadExcuseById);
    on<ApproveExcuseRequested>(_onApproveExcuse);
    on<RejectExcuseRequested>(_onRejectExcuse);
    on<BulkApproveExcusesRequested>(_onBulkApproveExcuses);
    on<BulkRejectExcusesRequested>(_onBulkRejectExcuses);
    on<LoadNotificationTemplatesRequested>(_onLoadNotificationTemplates);
    on<LoadNotificationTemplateByIdRequested>(_onLoadNotificationTemplateById);
    on<CreateNotificationTemplateRequested>(_onCreateNotificationTemplate);
    on<UpdateNotificationTemplateRequested>(_onUpdateNotificationTemplate);
    on<DeleteNotificationTemplateRequested>(_onDeleteNotificationTemplate);
    on<ToggleNotificationTemplateRequested>(_onToggleNotificationTemplate);
    on<LoadNotificationSchedulesRequested>(_onLoadNotificationSchedules);
    on<LoadNotificationScheduleByIdRequested>(_onLoadNotificationScheduleById);
    on<CreateNotificationScheduleRequested>(_onCreateNotificationSchedule);
    on<UpdateNotificationScheduleRequested>(_onUpdateNotificationSchedule);
    on<DeleteNotificationScheduleRequested>(_onDeleteNotificationSchedule);
    on<ToggleNotificationScheduleRequested>(_onToggleNotificationSchedule);
    on<SendManualNotificationRequested>(_onSendManualNotification);
    on<SearchReportsRequested>(_onSearchReports);
    on<GetReportByIdRequested>(_onGetReportById);
    on<UpdateReportRequested>(_onUpdateReport);
    on<LoadRestDaysRequested>(_onLoadRestDays);
    on<CreateRestDayRequested>(_onCreateRestDay);
    on<UpdateRestDayRequested>(_onUpdateRestDay);
    on<DeleteRestDayRequested>(_onDeleteRestDay);
    on<BulkImportRestDaysRequested>(_onBulkImportRestDays);
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

  // ==================== AUDIT LOGS ====================

  Future<void> _onLoadAuditLogs(
    LoadAuditLogsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final logs = await _repository.getAuditLogs(
        action: event.action,
        performedBy: event.performedBy,
        entityType: event.entityType,
        entityId: event.entityId,
        startDate: event.startDate,
        endDate: event.endDate,
        limit: event.limit,
      );
      emit(AuditLogsLoaded(logs));
    } catch (e) {
      emit(AdminError('Failed to load audit logs: ${e.toString()}'));
    }
  }

  Future<void> _onExportAuditLogs(
    ExportAuditLogsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final csvContent = await _repository.exportAuditLogs(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Count lines (subtract 1 for header)
      final logCount = csvContent.split('\n').length - 1;

      emit(AuditLogsExported(
        csvContent: csvContent,
        logCount: logCount,
      ));
    } catch (e) {
      emit(AdminError('Failed to export audit logs: ${e.toString()}'));
    }
  }

  // ============================================================================
  // Excuse Management Handlers
  // ============================================================================

  Future<void> _onLoadExcuses(
    LoadExcusesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final excuses = await _repository.getExcuses(
        status: event.status,
        userId: event.userId,
        excuseType: event.excuseType,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      String? filterDesc;
      if (event.status != null) {
        filterDesc = event.status == 'pending' ? 'Pending' :
                     event.status == 'approved' ? 'Approved' : 'Rejected';
      }

      emit(ExcusesLoaded(excuses: excuses, appliedFilter: filterDesc));
    } catch (e) {
      emit(AdminError('Failed to load excuses: ${e.toString()}'));
    }
  }

  Future<void> _onLoadExcuseById(
    LoadExcuseByIdRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final excuse = await _repository.getExcuseById(event.excuseId);
      emit(ExcuseDetailLoaded(excuse));
    } catch (e) {
      emit(AdminError('Failed to load excuse: ${e.toString()}'));
    }
  }

  Future<void> _onApproveExcuse(
    ApproveExcuseRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.approveExcuse(
        excuseId: event.excuseId,
        approvedBy: event.approvedBy,
      );
      emit(ExcuseApproved(event.excuseId));
      // Reload excuses list
      add(const LoadExcusesRequested());
    } catch (e) {
      emit(AdminError('Failed to approve excuse: ${e.toString()}'));
    }
  }

  Future<void> _onRejectExcuse(
    RejectExcuseRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.rejectExcuse(
        excuseId: event.excuseId,
        rejectedBy: event.rejectedBy,
        reason: event.reason,
      );
      emit(ExcuseRejected(event.excuseId));
      // Reload excuses list
      add(const LoadExcusesRequested());
    } catch (e) {
      emit(AdminError('Failed to reject excuse: ${e.toString()}'));
    }
  }

  Future<void> _onBulkApproveExcuses(
    BulkApproveExcusesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final count = await _repository.bulkApproveExcuses(
        excuseIds: event.excuseIds,
        approvedBy: event.approvedBy,
      );
      emit(BulkExcusesApproved(count));
      // Reload excuses list
      add(const LoadExcusesRequested());
    } catch (e) {
      emit(AdminError('Failed to bulk approve excuses: ${e.toString()}'));
    }
  }

  Future<void> _onBulkRejectExcuses(
    BulkRejectExcusesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final count = await _repository.bulkRejectExcuses(
        excuseIds: event.excuseIds,
        rejectedBy: event.rejectedBy,
        reason: event.reason,
      );
      emit(BulkExcusesRejected(count));
      // Reload excuses list
      add(const LoadExcusesRequested());
    } catch (e) {
      emit(AdminError('Failed to bulk reject excuses: ${e.toString()}'));
    }
  }

  // ==================== NOTIFICATION TEMPLATE EVENT HANDLERS ====================

  Future<void> _onLoadNotificationTemplates(
    LoadNotificationTemplatesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final templates = await _repository.getNotificationTemplates(
        templateType: event.templateType,
        isActive: event.isActive,
      );
      emit(NotificationTemplatesLoaded(templates));
    } catch (e) {
      emit(AdminError('Failed to load notification templates: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNotificationTemplateById(
    LoadNotificationTemplateByIdRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final template = await _repository.getNotificationTemplateById(event.templateId);
      emit(NotificationTemplateLoaded(template));
    } catch (e) {
      emit(AdminError('Failed to load notification template: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNotificationTemplate(
    CreateNotificationTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final template = await _repository.createNotificationTemplate(
        templateKey: event.templateKey,
        title: event.title,
        body: event.body,
        emailSubject: event.emailSubject,
        emailBody: event.emailBody,
        notificationType: event.notificationType,
      );
      emit(NotificationTemplateCreated(template));
      // Reload templates list
      add(const LoadNotificationTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to create notification template: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationTemplate(
    UpdateNotificationTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final template = await _repository.updateNotificationTemplate(
        templateId: event.templateId,
        title: event.title,
        body: event.body,
        emailSubject: event.emailSubject,
        emailBody: event.emailBody,
        isEnabled: event.isEnabled,
      );
      emit(NotificationTemplateUpdated(template));
      // Reload templates list
      add(const LoadNotificationTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to update notification template: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNotificationTemplate(
    DeleteNotificationTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.deleteNotificationTemplate(event.templateId);
      emit(NotificationTemplateDeleted(event.templateId));
      // Reload templates list
      add(const LoadNotificationTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to delete notification template: ${e.toString()}'));
    }
  }

  Future<void> _onToggleNotificationTemplate(
    ToggleNotificationTemplateRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final template = await _repository.toggleNotificationTemplate(
        templateId: event.templateId,
        isEnabled: event.isEnabled,
      );
      emit(NotificationTemplateToggled(template));
      // Reload templates list
      add(const LoadNotificationTemplatesRequested());
    } catch (e) {
      emit(AdminError('Failed to toggle notification template: ${e.toString()}'));
    }
  }

  // ==================== NOTIFICATION SCHEDULE EVENT HANDLERS ====================

  Future<void> _onLoadNotificationSchedules(
    LoadNotificationSchedulesRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final schedules = await _repository.getNotificationSchedules();
      emit(NotificationSchedulesLoaded(schedules));
    } catch (e) {
      emit(AdminError('Failed to load notification schedules: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNotificationScheduleById(
    LoadNotificationScheduleByIdRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final schedule = await _repository.getNotificationScheduleById(event.scheduleId);
      emit(NotificationScheduleLoaded(schedule));
    } catch (e) {
      emit(AdminError('Failed to load notification schedule: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNotificationSchedule(
    CreateNotificationScheduleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final schedule = await _repository.createNotificationSchedule(
        notificationTemplateId: event.notificationTemplateId,
        scheduledTime: event.scheduledTime,
        frequency: event.frequency,
        daysOfWeek: event.daysOfWeek,
        conditions: event.conditions,
        createdBy: event.createdBy,
      );
      emit(NotificationScheduleCreated(schedule));
      // Reload schedules list
      add(const LoadNotificationSchedulesRequested());
    } catch (e) {
      emit(AdminError('Failed to create notification schedule: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateNotificationSchedule(
    UpdateNotificationScheduleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final schedule = await _repository.updateNotificationSchedule(
        scheduleId: event.scheduleId,
        notificationTemplateId: event.notificationTemplateId,
        scheduledTime: event.scheduledTime,
        frequency: event.frequency,
        daysOfWeek: event.daysOfWeek,
        conditions: event.conditions,
        isActive: event.isActive,
      );
      emit(NotificationScheduleUpdated(schedule));
      // Reload schedules list
      add(const LoadNotificationSchedulesRequested());
    } catch (e) {
      emit(AdminError('Failed to update notification schedule: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNotificationSchedule(
    DeleteNotificationScheduleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.deleteNotificationSchedule(event.scheduleId);
      emit(NotificationScheduleDeleted(event.scheduleId));
      // Reload schedules list
      add(const LoadNotificationSchedulesRequested());
    } catch (e) {
      emit(AdminError('Failed to delete notification schedule: ${e.toString()}'));
    }
  }

  Future<void> _onToggleNotificationSchedule(
    ToggleNotificationScheduleRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final schedule = await _repository.toggleNotificationSchedule(
        scheduleId: event.scheduleId,
        isActive: event.isActive,
      );
      emit(NotificationScheduleToggled(schedule));
      // Reload schedules list
      add(const LoadNotificationSchedulesRequested());
    } catch (e) {
      emit(AdminError('Failed to toggle notification schedule: ${e.toString()}'));
    }
  }

  Future<void> _onSendManualNotification(
    SendManualNotificationRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.sendManualNotification(
        userIds: event.userIds,
        title: event.title,
        body: event.body,
        notificationType: event.notificationType,
      );
      emit(ManualNotificationSent(event.userIds.length));
    } catch (e) {
      emit(AdminError('Failed to send manual notification: ${e.toString()}'));
    }
  }

  // ==================== REPORT MANAGEMENT HANDLERS ====================

  Future<void> _onSearchReports(
    SearchReportsRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const ReportsSearchInProgress());
    try {
      final reports = await _repository.searchReports(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
        status: event.status,
      );
      emit(ReportsSearchSuccess(reports));
    } catch (e) {
      emit(AdminError('Failed to search reports: ${e.toString()}'));
    }
  }

  Future<void> _onGetReportById(
    GetReportByIdRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final report = await _repository.getReportById(event.reportId);
      emit(ReportLoadedSuccess(report));
    } catch (e) {
      emit(AdminError('Failed to load report: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateReport(
    UpdateReportRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final report = await _repository.updateReport(
        reportId: event.reportId,
        deedValues: event.deedValues,
        reason: event.reason,
      );
      emit(ReportUpdatedSuccess(report));
      // Auto-reload reports list if we have previous search criteria
      // The UI can handle re-fetching based on this success state
    } catch (e) {
      emit(AdminError('Failed to update report: ${e.toString()}'));
    }
  }

  // ==================== REST DAYS MANAGEMENT HANDLERS ====================

  Future<void> _onLoadRestDays(
    LoadRestDaysRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final restDays = await _repository.getRestDays(
        year: event.year,
        isRecurring: event.isRecurring,
      );
      emit(RestDaysLoaded(restDays));
    } catch (e) {
      emit(AdminError('Failed to load rest days: ${e.toString()}'));
    }
  }

  Future<void> _onCreateRestDay(
    CreateRestDayRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final restDay = await _repository.createRestDay(
        date: event.date,
        endDate: event.endDate,
        description: event.description,
        isRecurring: event.isRecurring,
        createdBy: event.createdBy,
      );
      emit(RestDayCreated(restDay));
      // Auto-reload rest days
      add(LoadRestDaysRequested(year: event.date.year));
    } catch (e) {
      emit(AdminError('Failed to create rest day: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateRestDay(
    UpdateRestDayRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.updateRestDay(
        restDayId: event.restDayId,
        date: event.date,
        endDate: event.endDate,
        description: event.description,
        isRecurring: event.isRecurring,
        updatedBy: event.updatedBy,
      );
      emit(const RestDayUpdated());
      // Auto-reload rest days
      add(LoadRestDaysRequested(year: event.date?.year));
    } catch (e) {
      emit(AdminError('Failed to update rest day: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteRestDay(
    DeleteRestDayRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      await _repository.deleteRestDay(
        restDayId: event.restDayId,
        deletedBy: event.deletedBy,
      );
      emit(const RestDayDeleted());
      // Auto-reload rest days
      add(const LoadRestDaysRequested());
    } catch (e) {
      emit(AdminError('Failed to delete rest day: ${e.toString()}'));
    }
  }

  Future<void> _onBulkImportRestDays(
    BulkImportRestDaysRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());
    try {
      final count = await _repository.bulkImportRestDays(
        fileContent: event.fileContent,
        createdBy: event.createdBy,
      );
      emit(RestDaysBulkImported(count));
      // Auto-reload rest days
      add(const LoadRestDaysRequested());
    } catch (e) {
      emit(AdminError('Failed to bulk import rest days: ${e.toString()}'));
    }
  }
}
