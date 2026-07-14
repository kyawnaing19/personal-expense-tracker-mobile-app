import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/settlement_request_model.dart';

class SettlementRequestRepository {
  final Dio _dio = DioClient.getInstance();

  // 1. [GET] /settlement-requests?role=payer|claimant&status=pending|confirmed|rejected
  // role=payer  -> "Received Requests" (ကိုယ်က ငွေရှင်၊ confirm/reject လုပ်ရမယ့်ဘက်)
  // role=claimant -> "Sent Requests" (ကိုယ်တိုင် settle request တင်ခဲ့တဲ့ဘက်)
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

  // 2. [POST] /settlement-requests/{requestId}/confirm
  // "Received Requests" card ပေါ်က "Confirm" ခလုတ်
  Future<void> confirmRequest(String requestId) async {
    try {
      await _dio.post(ApiConstants.confirmSettlementRequest(requestId));
    } on DioException catch (e) {
      developer.log('⚠️ Failed confirming settlement request: ${e.response?.data}',
          name: 'SettlementRequestRepository');
      throw Exception(_extractError(e) ?? 'Failed to confirm request');
    }
  }

  // 3. [POST] /settlement-requests/{requestId}/reject
  // "Received Requests" card ပေါ်က "Reject" ခလုတ်
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