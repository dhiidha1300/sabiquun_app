import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/payment_method_entity.dart';

part 'payment_method_model.freezed.dart';

@freezed
class PaymentMethodModel with _$PaymentMethodModel {
  const PaymentMethodModel._();

  const factory PaymentMethodModel({
    required String id,
    required String name,
    required String displayName,
    required bool isActive,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PaymentMethodModel;

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['method_name'] as String,
      displayName: json['display_name'] as String,
      isActive: json['is_active'] as bool,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      name: name,
      displayName: displayName,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
