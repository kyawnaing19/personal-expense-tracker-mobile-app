import 'package:expense_tracker/models/category_model.dart';

abstract class CategoryStateBase {}

// Initial State
class CategoryInitial extends CategoryStateBase {}

// Loading State (ပြနေစဉ်)
class CategoryLoading extends CategoryStateBase {}

// Successfully Loaded State (ဒေတာရလာစဉ်)
class CategoryLoaded extends CategoryStateBase {
  final List<CategoryItem> categories;
  CategoryLoaded(this.categories);
}

// Error State (အမှားတစ်ခုခုတက်စဉ်)
class CategoryError extends CategoryStateBase {
  final String message;
  CategoryError(this.message);
}