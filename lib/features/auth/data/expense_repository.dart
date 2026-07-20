
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/expense_model.dart';

class ExpenseSplitInput {
  final String userId;
  final int amountOwed;

  ExpenseSplitInput({required this.userId, required this.amountOwed});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'amount_owed': amountOwed,
      };
}

class ExpenseRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<ExpenseModel>> getGroupExpenses(String groupId) async {
    try {
      final response =
          await _dio.get(ApiConstants.groupExpensesList(groupId));
      developer.log('RAW /groups/$groupId/expenses response: ${response.data}', name: 'ExpenseRepository');
      final rawData = response.data['data'];
      final List<dynamic> data = rawData is List
          ? rawData
          : (rawData is Map && rawData['data'] is List)
              ? rawData['data'] as List
              : [];
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching expenses: ${e.response?.data}',
          name: 'ExpenseRepository');
      throw Exception(_extractError(e) ?? 'Failed to load expenses');
    }
  }

  Future<ExpenseModel> createExpense({
    required String groupId,
    required int amount,
    String? description,
    String? categoryId,
    required DateTime expenseDate,
    required String splitType, 
    bool? includePayer,
    List<ExpenseSplitInput>? splits,
  }) async {
    try {
      final body = <String, dynamic>{
        'group_id': groupId,
        'amount': amount,
        'expense_date': _formatDate(expenseDate),
        'split_type': splitType,
      };
      if (description != null && description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        body['category_id'] = categoryId;
      }
      if (splitType == 'equally' && includePayer != null) {
        body['include_payer'] = includePayer;
      }
      if (splitType == 'custom' && splits != null) {
        body['splits'] = splits.map((s) => s.toJson()).toList();
      }

      final response =
          await _dio.post(ApiConstants.groupExpenses, data: body);
      developer.log('✅ Expense Created.', name: 'ExpenseRepository');
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Expense Create Failed: ${e.response?.data}',
          name: 'ExpenseRepository');
      throw Exception(_extractError(e) ?? 'Failed to create expense');
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<ExpenseModel> getExpenseDetail(String expenseId) async {
    try {
      final response =
          await _dio.get(ApiConstants.groupExpenseDetail(expenseId));
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching expense detail: ${e.response?.data}',
          name: 'ExpenseRepository');
      throw Exception(_extractError(e) ?? 'Failed to load expense detail');
    }
  }

  Future<ExpenseModel> updateExpense({
    required String expenseId,
    required int amount,
    String? description,
    String? categoryId,
    required DateTime expenseDate,
    required String splitType, 
    bool? includePayer,
    List<ExpenseSplitInput>? splits,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'expense_date': _formatDate(expenseDate),
        'split_type': splitType,
      };
      if (description != null && description.trim().isNotEmpty) {
        body['description'] = description.trim();
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        body['category_id'] = categoryId;
      }
      if (splitType == 'equally' && includePayer != null) {
        body['include_payer'] = includePayer;
      }
      if (splitType == 'custom' && splits != null) {
        body['splits'] = splits.map((s) => s.toJson()).toList();
      }

      final response = await _dio.put(
          ApiConstants.groupExpenseDetail(expenseId),
          data: body);
      developer.log('✅ Expense Updated.', name: 'ExpenseRepository');
      return ExpenseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Expense Update Failed: ${e.response?.data}',
          name: 'ExpenseRepository');
      throw Exception(_extractError(e) ?? 'Failed to update expense');
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _dio.delete(ApiConstants.groupExpenseDetail(expenseId));
      developer.log('✅ Expense Deleted.', name: 'ExpenseRepository');
    } on DioException catch (e) {
      developer.log('⚠️ Expense Delete Failed: ${e.response?.data}',
          name: 'ExpenseRepository');
      throw Exception(_extractError(e) ?? 'Failed to delete expense');
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