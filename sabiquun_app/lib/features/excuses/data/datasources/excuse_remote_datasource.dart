import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/excuses/data/models/excuse_model.dart';
import 'package:sabiquun_app/features/excuses/domain/entities/excuse_entity.dart';

class ExcuseRemoteDataSource {
  final SupabaseClient _supabase;

  ExcuseRemoteDataSource(this._supabase);

  /// Create a new excuse request
  Future<ExcuseModel> createExcuse({
    required String userId,
    required DateTime excuseDate,
    required ExcuseType excuseType,
    required List<String> affectedDeeds,
    String? description,
  }) async {
    try {
      final excuseData = {
        'user_id': userId,
        'report_date': excuseDate.toIso8601String().split('T')[0],
        'excuse_type': excuseType.name,
        'affected_deeds': affectedDeeds.isEmpty ? {'all': true} : affectedDeeds,
        'description': description ?? '',
        'status': 'pending',
      };

      final response = await _supabase
          .from('excuses')
          .insert(excuseData)
          .select()
          .single();

      return ExcuseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create excuse: $e');
    }
  }

  /// Get all excuses for the current user
  Future<List<ExcuseModel>> getMyExcuses({
    required String userId,
    ExcuseStatus? status,
  }) async {
    try {
      var query = _supabase
          .from('excuses')
          .select()
          .eq('user_id', userId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final response = await query.order('report_date', ascending: false);

      return (response as List)
          .map((json) => ExcuseModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch excuses: $e');
    }
  }

  /// Get a specific excuse by ID
  Future<ExcuseModel> getExcuseById(String excuseId) async {
    try {
      final response = await _supabase
          .from('excuses')
          .select()
          .eq('id', excuseId)
          .single();

      return ExcuseModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch excuse: $e');
    }
  }

  /// Delete an excuse (only if pending)
  Future<void> deleteExcuse(String excuseId) async {
    try {
      await _supabase.from('excuses').delete().eq('id', excuseId);
    } catch (e) {
      throw Exception('Failed to delete excuse: $e');
    }
  }

  /// Check if user already has an excuse for a specific date
  Future<bool> hasExcuseForDate({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final response = await _supabase
          .from('excuses')
          .select('id')
          .eq('user_id', userId)
          .eq('report_date', date.toIso8601String().split('T')[0])
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check excuse: $e');
    }
  }
}
