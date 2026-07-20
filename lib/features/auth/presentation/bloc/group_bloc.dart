import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupStateBase> {
  final GroupRepository _repository;

  GroupBloc(this._repository) : super(GroupInitial()) {
    on<LoadGroups>(_onLoadGroups);
    on<LoadGroupDetail>(_onLoadGroupDetail);
    on<CreateGroupRequested>(_onCreateGroup);
    on<UpdateGroupRequested>(_onUpdateGroup);
    on<DeleteGroupRequested>(_onDeleteGroup);
    on<AddMemberRequested>(_onAddMember);
    on<RemoveMemberRequested>(_onRemoveMember);
    on<GenerateJoinCodeRequested>(_onGenerateJoinCode);
    on<JoinGroupRequested>(_onJoinGroup);
  }

  Future<void> _onLoadGroups(
      LoadGroups event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onLoadGroupDetail(
      LoadGroupDetail event, Emitter<GroupStateBase> emit) async {
    emit(GroupDetailLoading());
    try {
      final group = await _repository.getGroupDetail(event.id);
      emit(GroupDetailLoaded(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onCreateGroup(
      CreateGroupRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.createGroup(name: event.name);
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupActionSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
    }
  }

  Future<void> _onUpdateGroup(
      UpdateGroupRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final updated = await _repository.updateGroup(
        id: event.id,
        name: event.name,
      );
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupUpdateSuccess(updated));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
    }
  }

  Future<void> _onDeleteGroup(
      DeleteGroupRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      await _repository.deleteGroup(id: event.id);
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupDeleteSuccess(event.id));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
    }
  }

  Future<void> _onAddMember(
      AddMemberRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.addMember(
        id: event.groupId,
        email: event.email,
      );

      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(MemberActionSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onRemoveMember(
      RemoveMemberRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.removeMember(
        id: event.groupId,
        userId: event.userId,
      );
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(MemberActionSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onGenerateJoinCode(
      GenerateJoinCodeRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.generateJoinCode(id: event.groupId);
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(JoinCodeGenerated(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  Future<void> _onJoinGroup(
      JoinGroupRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.joinGroup(code: event.code);
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupJoinSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}