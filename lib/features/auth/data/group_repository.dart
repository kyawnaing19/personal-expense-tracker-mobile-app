import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../models/group_model.dart';

class GroupRepository {
  final Dio _dio = DioClient.getInstance();

  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _dio.get(ApiConstants.groups);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => GroupModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching groups: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to load groups');
    }
    return [];
  }
  Future<GroupModel> getGroupDetail(String id) async {
    try {
      final response = await _dio.get(ApiConstants.groupDetail(id));
      return GroupModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Failed fetching group detail: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to load group');
    }
  }

  Future<GroupModel> createGroup({required String name}) async {
    try {
      final response = await _dio.post(
        ApiConstants.groups,
        queryParameters: {'name': name},
      );

      developer.log('✅ Group Created.', name: 'GroupRepository');
      return GroupModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Group Create Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to create group');
    }
  }

  Future<GroupModel> updateGroup({
    required String id,
    required String name,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.groups}/$id',
        data: {'name': name},
      );

      developer.log('✅ Group Updated.', name: 'GroupRepository');
      return GroupModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      developer.log('⚠️ Group Update Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to update group');
    }
  }

  Future<void> deleteGroup({required String id}) async {
    try {
      await _dio.delete('${ApiConstants.groups}/$id');
      developer.log('✅ Group Deleted.', name: 'GroupRepository');
    } on DioException catch (e) {
      developer.log('⚠️ Group Delete Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to delete group');
    }
  }

  Future<GroupModel> addMember({
    required String id,
    required String email,
  }) async {
    try {
      await _dio.post(
        ApiConstants.groupMembers(id),
        data: {'email': email},
      );
      developer.log('✅ Member Added.', name: 'GroupRepository');
  
      return await getGroupDetail(id);
    } on DioException catch (e) {
      developer.log('⚠️ Add Member Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to add member');
    }
  }


  Future<GroupModel> removeMember({
    required String id,
    required String userId,
  }) async {
    try {
      await _dio.delete(ApiConstants.groupMember(id, userId));
      developer.log('✅ Member Removed.', name: 'GroupRepository');
      return await getGroupDetail(id);
    } on DioException catch (e) {
      developer.log('⚠️ Remove Member Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to remove member');
    }
  }

  Future<GroupModel> generateJoinCode({required String id}) async {
    try {
      final response = await _dio.post(ApiConstants.groupJoinCode(id));
      developer.log('✅ Join Code Generated.', name: 'GroupRepository');
      final data = response.data['data'];

      if (data is Map && data['members'] != null) {
        return GroupModel.fromJson(data as Map<String, dynamic>);
      }
      return await getGroupDetail(id);
    } on DioException catch (e) {
      developer.log('⚠️ Generate Join Code Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Failed to generate invite code');
    }
  }


  Future<GroupModel> joinGroup({required String code}) async {
    try {
      final response = await _dio.post(
        ApiConstants.groupJoin,
        data: {'join_code': code.trim()},
      );

      developer.log('✅ Joined Group.', name: 'GroupRepository');
      final data = response.data['data'];
      if (data is Map && data['id'] != null) {
        final group = GroupModel.fromJson(data as Map<String, dynamic>);
        return group.members.isNotEmpty || group.name.isNotEmpty
            ? group
            : await getGroupDetail(group.id);
      }
      throw Exception('Invalid response from server');
    } on DioException catch (e) {
      developer.log('⚠️ Join Group Failed: ${e.response?.data}',
          name: 'GroupRepository');
      throw Exception(_extractError(e) ?? 'Invalid or expired group code');
    }
  }

  String? _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return null;
  }
}
