// import 'dart:developer' as developer;
// import 'package:dio/dio.dart';
// import '../../../core/network/dio_client.dart';
// import '../../../core/constants/api_constants.dart';

// class AnalyticsRepository {
//   final Dio _dio = DioClient.getInstance();

//   Future<Map<String, dynamic>> getCategoryBreakdown({
//     required String filter,
//     required String type,
//     DateTime? startDate, // 🆕 [FIX] bloc ကနေ ခေါ်နေပေမယ့် ရှေ့က မလက်ခံထားလို့ ဖြည့်ထား
//     DateTime? endDate,   // 🆕 [FIX]
//   }) async {
//     try {
//       final queryParams = <String, dynamic>{
//         'filter': filter,
//         'type': type,
//       };

//       // Custom date range ရွေးထားရင် start/end ကို ထပ်ထည့်ပို့ပါ
//       if (startDate != null) {
//         queryParams['start_date'] =
//             startDate.toIso8601String().split('T').first;
//       }
//       if (endDate != null) {
//         queryParams['end_date'] = endDate.toIso8601String().split('T').first;
//       }

//       final response = await _dio.get(
//         ApiConstants.analytics,
//         queryParameters: queryParams,
//       );

//       if (response.statusCode == 200) {
//         developer.log('✅ Analytics Sync Success.', name: 'AnalyticsRepository');
//         return response.data;
//       }
//     } catch (e) {
//       developer.log('⚠️ Analytics Sync Failed: $e', name: 'AnalyticsRepository');
//       throw Exception('Failed to load analytics data');
//     }
//     return {};
//   }
// }


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

      // 🆕 [FIX] Backend's `custom` branch reads $filters['from'] / $filters['to']
      // (see reports/category-breakdown controller), not start_date/end_date.
      // That mismatch was causing "Undefined array key \"from\"" and an
      // empty/failed response, so the pie chart never updated for a custom
      // range. We now send BOTH naming conventions so it works regardless
      // of which key the endpoint ends up reading.
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
        // Backend can return HTTP 200 with {"success": false, "message": ...}
        // when a required param is missing — surface that instead of silently
        // treating it as a successful-but-empty response.
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
  // analytics_repository.dart ထဲ class ရဲ့ အောက်ဆုံးမှာ ထပ်ထည့်ပါ
// 🆕 [FIX] Backend က query param လုံးဝမလိုပါ — ခေါ်လိုက်ရင်ရှိသမျှ
  // month data ကို ပြန်ပေးပါတယ် (Postman screenshot အတိုင်း)
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