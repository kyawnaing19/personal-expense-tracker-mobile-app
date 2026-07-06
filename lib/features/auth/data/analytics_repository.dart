
// import 'dart:developer' as developer;
// import 'package:dio/dio.dart';
// import 'package:intl/intl.dart'; // 👈 နေ့စွဲ format အတွက် ထည့်ပါ
// import '../../../core/network/dio_client.dart';
// import '../../../core/constants/api_constants.dart';

// class AnalyticsRepository {
//   final Dio _dio = DioClient.getInstance();

//   Future<Map<String, dynamic>> getCategoryBreakdown({
//     required String filter, 
//     required String type,
//     DateTime? startDate, 
//     DateTime? endDate,
//   }) async {
//     try {
//       final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
//       // queryParameters ကို Dynamic တည်ဆောက်ခြင်း
//       final Map<String, dynamic> params = {'filter': filter, 'type': type};
//     if (startDate != null) params['start_date'] = DateFormat('yyyy-MM-dd').format(startDate);
//     if (endDate != null) params['end_date'] = DateFormat('yyyy-MM-dd').format(endDate);

//     final response = await _dio.get(
//       ApiConstants.analytics,
//       queryParameters: params,
//     );

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
    DateTime? startDate, // 🆕 [FIX] bloc ကနေ ခေါ်နေပေမယ့် ရှေ့က မလက်ခံထားလို့ ဖြည့်ထား
    DateTime? endDate,   // 🆕 [FIX]
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'filter': filter,
        'type': type,
      };

      // Custom date range ရွေးထားရင် start/end ကို ထပ်ထည့်ပို့ပါ
      if (startDate != null) {
        queryParams['start_date'] =
            startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T').first;
      }

      final response = await _dio.get(
        ApiConstants.analytics,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        developer.log('✅ Analytics Sync Success.', name: 'AnalyticsRepository');
        return response.data;
      }
    } catch (e) {
      developer.log('⚠️ Analytics Sync Failed: $e', name: 'AnalyticsRepository');
      throw Exception('Failed to load analytics data');
    }
    return {};
  }
}