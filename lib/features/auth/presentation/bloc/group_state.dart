import '../../../../models/group_model.dart';

abstract class GroupStateBase {}

class GroupInitial extends GroupStateBase {}

class GroupLoading extends GroupStateBase {}

class GroupLoaded extends GroupStateBase {
  final List<GroupModel> groups;
  GroupLoaded(this.groups);
}

// Group Detail / Settings screen အတွက် - member list ပါတဲ့ group တစ်ခုတည်း
class GroupDetailLoading extends GroupStateBase {}

class GroupDetailLoaded extends GroupStateBase {
  final GroupModel group;
  GroupDetailLoaded(this.group);
}

// Emitted right after a successful create, before the list reloads
class GroupActionSuccess extends GroupStateBase {
  final GroupModel group;
  GroupActionSuccess(this.group);
}

// Emitted right after a successful name update (Edit Group)
class GroupUpdateSuccess extends GroupStateBase {
  final GroupModel group;
  GroupUpdateSuccess(this.group);
}

// Emitted right after a successful delete
class GroupDeleteSuccess extends GroupStateBase {
  final String groupId;
  GroupDeleteSuccess(this.groupId);
}

// Member ထည့်ပြီးတာနဲ့ / ဖြုတ်ပြီးတာနဲ့ group (with refreshed members) ပြန်ပေးမယ်
class MemberActionSuccess extends GroupStateBase {
  final GroupModel group;
  MemberActionSuccess(this.group);
}

// Invite code အသစ်ထုတ်ပြီးတာနဲ့
class JoinCodeGenerated extends GroupStateBase {
  final GroupModel group;
  JoinCodeGenerated(this.group);
}

// Invite code ဖြင့် group ထဲ join ဝင်ပြီးတာနဲ့ (Create နဲ့ text ကွဲသွားအောင်
// သီးသန့် state ခွဲထားတယ်)
class GroupJoinSuccess extends GroupStateBase {
  final GroupModel group;
  GroupJoinSuccess(this.group);
}

class GroupError extends GroupStateBase {
  final String message;
  GroupError(this.message);
}
