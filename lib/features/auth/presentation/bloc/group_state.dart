import '../../../../models/group_model.dart';

abstract class GroupStateBase {}

class GroupInitial extends GroupStateBase {}

class GroupLoading extends GroupStateBase {}

class GroupLoaded extends GroupStateBase {
  final List<GroupModel> groups;
  GroupLoaded(this.groups);
}

class GroupDetailLoading extends GroupStateBase {}

class GroupDetailLoaded extends GroupStateBase {
  final GroupModel group;
  GroupDetailLoaded(this.group);
}

class GroupActionSuccess extends GroupStateBase {
  final GroupModel group;
  GroupActionSuccess(this.group);
}

class GroupUpdateSuccess extends GroupStateBase {
  final GroupModel group;
  GroupUpdateSuccess(this.group);
}

class GroupDeleteSuccess extends GroupStateBase {
  final String groupId;
  GroupDeleteSuccess(this.groupId);
}

class MemberActionSuccess extends GroupStateBase {
  final GroupModel group;
  MemberActionSuccess(this.group);
}

class JoinCodeGenerated extends GroupStateBase {
  final GroupModel group;
  JoinCodeGenerated(this.group);
}

class GroupJoinSuccess extends GroupStateBase {
  final GroupModel group;
  GroupJoinSuccess(this.group);
}

class GroupError extends GroupStateBase {
  final String message;
  GroupError(this.message);
}
