import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/transaction_model.dart';

class TransactionRepository {
  final Dio _dio = DioClient.getInstance();

  // 1. [POST] Create Transaction
  Future<void> createTransaction({
    required String categoryId,
    required double amount,
    required String note,
  }) async {
    try {
      await _dio.post(
        ApiConstants.transactions,
        data: {
          'category_id': categoryId,
          'amount': amount.toInt(), 
          'note': note,
        },
      );
      developer.log('✅ Transaction Sync Success.', name: 'TransactionRepository');
    } catch (e) {
      developer.log('⚠️ Transaction Sync Failed: $e', name: 'TransactionRepository');
      throw Exception('Failed to create transaction');
    }
  }

  // 2. [GET] Get All Transactions
  Future<List<TransactionItem>> getTransactions() async {
    try {
      final response = await _dio.get(ApiConstants.transactions);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) {
          return TransactionItem(
            id: json['id'].toString(),
            categoryId: json['category_id'].toString(),
            categoryName: '', // UI ရောက်မှ Category List နှင့် ID တိုက်စစ်ပါမည်
            categoryIcon: Icons.help_outline, 
            categoryColor: Colors.grey,       
            amount: double.tryParse(json['amount'].toString()) ?? 0.0,
            note: json['note'] ?? '', 
            type: json['type']?.toString().toLowerCase() ?? 'expense', 
            createdAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      developer.log('⚠️ Failed fetching transactions: $e', name: 'TransactionRepository');
    }
    return [];
  }
}