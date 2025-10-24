import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sabiquun_app/core/constants/user_role.dart';
import 'package:sabiquun_app/core/constants/account_status.dart';
import 'package:sabiquun_app/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User model for data layer with JSON serialization
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String? phoneNumber,
    @JsonKey(name: 'profile_photo_url') required String? profilePhotoUrl,
    required String role,
    @JsonKey(name: 'account_status') required String accountStatus,
    @JsonKey(name: 'created_at') required DateTime? createdAt,
    @JsonKey(name: 'last_login_at') required DateTime? lastLoginAt,
  }) = _UserModel;

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Convert to domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePhotoUrl: profilePhotoUrl,
      role: UserRole.fromString(role),
      accountStatus: AccountStatus.fromString(accountStatus),
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create UserModel from entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      profilePhotoUrl: entity.profilePhotoUrl,
      role: entity.role.value,
      accountStatus: entity.accountStatus.value,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }
}
