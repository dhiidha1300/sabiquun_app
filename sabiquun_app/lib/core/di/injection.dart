import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/core/config/env_config.dart';
import 'package:sabiquun_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sabiquun_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sabiquun_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sabiquun_app/features/deeds/data/datasources/deed_remote_datasource.dart';
import 'package:sabiquun_app/features/deeds/data/repositories/deed_repository_impl.dart';
import 'package:sabiquun_app/features/deeds/domain/repositories/deed_repository.dart';
import 'package:sabiquun_app/features/deeds/presentation/bloc/deed_bloc.dart';
import 'package:sabiquun_app/features/penalties/data/datasources/penalty_remote_datasource.dart';
import 'package:sabiquun_app/features/penalties/data/repositories/penalty_repository_impl.dart';
import 'package:sabiquun_app/features/penalties/domain/repositories/penalty_repository.dart';
import 'package:sabiquun_app/features/penalties/presentation/bloc/penalty_bloc.dart';
import 'package:sabiquun_app/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:sabiquun_app/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:sabiquun_app/features/payments/domain/repositories/payment_repository.dart';
import 'package:sabiquun_app/features/payments/presentation/bloc/payment_bloc.dart';
import 'package:sabiquun_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:sabiquun_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:sabiquun_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:sabiquun_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:sabiquun_app/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:sabiquun_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:sabiquun_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:sabiquun_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:sabiquun_app/shared/services/secure_storage_service.dart';

/// Dependency injection container
/// This is a simple service locator pattern
/// For larger apps, consider using get_it or injectable packages
class Injection {
  static late SupabaseClient _supabase;
  static late SecureStorageService _secureStorage;
  static late AuthRemoteDataSource _authRemoteDataSource;
  static late AuthRepository _authRepository;
  static late AuthBloc _authBloc;
  static late DeedRemoteDataSource _deedRemoteDataSource;
  static late DeedRepository _deedRepository;
  static late DeedBloc _deedBloc;
  static late PenaltyRemoteDataSource _penaltyRemoteDataSource;
  static late PenaltyRepository _penaltyRepository;
  static late PenaltyBloc _penaltyBloc;
  static late PaymentRemoteDataSource _paymentRemoteDataSource;
  static late PaymentRepository _paymentRepository;
  static late PaymentBloc _paymentBloc;
  static late AdminRemoteDataSource _adminRemoteDataSource;
  static late AdminRepository _adminRepository;
  static late AdminBloc _adminBloc;
  static late NotificationRemoteDatasource _notificationRemoteDataSource;
  static late NotificationRepository _notificationRepository;
  static late NotificationBloc _notificationBloc;

  /// Initialize all dependencies
  static Future<void> init() async {
    // Validate environment configuration
    EnvConfig.validateConfig();

    // Initialize Supabase
    _supabase = await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    ).then((value) => value.client);

    // Initialize Secure Storage
    _secureStorage = SecureStorageService.instance();

    // Initialize Data Sources
    _authRemoteDataSource = AuthRemoteDataSource(_supabase);

    // Initialize Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      storageService: _secureStorage,
    );

    // Initialize Blocs
    _authBloc = AuthBloc(authRepository: _authRepository);

    // Initialize Deed Data Sources
    _deedRemoteDataSource = DeedRemoteDataSource(_supabase);

    // Initialize Deed Repositories
    _deedRepository = DeedRepositoryImpl(_deedRemoteDataSource, _supabase);

    // Initialize Deed Blocs
    _deedBloc = DeedBloc(_deedRepository);

    // Initialize Penalty Data Sources
    _penaltyRemoteDataSource = PenaltyRemoteDataSource(_supabase);

    // Initialize Penalty Repositories
    _penaltyRepository = PenaltyRepositoryImpl(_penaltyRemoteDataSource);

    // Initialize Penalty Blocs
    _penaltyBloc = PenaltyBloc(_penaltyRepository);

    // Initialize Payment Data Sources
    _paymentRemoteDataSource = PaymentRemoteDataSource(_supabase);

    // Initialize Payment Repositories
    _paymentRepository = PaymentRepositoryImpl(_paymentRemoteDataSource);

    // Initialize Payment Blocs
    _paymentBloc = PaymentBloc(_paymentRepository);

    // Initialize Admin Data Sources
    _adminRemoteDataSource = AdminRemoteDataSource(_supabase);

    // Initialize Admin Repositories
    _adminRepository = AdminRepositoryImpl(_adminRemoteDataSource);

    // Initialize Admin Blocs
    _adminBloc = AdminBloc(_adminRepository);

    // Initialize Notification Data Sources
    _notificationRemoteDataSource = NotificationRemoteDatasource(supabaseClient: _supabase);

    // Initialize Notification Repositories
    _notificationRepository = NotificationRepositoryImpl(remoteDatasource: _notificationRemoteDataSource);

    // Initialize Notification Blocs
    _notificationBloc = NotificationBloc(repository: _notificationRepository);
  }

  /// Get Supabase client instance
  static SupabaseClient get supabase => _supabase;

  /// Get Secure Storage service instance
  static SecureStorageService get secureStorage => _secureStorage;

  /// Get Auth Remote Data Source instance
  static AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;

  /// Get Auth Repository instance
  static AuthRepository get authRepository => _authRepository;

  /// Get Auth Bloc instance
  static AuthBloc get authBloc => _authBloc;

  /// Get Deed Remote Data Source instance
  static DeedRemoteDataSource get deedRemoteDataSource => _deedRemoteDataSource;

  /// Get Deed Repository instance
  static DeedRepository get deedRepository => _deedRepository;

  /// Get Deed Bloc instance
  static DeedBloc get deedBloc => _deedBloc;

  /// Get Penalty Remote Data Source instance
  static PenaltyRemoteDataSource get penaltyRemoteDataSource => _penaltyRemoteDataSource;

  /// Get Penalty Repository instance
  static PenaltyRepository get penaltyRepository => _penaltyRepository;

  /// Get Penalty Bloc instance
  static PenaltyBloc get penaltyBloc => _penaltyBloc;

  /// Get Payment Remote Data Source instance
  static PaymentRemoteDataSource get paymentRemoteDataSource => _paymentRemoteDataSource;

  /// Get Payment Repository instance
  static PaymentRepository get paymentRepository => _paymentRepository;

  /// Get Payment Bloc instance
  static PaymentBloc get paymentBloc => _paymentBloc;

  /// Get Admin Remote Data Source instance
  static AdminRemoteDataSource get adminRemoteDataSource => _adminRemoteDataSource;

  /// Get Admin Repository instance
  static AdminRepository get adminRepository => _adminRepository;

  /// Get Admin Bloc instance
  static AdminBloc get adminBloc => _adminBloc;

  /// Get Notification Remote Data Source instance
  static NotificationRemoteDatasource get notificationRemoteDataSource => _notificationRemoteDataSource;

  /// Get Notification Repository instance
  static NotificationRepository get notificationRepository => _notificationRepository;

  /// Get Notification Bloc instance
  static NotificationBloc get notificationBloc => _notificationBloc;

  /// Reset/dispose all dependencies (useful for testing)
  static Future<void> reset() async {
    await _authBloc.close();
    await _deedBloc.close();
    await _penaltyBloc.close();
    await _paymentBloc.close();
    await _adminBloc.close();
    await _notificationBloc.close();
    // Add any other cleanup needed
  }
}
