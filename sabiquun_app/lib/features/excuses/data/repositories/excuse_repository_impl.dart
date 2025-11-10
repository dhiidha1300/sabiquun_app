import 'package:sabiquun_app/features/excuses/data/datasources/excuse_remote_datasource.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';
import 'package:sabiquun_app/features/excuses/domain/repositories/excuse_repository.dart';

class ExcuseRepositoryImpl implements ExcuseRepository {
  final ExcuseRemoteDataSource remoteDataSource;

  ExcuseRepositoryImpl(this.remoteDataSource);

  @override
  Future<ExcuseEntity> createExcuse({
    required String userId,
    required DateTime excuseDate,
    required ExcuseType excuseType,
    required List<String> affectedDeeds,
    String? description,
  }) async {
    try {
      final excuse = await remoteDataSource.createExcuse(
        userId: userId,
        excuseDate: excuseDate,
        excuseType: excuseType,
        affectedDeeds: affectedDeeds,
        description: description,
      );
      return excuse.toEntity();
    } catch (e) {
      throw Exception('Failed to create excuse: $e');
    }
  }

  @override
  Future<List<ExcuseEntity>> getMyExcuses({
    required String userId,
    ExcuseStatus? status,
  }) async {
    try {
      final excuses = await remoteDataSource.getMyExcuses(
        userId: userId,
        status: status,
      );
      return excuses.map((excuse) => excuse.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch excuses: $e');
    }
  }

  @override
  Future<ExcuseEntity> getExcuseById(String excuseId) async {
    try {
      final excuse = await remoteDataSource.getExcuseById(excuseId);
      return excuse.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch excuse: $e');
    }
  }

  @override
  Future<void> deleteExcuse(String excuseId) async {
    try {
      await remoteDataSource.deleteExcuse(excuseId);
    } catch (e) {
      throw Exception('Failed to delete excuse: $e');
    }
  }

  @override
  Future<bool> hasExcuseForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      return await remoteDataSource.hasExcuseForDate(
        userId: userId,
        date: date,
      );
    } catch (e) {
      throw Exception('Failed to check excuse: $e');
    }
  }
}
