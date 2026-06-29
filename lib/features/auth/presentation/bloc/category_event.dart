import 'package:flutter/material.dart';

abstract class CategoryEvent {}

// 1. Category အားလုံးကို ဆွဲထုတ်မည့် Event
class LoadCategories extends CategoryEvent {}

// 2. Category အသစ်ဆောက်မည့် Event
class AddCategoryRequested extends CategoryEvent {
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  AddCategoryRequested({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

// 3. Category ကို ID ဖြင့် ပြန်ပြင်မည့် Event
class UpdateCategoryRequested extends CategoryEvent {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  UpdateCategoryRequested({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

// 4. Category ကို ID ဖြင့် ဖျက်မည့် Event
class DeleteCategoryRequested extends CategoryEvent {
  final String id;
  DeleteCategoryRequested(this.id);
}

