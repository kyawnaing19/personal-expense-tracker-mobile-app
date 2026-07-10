import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class AnalyticsRepository {
  final Dio _dio = DioClient.getInstance();

  Future<Map<String, dynamic>> getCategoryBreakdown({
    required String filter,
    required String type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'filter': filter,
        'type': type,
      };

      if (startDate != null) {
        final formatted = startDate.toIso8601String().split('T').first;
        queryParams['start_date'] = formatted;
        queryParams['from'] = formatted;
      }
      if (endDate != null) {
        final formatted = endDate.toIso8601String().split('T').first;
        queryParams['end_date'] = formatted;
        queryParams['to'] = formatted;
      }

      final response = await _dio.get(
        ApiConstants.analytics,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['success'] == false) {
          developer.log('⚠️ Analytics API returned success:false — ${data['message']}',
              name: 'AnalyticsRepository');
          throw Exception(data['message'] ?? 'Failed to load analytics data');
        }
        developer.log('✅ Analytics Sync Success.', name: 'AnalyticsRepository');
        return data;
      }
    } catch (e) {
      developer.log('⚠️ Analytics Sync Failed: $e', name: 'AnalyticsRepository');
      throw Exception('Failed to load analytics data');
    }
    return {};
  }

  Future<List<dynamic>> getAnnualSummary() async {
    try {
      final response = await _dio.get(ApiConstants.annualSummary);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['success'] == true) {
          developer.log('✅ Annual Summary Sync Success.', name: 'AnalyticsRepository');
          return data['data'] as List<dynamic>? ?? [];
        }
      }
    } catch (e) {
      developer.log('⚠️ Annual Summary Fetch Failed: $e', name: 'AnalyticsRepository');
    }
    return [];
  }
}