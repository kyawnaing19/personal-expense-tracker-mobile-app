import 'package:flutter/material.dart';

abstract class CategoryEvent {}

class LoadCategories extends CategoryEvent {}

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

class DeleteCategoryRequested extends CategoryEvent {
  final String id;
  DeleteCategoryRequested(this.id);
}

