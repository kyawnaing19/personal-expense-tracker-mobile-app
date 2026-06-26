// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../../data/category_repository.dart';
// // import 'category_event.dart';
// // import 'category_state.dart';

// // class CategoryBloc extends Bloc<CategoryEvent, CategoryStateBase> {
// //   final CategoryRepository _repository;

// //   CategoryBloc(this._repository) : super(CategoryInitial()) {
// //     on<LoadCategories>(_onLoadCategories);
// //     on<AddCategoryRequested>(_onAddCategory);
// //     on<UpdateCategoryRequested>(_onUpdateCategory);
// //     on<DeleteCategoryRequested>(_onDeleteCategory);
// //   }

// //   Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryStateBase> emit) async {
// //     emit(CategoryLoading());
// //     try {
// //       final categories = await _repository.getCategories();
// //       emit(CategoryLoaded(categories));
// //     } catch (e) {
// //       emit(CategoryError(e.toString()));
// //     }
// //   }

// //   Future<void> _onAddCategory(AddCategoryRequested event, Emitter<CategoryStateBase> emit) async {
// //     try {
// //       await _repository.createCategory(name: event.name, icon: event.icon, color: event.color, type: event.type);
// //       add(LoadCategories()); // API ကနေ List အသစ်ကို ပြန်ခေါ်ပြီး Refresh လုပ်ခြင်း
// //     } catch (e) {
// //       emit(CategoryError(e.toString()));
// //     }
// //   }

// //   Future<void> _onUpdateCategory(UpdateCategoryRequested event, Emitter<CategoryStateBase> emit) async {
// //     try {
// //       await _repository.updateCategory(id: event.id, name: event.name, icon: event.icon, color: event.color, type: event.type);
// //       add(LoadCategories());
// //     } catch (e) {
// //       emit(CategoryError(e.toString()));
// //     }
// //   }

// //   Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
// //     try {
// //       await _repository.deleteCategory(event.id);
// //       add(LoadCategories());
// //     } catch (e) {
// //       emit(CategoryError(e.toString()));
// //     }
// //   }
// // }


// import 'dart:developer' as developer;
// import 'package:expense_tracker/features/auth/data/category_repository.dart';
// import 'package:expense_tracker/features/auth/presentation/bloc/category_event.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'category_state.dart';

// class CategoryBloc extends Bloc<CategoryEvent, CategoryStateBase> {
//   final CategoryRepository _repository;

//   CategoryBloc(this._repository) : super(CategoryInitial()) {
//     on<LoadCategories>(_onLoadCategories);
//     on<AddCategoryRequested>(_onAddCategory);
//     on<UpdateCategoryRequested>(_onUpdateCategory);
//     on<DeleteCategoryRequested>(_onDeleteCategory);
//   }

//   // 1. Handler for LoadCategories
//   Future<void> _onLoadCategories(LoadCategories event, Emitter<CategoryStateBase> emit) async {
//     developer.log('🎯 [BLOC EVENT] LoadCategories Triggered', name: 'CategoryBloc');
//     emit(CategoryLoading());
//     try {
//       final categories = await _repository.getCategories();
//       developer.log('🎯 [BLOC STATE] Emitting CategoryLoaded with ${categories.length} items', name: 'CategoryBloc');
//       emit(CategoryLoaded(categories));
//     } catch (e) {
//       developer.log('🎯 [BLOC ERROR] Failed to load categories', name: 'CategoryBloc', error: e);
//       emit(CategoryError(e.toString()));
//     }
//   }

//   // 2. Handler for AddCategory
//   Future<void> _onAddCategory(AddCategoryRequested event, Emitter<CategoryStateBase> emit) async {
//     developer.log('🎯 [BLOC EVENT] AddCategoryRequested Triggered: ${event.name}', name: 'CategoryBloc');
//     try {
//       await _repository.createCategory(
//         name: event.name,
//         icon: event.icon,
//         color: event.color,
//         type: event.type,
//       );
//       developer.log('🎯 [BLOC SUCCESS] Category Added. Reloading list...', name: 'CategoryBloc');
//       // ပြောင်းလဲမှုရှိသွားလို့ Server ကနေ List အသစ်ကို အော်တိုပြန်ခေါ်ခိုင်းခြင်း
//       add(LoadCategories());
//     } catch (e) {
//       developer.log('🎯 [BLOC ERROR] Failed to add category', name: 'CategoryBloc', error: e);
//       emit(CategoryError(e.toString()));
//     }
//   }

//   // 3. Handler for UpdateCategory
//   Future<void> _onUpdateCategory(UpdateCategoryRequested event, Emitter<CategoryStateBase> emit) async {
//     developer.log('🎯 [BLOC EVENT] UpdateCategoryRequested Triggered for ID: ${event.id}', name: 'CategoryBloc');
//     try {
//       await _repository.updateCategory(
//         id: event.id,
//         name: event.name,
//         icon: event.icon,
//         color: event.color,
//         type: event.type,
//       );
//       developer.log('🎯 [BLOC SUCCESS] Category Updated. Reloading list...', name: 'CategoryBloc');
//       // ပြောင်းလဲမှုရှိသွားလို့ Server ကနေ List အသစ်ကို အော်တိုပြန်ခေါ်ခိုင်းခြင်း
//       add(LoadCategories());
//     } catch (e) {
//       developer.log('🎯 [BLOC ERROR] Failed to update category', name: 'CategoryBloc', error: e);
//       emit(CategoryError(e.toString()));
//     }
//   }

//   // 4. Handler for DeleteCategory
//   Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
//     developer.log('🎯 [BLOC EVENT] DeleteCategoryRequested Triggered for ID: ${event.id}', name: 'CategoryBloc');
//     try {
//       await _repository.deleteCategory(event.id);
//       developer.log('🎯 [BLOC SUCCESS] Category Deleted. Reloading list...', name: 'CategoryBloc');
//       // ပြောင်းလဲမှုရှိသွားလို့ Server ကနေ List အသစ်ကို အော်တိုပြန်ခေါ်ခိုင်းခြင်း
//       add(LoadCategories());
//     } catch (e) {
//       developer.log('🎯 [BLOC ERROR] Failed to delete category', name: 'CategoryBloc', error: e);
//       emit(CategoryError(e.toString()));
//     }
//   }
// }


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
    
    // မှတ်ချက် - Loading ကိုပြသော်လည်း Local Storage ရှိလျှင် အောက်က Line က ပိုမြန်လို့ မျက်စိထဲ တန်းပွင့်လာပါလိမ့်မယ်
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
      await _repository.deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}