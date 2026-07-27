import 'dart:developer' as developer;
import 'package:expense_tracker/cache-first/online-refresh/silent_refresh_registry.dart';
import 'package:expense_tracker/features/auth/data/category_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryStateBase> {
  final CategoryRepository _repository;
  bool _isDeleting = false; 

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategoryRequested>(_onAddCategory);
    on<UpdateCategoryRequested>(_onUpdateCategory);
    on<DeleteCategoryRequested>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryStateBase> emit) async {
    developer.log('[BLOC EVENT] LoadCategories Triggered', name: 'CategoryBloc');

    emit(CategoryLoading());
    try {
      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));
      developer.log('[BLOC STATE] Emitting Loaded. Total Items: ${categories.length}', name: 'CategoryBloc');
    } catch (e) {
      developer.log('[BLOC ERROR] Load failed: $e', name: 'CategoryBloc');
      emit(CategoryError(e.toString(), const []));
    }
  }

  Future<void> _onAddCategory(AddCategoryRequested event, Emitter<CategoryStateBase> emit) async {
    final previousCategories = state is CategoryLoaded ? (state as CategoryLoaded).categories : <CategoryItem>[];

    try {
      await _repository.createCategory(
        name: event.name,
        icon: event.icon,
        color: event.color,
        type: event.type,
      );
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString(), previousCategories));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategoryRequested event, Emitter<CategoryStateBase> emit) async {
    final previousCategories = state is CategoryLoaded ? (state as CategoryLoaded).categories : <CategoryItem>[];

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
      emit(CategoryError(e.toString(), previousCategories));
    }
  }
    Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
   
    if (_isDeleting) {
      developer.log(' [SKIPPED] Delete already in progress, ignoring duplicate request.', name: 'CategoryBloc');
      return;
    }
    _isDeleting = true;

    final previousCategories =
        state is CategoryLoaded ? (state as CategoryLoaded).categories : await _repository.getCategories();

    try {
      await _repository.deleteCategory(event.id);

      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));

      developer.log(' [BLOC STATE] Delete succeeded. Total Items: ${categories.length}', name: 'CategoryBloc');
   } catch (e) {
      final cleanMessage = e.toString().replaceAll("Exception: ", "");
      developer.log(' [BLOC ERROR] Delete failed: $cleanMessage', name: 'CategoryBloc');

      emit(CategoryError(cleanMessage, previousCategories));

      final categories = await _repository.getCategories();
      emit(CategoryLoaded(categories));
    } finally {
      _isDeleting = false;
    }
  }
  @override
  Future<void> close() {
    SilentRefreshRegistry.instance.unregister('categories');
    return super.close();
  }
}