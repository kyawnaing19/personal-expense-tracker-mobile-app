import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final double amount;
  final String note;
  final String type; // 'expense' သို့မဟုတ် 'income'
  final DateTime createdAt;

  TransactionItem({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.note,
    required this.type,
    required this.createdAt,
  });
}