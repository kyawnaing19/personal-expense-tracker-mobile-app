import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:expense_tracker/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';


class CategoryRepository {
  final Dio _dio = DioClient.getInstance();
  final Box _cacheBox = Hive.box('categories_cache');

  void _saveToLocalDB(List<CategoryItem> items) {
    final List<Map<String, dynamic>> rawList = items.map((item) => {
      'id': item.id,
      'name': item.name,
      'icon': item.icon.codePoint.toString(),
      'color': '#${item.color.value.toRadixString(16).substring(2)}',
      'type': item.type,
    }).toList();
    _cacheBox.put('cached_list', rawList);
    developer.log('📦 [LOCAL DB] Successfully cached ${items.length} items to Hive.', name: 'CategoryRepository');
  }

  List<CategoryItem> _loadFromLocalDB() {
    final List<dynamic>? rawList = _cacheBox.get('cached_list');
    if (rawList == null) return [];
    
    return rawList.map((json) {
      String colorHex = json['color'] ?? '#6366F1';
      colorHex = colorHex.replaceAll('#', '');
      if (colorHex.length == 6) colorHex = "FF$colorHex";
      Color color = Color(int.parse("0x$colorHex"));

      int iconCode = int.tryParse(json['icon'].toString()) ?? Icons.restaurant.codePoint;
      IconData icon = IconData(iconCode, fontFamily: 'MaterialIcons');

      return CategoryItem(
        id: json['id'].toString(),
        name: json['name'] ?? 'Unnamed',
        icon: icon,
        color: color,
        type: json['type'].toString().toLowerCase(),
      );
    }).toList();
  }

  Future<List<CategoryItem>> getCategories() async {
    final localData = _loadFromLocalDB();
    developer.log('⚡ [LOCAL DB LOAD] Found ${localData.length} items in Cache.', name: 'CategoryRepository');

    try {
      developer.log('🚀 [API GET] Fetching fresh data from Server...', name: 'CategoryRepository');
      final response = await _dio.get(ApiConstants.categories);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        
        final List<CategoryItem> remoteItems = data.map((json) {
          String colorHex = json['color'] ?? '#6366F1';
          colorHex = colorHex.replaceAll('#', '');
          if (colorHex.length == 6) colorHex = "FF$colorHex";
          Color color = Color(int.parse("0x$colorHex"));

          int iconCode = int.tryParse(json['icon'].toString()) ?? Icons.restaurant.codePoint;
          IconData icon = IconData(iconCode, fontFamily: 'MaterialIcons');

          return CategoryItem(
            id: json['id'].toString(),
            name: json['name'] ?? 'Unnamed',
            icon: icon,
            color: color,
            type: json['type'].toString().toLowerCase(),
          );
        }).toList();

        _saveToLocalDB(remoteItems);
        return remoteItems;
      }
    } catch (e) {
      developer.log('⚠️ [OFFLINE MODE] Network failed ($e). Using Local Cache instead.', name: 'CategoryRepository');
      if (localData.isNotEmpty) {
        return localData;
      }
    }
    return localData;
  }

  Future<CategoryItem> createCategory({required String name, required IconData icon, required Color color, required String type}) async {
    final String tempId = DateTime.now().millisecondsSinceEpoch.toString();
    CategoryItem newItem = CategoryItem(id: tempId, name: name, icon: icon, color: color, type: type);

    final currentList = _loadFromLocalDB();
    currentList.add(newItem);
    _saveToLocalDB(currentList);

    try {
      String hexColor = '#${color.value.toRadixString(16).substring(2)}';
      final response = await _dio.post(
        ApiConstants.categories,
        data: {
          'name': name,
          'icon': icon.codePoint.toString(),
          'color': hexColor,
          'type': type.toLowerCase(),
        },
      );
      
      final json = response.data['data'];
      String serverId = json['id'].toString();

      final listForUpdate = _loadFromLocalDB();
      final idx = listForUpdate.indexWhere((element) => element.id == tempId);
      if (idx != -1) {
        newItem = CategoryItem(id: serverId, name: name, icon: icon, color: color, type: type);
        listForUpdate[idx] = newItem;
        _saveToLocalDB(listForUpdate);
      }
      
      developer.log('✅ [SERVER SYNC] Category Created and Synced to Server with ID: $serverId', name: 'CategoryRepository');
    } catch (e) {
      developer.log('⚠️ [LOCAL ONLY SAVED] Internet offline. Saved locally with Temp ID.', name: 'CategoryRepository');
    }
    return newItem;
  }

  Future<void> updateCategory({required String id, required String name, required IconData icon, required Color color, required String type}) async {
    final currentList = _loadFromLocalDB();
    final index = currentList.indexWhere((element) => element.id == id);
    if (index != -1) {
      currentList[index] = CategoryItem(id: id, name: name, icon: icon, color: color, type: type);
      _saveToLocalDB(currentList);
    }

    try {
      String hexColor = '#${color.value.toRadixString(16).substring(2)}';
      await _dio.put(
        '${ApiConstants.categories}/$id',
        data: {
          'name': name,
          'icon': icon.codePoint.toString(),
          'color': hexColor,
          'type': type.toLowerCase(),
        },
      );
      developer.log('✅ [SERVER SYNC] Category ID: $id Update Synced.', name: 'CategoryRepository');
    } catch (e) {
      developer.log('⚠️ [LOCAL ONLY UPDATED] Update saved locally. Internet offline.', name: 'CategoryRepository');
    }
  }

  Future<void> deleteCategory(String id) async {

  try {
    await _dio.delete('${ApiConstants.categories}/$id');
    
    final currentList = _loadFromLocalDB();
    currentList.removeWhere((element) => element.id.toString() == id.toString());
    _saveToLocalDB(currentList);
    
    developer.log('✅ [SERVER SYNC] Category ID: $id Deleted.', name: 'CategoryRepository');
  } on DioException catch (e) {
    developer.log('⚠️ [SERVER ERROR] Cannot delete category: ${e.response?.statusCode}', name: 'CategoryRepository');
    
    if (e.response?.statusCode == 500) {
      throw Exception("This category contains transactions and cannot be deleted.");
    }
    
    throw Exception("Failed to delete category. Please try again.");
  } catch (e) {
    throw Exception(e.toString());
  }
}
}