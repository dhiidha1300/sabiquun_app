import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sabiquun_app/features/settings/data/models/app_content_model.dart';

/// Remote data source for app content operations
class AppContentRemoteDataSource {
  final SupabaseClient _supabase;

  AppContentRemoteDataSource(this._supabase);

  /// Get all published app content items
  Future<List<AppContentModel>> getAllPublishedContent() async {
    try {
      final response = await _supabase
          .from('app_content')
          .select('*')
          .eq('is_published', true)
          .order('title', ascending: true);

      final contentList = response as List;

      if (contentList.isEmpty) {
        // print('No content found in app_content table');
        return [];
      }

      // print('Found ${contentList.length} content items');

      return contentList.map((json) {
        try {
          return AppContentModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          // print('Error parsing app content item: $e');
          // print('JSON data: $json');
          rethrow;
        }
      }).toList();
    } catch (e) {
      // print('Error in getAllPublishedContent: $e');
      throw Exception('Failed to fetch app content: $e');
    }
  }

  /// Get app content by content key
  Future<AppContentModel?> getContentByKey(String contentKey) async {
    try {
      final response = await _supabase
          .from('app_content')
          .select('*')
          .eq('content_key', contentKey)
          .eq('is_published', true)
          .maybeSingle();

      if (response == null) return null;

      return AppContentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch content by key: $e');
    }
  }

  /// Get specific content items by keys (for specific pages like rules)
  Future<List<AppContentModel>> getContentByKeys(List<String> contentKeys) async {
    try {
      final response = await _supabase
          .from('app_content')
          .select('*')
          .inFilter('content_key', contentKeys)
          .eq('is_published', true)
          .order('title', ascending: true);

      final contentList = response as List;
      return contentList.map((json) => AppContentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch content by keys: $e');
    }
  }
}
