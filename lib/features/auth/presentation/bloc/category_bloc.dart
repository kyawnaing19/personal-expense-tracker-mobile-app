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

  // Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
  //   try {
  //     await _repository.deleteCategory(event.id);
  //     add(LoadCategories());
  //   } catch (e) {
  //     emit(CategoryError(e.toString()));
  //   }
  // }
 Future<void> _onDeleteCategory(DeleteCategoryRequested event, Emitter<CategoryStateBase> emit) async {
  try {
    emit(CategoryLoading()); // ဖျက်နေစဉ် ခေတ္တ Loading ပြမယ်
    await _repository.deleteCategory(event.id);
    
    // အောင်မြင်ရင် ဒေတာအသစ် ပြန်ဆွဲမယ်
    final categories = await _repository.getCategories();
    emit(CategoryLoaded(categories));
  } catch (e) {
    // 🛑 Error တက်ရင် ဆက်မသွားတော့ဘဲ Error State ကို Message နဲ့အတူ ပို့ပေးလိုက်မယ်
    // e.toString() ထဲက 'Exception: ' ဆိုတဲ့ စာသားကို ဖယ်ထုတ်ပေးထားပါတယ်
    final cleanMessage = e.toString().replaceAll("Exception: ", "");
    emit(CategoryError(cleanMessage));
    
    // ဒေတာဟောင်းကို UI မှာ ပြန်ပြနိုင်အောင် ဒေတာပြန်ခေါ်ပေးထားမယ်
    final categories = await _repository.getCategories();
    emit(CategoryLoaded(categories));
  }
}
}