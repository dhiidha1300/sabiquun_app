import 'package:equatable/equatable.dart';

class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String displayName;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        displayName,
        isActive,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}
