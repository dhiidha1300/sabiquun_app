import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/core/config/env_config.dart';
import 'package:sabiquun_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:sabiquun_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sabiquun_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:sabiquun_app/features/auth/presentation/bloc/auth_bloc.dart';
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

  /// Reset/dispose all dependencies (useful for testing)
  static Future<void> reset() async {
    await _authBloc.close();
    // Add any other cleanup needed
  }
}
