import 'package:flutter/material.dart';

class TransactionItem {
  String id;
  String categoryId;
  String categoryName;
  IconData categoryIcon;
  Color categoryColor;
  double amount;
  String note;
  String type; // 'expense' သို့မဟုတ် 'income'
  DateTime createdAt;

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