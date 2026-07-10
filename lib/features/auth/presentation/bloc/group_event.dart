abstract class GroupEvent {}

class LoadGroups extends GroupEvent {}

// Group Detail / Settings screen ဝင်တာနဲ့ member list ပါအောင် အသေးစိတ်ခေါ်ဖို့
class LoadGroupDetail extends GroupEvent {
  final String id;
  LoadGroupDetail({required this.id});
}

class CreateGroupRequested extends GroupEvent {
  final String name;

  CreateGroupRequested({required this.name});
}

// Edit Group အတွက် - name ချိန်းဖို့
class UpdateGroupRequested extends GroupEvent {
  final String id;
  final String name;

  UpdateGroupRequested({required this.id, required this.name});
}

// Delete Group အတွက်
class DeleteGroupRequested extends GroupEvent {
  final String id;

  DeleteGroupRequested({required this.id});
}

// Add Member (email နဲ့ ရှာပြီးထည့်ဖို့)
class AddMemberRequested extends GroupEvent {
  final String groupId;
  final String email;

  AddMemberRequested({required this.groupId, required this.email});
}

// Remove Member (admin ကသာ လုပ်ခွင့်ရှိမယ်)
class RemoveMemberRequested extends GroupEvent {
  final String groupId;
  final String userId;

  RemoveMemberRequested({required this.groupId, required this.userId});
}

// Generate / Regenerate Invite Code
class GenerateJoinCodeRequested extends GroupEvent {
  final String groupId;

  GenerateJoinCodeRequested({required this.groupId});
}

// Join Group - friend ရဲ့ 6-digit invite code ကိုသုံးပြီး group ထဲဝင်ဖို့
class JoinGroupRequested extends GroupEvent {
  final String code;

  JoinGroupRequested({required this.code});
}
