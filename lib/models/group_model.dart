class GroupMember {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String role; // "admin" | "member"
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

  // "Created by" ဆိုတဲ့နေရာမှာ user id အစား အမည်ပြချင်လို့
  // members list ထဲက id တူတဲ့သူကို ရှာပြီး name ကို ပြန်ပေးမယ်
  // (backend က created_by field ကို user id အနေနဲ့ ပြန်ပေးထားလို့)
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
      // members array ကို backend က ပေးထားရင် (group detail / add member /
      // generate invite code စတဲ့ response တွေမှာ) - group_settings_screen
      // ကလိုပဲ members.length ကို တိုက်ရိုက်ယူမယ်၊ ဒါက အမှန်ကန်ဆုံးပါ။
      // (member_count field ကို မယုံပါဘူး - member အသစ်ထည့်ပြီးနောက်ပိုင်း
      // ဒီ field က မ update ဖြစ်ဘဲ stale ဖြစ်နေတတ်လို့ count မတိုးတဲ့ bug
      // ဖြစ်စေနိုင်တယ်)
      //
      // backend ရဲ့ members list ထဲမှာ group ဖန်တီးသူ (creator) ကိုယ်တိုင်
      // မပါဝင်ရင် (invited/added member တွေချည်းပဲ ပါလာရင်), creator ကိုပါ
      // +1 ထည့်ရေတွက်ပေးမယ် (group တိုင်းမှာ creator က member တစ်ယောက်
      // အနေနဲ့ အမြဲရှိနေရမှာမို့)
      final creatorAlreadyCounted = members.any((m) => m.id == createdBy);
      memberCount = creatorAlreadyCounted ? members.length : members.length + 1;
    } else {
      // members array မပါလာတဲ့ list-summary response (GET /groups) အတွက်
      // backend က field နာမည် "group_users_count" လို့ ပေးထားတယ် ("member_count"
      // မဟုတ်ဘူး) - နာမည်မကိုက်လို့ အရင်က အမြဲ 0 ဖြစ်နေခဲ့တာ။ ဒီ count ထဲမှာ
      // creator ကိုပါ ရေတွက်ပြီးသားမို့ (settings screen ရဲ့ members.length
      // နဲ့ ကိုက်ညီတယ်) +1 ထပ်ပေါင်းစရာ မလိုတော့ပါဘူး
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
