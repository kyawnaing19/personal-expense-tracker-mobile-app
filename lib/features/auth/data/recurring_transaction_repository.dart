import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/recurring_transaction_model.dart';

class RecurringTransactionRepository {
  final Dio _dio = DioClient.getInstance();

  String _fmtDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<RecurringTransactionItem> createRecurringTransaction({
    required String categoryId,
    required double amount,
    required String frequency, 
    required DateTime startDate,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.recurringTransactions,
        queryParameters: {
          'amount': amount.toInt(),
          'category_id': categoryId,
          'start_date': _fmtDate(startDate),
          'frequency': frequency,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
      developer.log('✅ Recurring Transaction Created.', name: 'RecurringTransactionRepository');
      return RecurringTransactionItem.fromJson(response.data['data']);
    } catch (e) {
      developer.log('⚠️ Failed to create recurring transaction: $e', name: 'RecurringTransactionRepository');
      throw Exception('Failed to create recurring transaction');
    }
  }

  Future<List<RecurringTransactionItem>> getRecurringTransactions({
    String? type, 
    String? categoryId,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.recurringTransactions,
        queryParameters: {
          if (type != null && type.toLowerCase() != 'all') 'type': type.toLowerCase(),
          if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => RecurringTransactionItem.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('⚠️ Failed fetching recurring transactions: $e', name: 'RecurringTransactionRepository');
    }
    return [];
  }
  Future<void> updateRecurringTransaction({
    required String id,
    required String categoryId,
    required double amount,
    required String frequency,
    required DateTime startDate,
    String? note,
  }) async {
    try {
      await _dio.put(
        '${ApiConstants.recurringTransactions}/$id',
        queryParameters: {
          'amount': amount.toInt(),
          'category_id': categoryId,
          'start_date': _fmtDate(startDate),
          'frequency': frequency,
          if (note != null) 'note': note.trim(),
        },
      );
      developer.log('✅ Recurring Transaction Updated.', name: 'RecurringTransactionRepository');
    } catch (e) {
      developer.log('⚠️ Failed to update recurring transaction: $e', name: 'RecurringTransactionRepository');
      throw Exception('Failed to update recurring transaction');
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    try {
      await _dio.delete('${ApiConstants.recurringTransactions}/$id');
      developer.log('✅ Recurring Transaction Deleted.', name: 'RecurringTransactionRepository');
    } catch (e) {
      developer.log('⚠️ Failed to delete recurring transaction: $e', name: 'RecurringTransactionRepository');
      throw Exception('Failed to delete recurring transaction');
    }
  }
}
