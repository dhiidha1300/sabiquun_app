import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/auth/data/models/user_model.dart';

/// Remote data source for authentication using Supabase
class AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSource(this._supabase);

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Fetch user details from users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign up with user details
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      // Create auth user
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Create user profile in users table
      final userData = await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'profile_photo_url': profilePhotoUrl,
        'role': 'user', // Default role
        'account_status': 'pending', // Awaiting admin approval
      }).select().single();

      return UserModel.fromJson(userData);
    } on AuthException catch (e) {
      throw Exception('Authentication error: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Get current user details
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _supabase.auth.currentUser != null;
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      final response = await _supabase.auth.refreshSession();
      return response.session != null;
    } catch (e) {
      return false;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Password reset error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw Exception('Password update error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (profilePhotoUrl != null) {
        updates['profile_photo_url'] = profilePhotoUrl;
      }

      final userData = await _supabase
          .from('users')
          .update(updates)
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final result = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return result != null;
    } catch (e) {
      return false;
    }
  }
}
