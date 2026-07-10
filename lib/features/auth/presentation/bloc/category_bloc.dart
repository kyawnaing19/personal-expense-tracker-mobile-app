import 'dart:developer' as developer;
import 'package:expense_tracker/features/auth/data/category_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryStateBase> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryRequested>(_onAddCategory);
    on<UpdateCategoryRequested>(_onUpdateCategory);
    on<DeleteCategoryRequested>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryStateBase> emit) async {
    developer.log('🎯 [BLOC EVENT] LoadCategories Triggered', name: 'CategoryBloc');
    
    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));
      developer.log('🎯 [BLOC STATE] Emitting Loaded. Total Items: ${categories.length}', name: 'CategoryBloc');
    } catch (e) {
      developer.log('🎯 [BLOC ERROR] Load failed: $e', name: 'CategoryBloc');
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onAddCategory(AddCategoryRequested event, Emitter<CategoryStateBase> emit) async {
    try {
      await _repository.createCategory(
        name: event.name,
        icon: event.icon,
        color: event.color,
        type: event.type,
      );
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategoryRequested event, Emitter<CategoryStateBase> emit) async {
    try {
      await _repository.updateCategory(
        id: event.id,
        name: event.name,
        icon: event.icon,
        color: event.color,
        type: event.type,
      );
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

 Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
  try {
    emit(CategoryLoading()); 
    await _repository.deleteCategory(event.id);
    
    final categories = await _repository.getCategories();
    emit(CategoryLoaded(categories));
  } catch (e) {
  
    final cleanMessage = e.toString().replaceAll("Exception: ", "");
    emit(CategoryError(cleanMessage));
    
    final categories = await _repository.getCategories();
    emit(CategoryLoaded(categories));
  }
}
}