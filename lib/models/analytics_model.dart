import 'package:flutter/material.dart';

class AnalyticsData {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final Color color;

  AnalyticsData({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.color,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    String colorHex = json['color'] ?? '#6366F1';
    colorHex = colorHex.replaceAll('#', '');
    if (colorHex.length == 6) colorHex = "FF$colorHex";
    Color parsedColor = Color(int.parse("0x$colorHex"));

    return AnalyticsData(
      categoryName: json['category'] ?? 'Unknown',
      totalAmount: double.tryParse(json['amount'].toString()) ?? 0.0,
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
      color: parsedColor,
    );
  }
}

class MonthlyBarData {
  final String monthName;
  final double amount;

  MonthlyBarData({required this.monthName, required this.amount});

  factory MonthlyBarData.fromJson(Map<String, dynamic> json) {
    return MonthlyBarData(
      monthName: json['month'] ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  }
}

class AnalyticsResponse {
  final double overallTotal;
  final List<AnalyticsData> breakdown;
  final List<MonthlyBarData> monthlyData;

  // 🆕 [FIX] Stale-data bug ကို ဖြေရှင်းဖို့ ဒီ data က ဘယ် selection
  // (type/period/subPeriod) အတွက် fetch လုပ်ခဲ့တာလဲဆိုတာ မှတ်ထားရန်
  final String type;
  final String period;
  final String subPeriod;

  AnalyticsResponse({
    required this.overallTotal,
    required this.breakdown,
    this.monthlyData = const [],
    required this.type,
    required this.period,
    required this.subPeriod,
  });
}