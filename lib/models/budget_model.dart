
import 'package:expense_tracker/features/auth/presentation/screens/category_icons.dart';
import 'package:flutter/material.dart';

class BudgetItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double budget;
  final double spent;
  final double remaining;
  final double percentage;
  final int alertPercentage;
  final int month; // 1-12
  final int year;

  BudgetItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.alertPercentage,
    required this.month,
    required this.year,
  });

  bool get isExceeded => percentage > 100 || remaining < 0;

  BudgetItem copyWith({
    String? categoryId,
    IconData? categoryIcon,
    Color? categoryColor,
  }) {
    return BudgetItem(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      alertPercentage: alertPercentage,
      month: month,
      year: year,
    );
  }

  // ← non-constant IconData ဖန်တီးနေတဲ့ old _parseIcon ကို ဖယ်ပြီး
  // shared resolveIcon() ကို အသုံးပြုမယ် (category_icons.dart ထဲက)
  static IconData _parseIcon(dynamic raw) {
    return resolveIcon(raw?.toString());
  }

  static Color _parseColor(dynamic raw) {
    String hex = (raw ?? '').toString().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    return value != null ? Color(value) : Colors.grey;
  }

  factory BudgetItem.fromJson(Map<String, dynamic> json, {required int month, required int year}) {
    double _num(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
    int _int(dynamic v) => int.tryParse(v.toString()) ?? 0;

    final double budget = _num(json['budget']);
    final double spent = _num(json['spent']);
    final double remaining = json['remaining'] != null ? _num(json['remaining']) : (budget - spent);
    final double percentage = json['expense_percentage'] != null
        ? _num(json['expense_percentage'])
        : (json['percentage'] != null ? _num(json['percentage']) : (budget > 0 ? (spent / budget) * 100 : 0));

    return BudgetItem(
      id: (json['id'] ?? '').toString(),
      categoryId: (json['category_id'] ?? '').toString(),
      categoryName: (json['category_name'] ?? json['category'] ?? 'Unknown').toString(),
      categoryIcon: _parseIcon(json['category_icon']),
      categoryColor: _parseColor(json['category_color']),
      budget: budget,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      alertPercentage: _int(json['alert_percentage']),
      month: _int(json['month'] ?? month),
      year: _int(json['year'] ?? year),
    );
  }
}