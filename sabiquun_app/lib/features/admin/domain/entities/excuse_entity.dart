import 'package:equatable/equatable.dart';

/// Entity representing a user excuse for missed deeds
class ExcuseEntity extends Equatable {
  final String id;
  final String userId;
  final String userName; // Joined from users table
  final DateTime reportDate;
  final String excuseType; // 'sickness', 'travel', 'raining'
  final String? description;
  final Map<String, dynamic> affectedDeeds; // {"all": true} or {"deed_ids": [...]}
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime submittedAt;
  final String? reviewedBy;
  final String? reviewerName; // Joined from users table
  final DateTime? reviewedAt;
  final String? rejectionReason;

  const ExcuseEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.reportDate,
    required this.excuseType,
    this.description,
    required this.affectedDeeds,
    required this.status,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewerName,
    this.reviewedAt,
    this.rejectionReason,
  });

  /// Check if excuse affects all deeds
  bool get affectsAllDeeds {
    return affectedDeeds['all'] == true;
  }

  /// Get list of affected deed IDs (empty if affects all)
  List<String> get affectedDeedIds {
    if (affectsAllDeeds) return [];
    final deedIds = affectedDeeds['deed_ids'];
    if (deedIds is List) {
      return deedIds.cast<String>();
    }
    return [];
  }

  /// Check if excuse is pending
  bool get isPending => status == 'pending';

  /// Check if excuse is approved
  bool get isApproved => status == 'approved';

  /// Check if excuse is rejected
  bool get isRejected => status == 'rejected';

  /// Get formatted excuse type
  String get formattedExcuseType {
    switch (excuseType) {
      case 'sickness':
        return 'Sickness';
      case 'travel':
        return 'Travel';
      case 'raining':
        return 'Raining';
      default:
        return excuseType;
    }
  }

  /// Get formatted status
  String get formattedStatus {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        reportDate,
        excuseType,
        description,
        affectedDeeds,
        status,
        submittedAt,
        reviewedBy,
        reviewerName,
        reviewedAt,
        rejectionReason,
      ];
}
