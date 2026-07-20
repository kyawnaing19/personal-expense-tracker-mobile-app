import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/pending_recurring_transaction_model.dart';

class PendingTransactionRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<PendingRecurringTransaction>> getPendingTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.transactionsRecurring);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((json) => PendingRecurringTransaction.fromJson(json))
            .where((tx) => tx.status == 'pending')
            .toList();
      }
    } catch (e) {
      developer.log('⚠️ Failed fetching pending recurring transactions: $e',
          name: 'PendingTransactionRepository');
    }
    return [];
  }

  Future<void> acceptTransaction(String id) async {
    try {
      await _dio.post(ApiConstants.acceptTransaction(id));
      developer.log('✅ Recurring occurrence accepted: $id', name: 'PendingTransactionRepository');
    } catch (e) {
      developer.log('⚠️ Failed to accept transaction $id: $e', name: 'PendingTransactionRepository');
      throw Exception('Failed to accept transaction');
    }
  }

  Future<void> rejectTransaction(String id) async {
    try {
      await _dio.post(ApiConstants.rejectTransaction(id));
      developer.log('✅ Recurring occurrence rejected: $id', name: 'PendingTransactionRepository');
    } catch (e) {
      developer.log('⚠️ Failed to reject transaction $id: $e', name: 'PendingTransactionRepository');
      throw Exception('Failed to reject transaction');
    }
  }
}