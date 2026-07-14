import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/expense_split_model.dart';

class ExpenseSplitRepository {
  final Dio _dio = DioClient.getInstance();

  // 1. [GET] /groups/expenses/splits
  // Profile > Settle Debt screen ဝင်တာနဲ့ login ဝင်ထားသူနဲ့ သက်ဆိုင်တဲ့
  // (group အားလုံးပေါင်း) ကျန်နေသေးတဲ့ debt (split) အားလုံးကိုခေါ်တယ်
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

  // 2. [POST] /expense-splits/{splitId}/claim-payment?amount=xxx
  // "Settle Now" -> Pay Amount dialog ထဲက "Done" ကိုနှိပ်လိုက်ရင်ခေါ်တယ်
  // claim-payment API ရဲ့ response data ဟာ ExpenseSplitModel မဟုတ်ဘဲ
// SettlementRequest object ({expense_split_id, claimed_by, amount,
// status, id, created_at, updated_at}) ဖြစ်နေလို့ ဒီနေရာမှာ split
// model အနေနဲ့ parse မလုပ်တော့ပါဘူး - claim တင်အောင်မြင်ကြောင်းကိုပဲ
// confirm လိုက်တာပါ (Future<void>)
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