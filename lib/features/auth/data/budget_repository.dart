import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/budget_model.dart';
import 'category_repository.dart';

class BudgetRepository {
  final Dio _dio = DioClient.getInstance();
  final CategoryRepository _categoryRepository;

  BudgetRepository(this._categoryRepository);

  // 1. [GET] Budgets overview for a given month/year
  Future<List<BudgetItem>> getBudgets({required int month, required int year}) async {
    try {
      final response = await _dio.get(
        ApiConstants.budgetsOverview,
        queryParameters: {'month': month, 'year': year},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final categories = await _categoryRepository.getCategories();

        return data.map((json) {
          BudgetItem item = BudgetItem.fromJson(json, month: month, year: year);

          // The overview endpoint doesn't return category_id (needed for Edit/Update),
          // so backfill it by matching the category name against the cached list.
          if (item.categoryId.isEmpty) {
            final match = categories.where(
              (c) => c.name.toLowerCase() == item.categoryName.toLowerCase(),
            );
            if (match.isNotEmpty) {
              item = item.copyWith(categoryId: match.first.id);
            }
          }
          return item;
        }).toList();
      }
    } catch (e) {
      developer.log('⚠️ Failed fetching budgets: $e', name: 'BudgetRepository');
    }
    return [];
  }

  // 2. [POST] Create a new budget
  Future<void> createBudget({
    required String categoryId,
    required double amount,
    required int alertPercentage,
    required int month,
    required int year,
  }) async {
    try {
      await _dio.post(
        ApiConstants.budgets,
        data: {
          'category_id': categoryId,
          'amount': amount.toInt(),
          'alert_percentage': alertPercentage,
          'month': month,
          'year': year,
        },
      );
      developer.log('✅ Budget Created.', name: 'BudgetRepository');
    } on DioException catch (e) {
      developer.log('⚠️ Budget Create Failed: ${e.response?.data}', name: 'BudgetRepository');
      throw Exception(_extractError(e) ?? 'Failed to set budget');
    }
  }

  // 3. [PUT] Update an existing budget (month cannot be changed)
  Future<void> updateBudget({
    required String id,
    required String categoryId,
    required double amount,
    required int alertPercentage,
  }) async {
    try {
      await _dio.put(
        '${ApiConstants.budgets}/$id',
        data: {
          'category_id': categoryId,
          'amount': amount.toInt(),
          'alert_percentage': alertPercentage,
        },
      );
      developer.log('✅ Budget Updated.', name: 'BudgetRepository');
    } on DioException catch (e) {
      developer.log('⚠️ Budget Update Failed: ${e.response?.data}', name: 'BudgetRepository');
      throw Exception(_extractError(e) ?? 'Failed to update budget');
    }
  }

  // 4. [DELETE] Remove a budget
  Future<void> deleteBudget(String id) async {
    try {
      await _dio.delete('${ApiConstants.budgets}/$id');
      developer.log('✅ Budget Deleted.', name: 'BudgetRepository');
    } on DioException catch (e) {
      developer.log('⚠️ Budget Delete Failed: ${e.response?.data}', name: 'BudgetRepository');
      throw Exception(_extractError(e) ?? 'Failed to delete budget');
    }
  }

  String? _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) return data['message'].toString();
    return null;
  }
}