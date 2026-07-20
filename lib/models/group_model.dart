class GroupMember {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role; 
  final DateTime? joinedAt;

  GroupMember({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
    this.joinedAt,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'member',
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'].toString())
          : null,
    );
  }
}

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final int memberCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? joinCode;
  final DateTime? joinCodeExpiresAt;
  final List<GroupMember> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.memberCount = 0,
    this.createdAt,
    this.updatedAt,
    this.joinCode,
    this.joinCodeExpiresAt,
    this.members = const [],
  });

  String get creatorName {
    final creator = members.where((m) => m.id == createdBy);
    if (creator.isNotEmpty) return creator.first.name;
    return createdBy;
  }

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>?;
    final members = membersJson != null
        ? membersJson
            .map((m) => GroupMember.fromJson(m as Map<String, dynamic>))
            .toList()
        : <GroupMember>[];

    final createdBy = json['created_by']?.toString() ?? '';

    int memberCount;
    if (membersJson != null) {
      final creatorAlreadyCounted = members.any((m) => m.id == createdBy);
      memberCount = creatorAlreadyCounted ? members.length : members.length + 1;
    } else {
      final rawCount = json['group_users_count'] is int
          ? json['group_users_count'] as int
          : int.tryParse(json['group_users_count']?.toString() ?? '') ?? 0;
      memberCount = rawCount;
    }

    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdBy: createdBy,
      memberCount: memberCount,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      joinCode: json['join_code']?.toString(),
      joinCodeExpiresAt: json['join_code_expires_at'] != null
          ? DateTime.tryParse(json['join_code_expires_at'].toString())
          : null,
      members: members,
    );
  }

  GroupModel copyWith({
    String? name,
    List<GroupMember>? members,
    String? joinCode,
    DateTime? joinCodeExpiresAt,
  }) {
    int newMemberCount = memberCount;
    if (members != null) {
      final creatorAlreadyCounted = members.any((m) => m.id == createdBy);
      newMemberCount =
          creatorAlreadyCounted ? members.length : members.length + 1;
    }
    return GroupModel(
      id: id,
      name: name ?? this.name,
      createdBy: createdBy,
      memberCount: newMemberCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      joinCode: joinCode ?? this.joinCode,
      joinCodeExpiresAt: joinCodeExpiresAt ?? this.joinCodeExpiresAt,
      members: members ?? this.members,
    );
  }
}
