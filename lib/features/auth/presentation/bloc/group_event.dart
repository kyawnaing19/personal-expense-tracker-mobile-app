abstract class GroupEvent {}

class LoadGroups extends GroupEvent {}

class LoadGroupDetail extends GroupEvent {
  final String id;
  LoadGroupDetail({required this.id});
}

class CreateGroupRequested extends GroupEvent {
  final String name;

  CreateGroupRequested({required this.name});
}

class UpdateGroupRequested extends GroupEvent {
  final String id;
  final String name;

  UpdateGroupRequested({required this.id, required this.name});
}

class DeleteGroupRequested extends GroupEvent {
  final String id;

  DeleteGroupRequested({required this.id});
}

class AddMemberRequested extends GroupEvent {
  final String groupId;
  final String email;

  AddMemberRequested({required this.groupId, required this.email});
}

class RemoveMemberRequested extends GroupEvent {
  final String groupId;
  final String userId;

  RemoveMemberRequested({required this.groupId, required this.userId});
}

class GenerateJoinCodeRequested extends GroupEvent {
  final String groupId;

  GenerateJoinCodeRequested({required this.groupId});
}

class JoinGroupRequested extends GroupEvent {
  final String code;

  JoinGroupRequested({required this.code});
}
