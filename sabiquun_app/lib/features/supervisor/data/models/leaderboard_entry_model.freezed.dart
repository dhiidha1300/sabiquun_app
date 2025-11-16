// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leaderboard_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LeaderboardEntryModel _$LeaderboardEntryModelFromJson(
  Map<String, dynamic> json,
) {
  return _LeaderboardEntryModel.fromJson(json);
}

/// @nodoc
mixin _$LeaderboardEntryModel {
  int get rank => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  String get membershipStatus => throw _privateConstructorUsedError;
  double get averageDeeds => throw _privateConstructorUsedError;
  double get complianceRate => throw _privateConstructorUsedError;
  List<String> get achievementTags => throw _privateConstructorUsedError;
  bool get hasFajrChampion => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;

  /// Serializes this LeaderboardEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaderboardEntryModelCopyWith<LeaderboardEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaderboardEntryModelCopyWith<$Res> {
  factory $LeaderboardEntryModelCopyWith(
    LeaderboardEntryModel value,
    $Res Function(LeaderboardEntryModel) then,
  ) = _$LeaderboardEntryModelCopyWithImpl<$Res, LeaderboardEntryModel>;
  @useResult
  $Res call({
    int rank,
    String userId,
    String fullName,
    String? profilePhotoUrl,
    String membershipStatus,
    double averageDeeds,
    double complianceRate,
    List<String> achievementTags,
    bool hasFajrChampion,
    int currentStreak,
  });
}

/// @nodoc
class _$LeaderboardEntryModelCopyWithImpl<
  $Res,
  $Val extends LeaderboardEntryModel
>
    implements $LeaderboardEntryModelCopyWith<$Res> {
  _$LeaderboardEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
    Object? membershipStatus = null,
    Object? averageDeeds = null,
    Object? complianceRate = null,
    Object? achievementTags = null,
    Object? hasFajrChampion = null,
    Object? currentStreak = null,
  }) {
    return _then(
      _value.copyWith(
            rank: null == rank
                ? _value.rank
                : rank // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePhotoUrl: freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            membershipStatus: null == membershipStatus
                ? _value.membershipStatus
                : membershipStatus // ignore: cast_nullable_to_non_nullable
                      as String,
            averageDeeds: null == averageDeeds
                ? _value.averageDeeds
                : averageDeeds // ignore: cast_nullable_to_non_nullable
                      as double,
            complianceRate: null == complianceRate
                ? _value.complianceRate
                : complianceRate // ignore: cast_nullable_to_non_nullable
                      as double,
            achievementTags: null == achievementTags
                ? _value.achievementTags
                : achievementTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            hasFajrChampion: null == hasFajrChampion
                ? _value.hasFajrChampion
                : hasFajrChampion // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaderboardEntryModelImplCopyWith<$Res>
    implements $LeaderboardEntryModelCopyWith<$Res> {
  factory _$$LeaderboardEntryModelImplCopyWith(
    _$LeaderboardEntryModelImpl value,
    $Res Function(_$LeaderboardEntryModelImpl) then,
  ) = __$$LeaderboardEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int rank,
    String userId,
    String fullName,
    String? profilePhotoUrl,
    String membershipStatus,
    double averageDeeds,
    double complianceRate,
    List<String> achievementTags,
    bool hasFajrChampion,
    int currentStreak,
  });
}

/// @nodoc
class __$$LeaderboardEntryModelImplCopyWithImpl<$Res>
    extends
        _$LeaderboardEntryModelCopyWithImpl<$Res, _$LeaderboardEntryModelImpl>
    implements _$$LeaderboardEntryModelImplCopyWith<$Res> {
  __$$LeaderboardEntryModelImplCopyWithImpl(
    _$LeaderboardEntryModelImpl _value,
    $Res Function(_$LeaderboardEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rank = null,
    Object? userId = null,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
    Object? membershipStatus = null,
    Object? averageDeeds = null,
    Object? complianceRate = null,
    Object? achievementTags = null,
    Object? hasFajrChampion = null,
    Object? currentStreak = null,
  }) {
    return _then(
      _$LeaderboardEntryModelImpl(
        rank: null == rank
            ? _value.rank
            : rank // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePhotoUrl: freezed == profilePhotoUrl
            ? _value.profilePhotoUrl
            : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        membershipStatus: null == membershipStatus
            ? _value.membershipStatus
            : membershipStatus // ignore: cast_nullable_to_non_nullable
                  as String,
        averageDeeds: null == averageDeeds
            ? _value.averageDeeds
            : averageDeeds // ignore: cast_nullable_to_non_nullable
                  as double,
        complianceRate: null == complianceRate
            ? _value.complianceRate
            : complianceRate // ignore: cast_nullable_to_non_nullable
                  as double,
        achievementTags: null == achievementTags
            ? _value._achievementTags
            : achievementTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        hasFajrChampion: null == hasFajrChampion
            ? _value.hasFajrChampion
            : hasFajrChampion // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaderboardEntryModelImpl extends _LeaderboardEntryModel {
  const _$LeaderboardEntryModelImpl({
    required this.rank,
    required this.userId,
    required this.fullName,
    this.profilePhotoUrl,
    required this.membershipStatus,
    required this.averageDeeds,
    required this.complianceRate,
    required final List<String> achievementTags,
    required this.hasFajrChampion,
    required this.currentStreak,
  }) : _achievementTags = achievementTags,
       super._();

  factory _$LeaderboardEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaderboardEntryModelImplFromJson(json);

  @override
  final int rank;
  @override
  final String userId;
  @override
  final String fullName;
  @override
  final String? profilePhotoUrl;
  @override
  final String membershipStatus;
  @override
  final double averageDeeds;
  @override
  final double complianceRate;
  final List<String> _achievementTags;
  @override
  List<String> get achievementTags {
    if (_achievementTags is EqualUnmodifiableListView) return _achievementTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievementTags);
  }

  @override
  final bool hasFajrChampion;
  @override
  final int currentStreak;

  @override
  String toString() {
    return 'LeaderboardEntryModel(rank: $rank, userId: $userId, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl, membershipStatus: $membershipStatus, averageDeeds: $averageDeeds, complianceRate: $complianceRate, achievementTags: $achievementTags, hasFajrChampion: $hasFajrChampion, currentStreak: $currentStreak)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaderboardEntryModelImpl &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.membershipStatus, membershipStatus) ||
                other.membershipStatus == membershipStatus) &&
            (identical(other.averageDeeds, averageDeeds) ||
                other.averageDeeds == averageDeeds) &&
            (identical(other.complianceRate, complianceRate) ||
                other.complianceRate == complianceRate) &&
            const DeepCollectionEquality().equals(
              other._achievementTags,
              _achievementTags,
            ) &&
            (identical(other.hasFajrChampion, hasFajrChampion) ||
                other.hasFajrChampion == hasFajrChampion) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rank,
    userId,
    fullName,
    profilePhotoUrl,
    membershipStatus,
    averageDeeds,
    complianceRate,
    const DeepCollectionEquality().hash(_achievementTags),
    hasFajrChampion,
    currentStreak,
  );

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaderboardEntryModelImplCopyWith<_$LeaderboardEntryModelImpl>
  get copyWith =>
      __$$LeaderboardEntryModelImplCopyWithImpl<_$LeaderboardEntryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaderboardEntryModelImplToJson(this);
  }
}

abstract class _LeaderboardEntryModel extends LeaderboardEntryModel {
  const factory _LeaderboardEntryModel({
    required final int rank,
    required final String userId,
    required final String fullName,
    final String? profilePhotoUrl,
    required final String membershipStatus,
    required final double averageDeeds,
    required final double complianceRate,
    required final List<String> achievementTags,
    required final bool hasFajrChampion,
    required final int currentStreak,
  }) = _$LeaderboardEntryModelImpl;
  const _LeaderboardEntryModel._() : super._();

  factory _LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =
      _$LeaderboardEntryModelImpl.fromJson;

  @override
  int get rank;
  @override
  String get userId;
  @override
  String get fullName;
  @override
  String? get profilePhotoUrl;
  @override
  String get membershipStatus;
  @override
  double get averageDeeds;
  @override
  double get complianceRate;
  @override
  List<String> get achievementTags;
  @override
  bool get hasFajrChampion;
  @override
  int get currentStreak;

  /// Create a copy of LeaderboardEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaderboardEntryModelImplCopyWith<_$LeaderboardEntryModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
