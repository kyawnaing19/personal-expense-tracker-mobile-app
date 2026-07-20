import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/balance_model.dart';

class BalanceRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<MemberBalanceModel>> getGroupBalance(String groupId) async {
    try {
      final response = await _dio.get(ApiConstants.groupBalance(groupId));
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => MemberBalanceModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching group balance: ${e.response?.data}',
          name: 'BalanceRepository');
      throw Exception(_extractError(e) ?? 'Failed to load balance');
    }
  }

  Future<MemberBalanceDetailModel> getMemberBalanceDetails({
    required String groupId,
    required String userId,
  }) async {
    try {
      final response = await _dio
          .get(ApiConstants.groupMemberBalanceDetails(groupId, userId));
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return MemberBalanceDetailModel.fromJson(data);
    } on DioException catch (e) {
      developer.log(
          '⚠️ Failed fetching member balance details: ${e.response?.data}',
          name: 'BalanceRepository');
      throw Exception(_extractError(e) ?? 'Failed to load balance detail');
    }
  }

  String? _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }
  
  Future<SettlementHistoryModel> getSettlementHistory({
  required String groupId,
  required String userId,
}) async {
  try {
    final response =
        await _dio.get(ApiConstants.groupMemberBalanceHistory(groupId, userId));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return SettlementHistoryModel.fromJson(data);
  } on DioException catch (e) {
    developer.log(
        '⚠️ Failed fetching settlement history: ${e.response?.data}',
        name: 'BalanceRepository');
    throw Exception(_extractError(e) ?? 'Failed to load settlement history');
  }
}
}

