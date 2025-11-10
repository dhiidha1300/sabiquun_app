import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';

abstract class ExcuseRepository {
  Future<ExcuseEntity> createExcuse({
    required String userId,
    required DateTime excuseDate,
    required ExcuseType excuseType,
    required List<String> affectedDeeds,
    String? description,
  });

  Future<List<ExcuseEntity>> getMyExcuses({
    required String userId,
    ExcuseStatus? status,
  });

  Future<ExcuseEntity> getExcuseById(String excuseId);

  Future<void> deleteExcuse(String excuseId);

  Future<bool> hasExcuseForDate({
    required String userId,
    required DateTime date,
  });
}
