import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/settlement_request_model.dart';

class SettlementRequestRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<SettlementRequestModel>> getSettlementRequests({
    required SettlementRequestRole role,
    SettlementRequestStatus? status,
  }) async {
    try {
      final query = <String, dynamic>{'role': role.apiValue};
      if (status != null) {
        query['status'] = status.apiValue;
      }
      final response = await _dio.get(
        ApiConstants.settlementRequests,
        queryParameters: query,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => SettlementRequestModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching settlement requests: ${e.response?.data}',
          name: 'SettlementRequestRepository');
      throw Exception(_extractError(e) ?? 'Failed to load debt requests');
    }
  }
    Future<void> confirmRequest(String requestId) async {
    try {
      await _dio.post(ApiConstants.confirmSettlementRequest(requestId));
    } on DioException catch (e) {
      developer.log('⚠️ Failed confirming settlement request: ${e.response?.data}',
          name: 'SettlementRequestRepository');
      throw Exception(_extractError(e) ?? 'Failed to confirm request');
    }
  }


  Future<void> rejectRequest(String requestId) async {
    try {
      await _dio.post(ApiConstants.rejectSettlementRequest(requestId));
    } on DioException catch (e) {
      developer.log('⚠️ Failed rejecting settlement request: ${e.response?.data}',
          name: 'SettlementRequestRepository');
      throw Exception(_extractError(e) ?? 'Failed to reject request');
    }
  }

  String? _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }
}