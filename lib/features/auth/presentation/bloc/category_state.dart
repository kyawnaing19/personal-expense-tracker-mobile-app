import 'package:expense_tracker/models/category_model.dart';

abstract class CategoryStateBase {}

class CategoryInitial extends CategoryStateBase {}

class CategoryLoading extends CategoryStateBase {}

class CategoryLoaded extends CategoryStateBase {
  final List<CategoryItem> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryStateBase {
  final String message;
  CategoryError(this.message);
}