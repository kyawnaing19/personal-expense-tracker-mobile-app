import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/expense_split_model.dart';

class ExpenseSplitRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<ExpenseSplitModel>> getMySplits() async {
    try {
      final response = await _dio.get(ApiConstants.mySplits);
      developer.log('RAW ${ApiConstants.mySplits} response: ${response.data}',
          name: 'ExpenseSplitRepository');
      final List<dynamic> data = response.data['data'] ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => ExpenseSplitModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching my splits: ${e.response?.data}',
          name: 'ExpenseSplitRepository');
      throw Exception(_extractError(e) ?? 'Failed to load your debts');
    }
  }

Future<void> claimPayment({
  required String splitId,
  required int amount,
}) async {
  try {
    await _dio.post(
      ApiConstants.claimPayment(splitId),
      data: {'amount': amount},
    );
  } on DioException catch (e) {
    developer.log('⚠️ Claim payment failed: ${e.response?.data}',
        name: 'ExpenseSplitRepository');
    throw Exception(_extractError(e) ?? 'Failed to claim payment');
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