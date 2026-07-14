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

  // Group Detail / Settings screen - member list ပါတဲ့ group တစ်ခုတည်းကို ခေါ်မယ်
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
      // "My Groups" list ကို GroupActionSuccess (dialog pop trigger) မထုတ်ခင်
      // အရင်ဆုံး refresh လုပ်ပြီး emit လုပ်လိုက်တယ် - GroupsScreen ရဲ့
      // BlocConsumer က dialog ပိတ်ခါနီးမှာတင် (ActionSuccess ရောက်ခါနီးမှာ)
      // list အသစ်ကို လက်ခံထားပြီးဖြစ်နေအောင် (dialog ပိတ်ပြီးမှ list
      // network fetch ဆက်စောင့်နေရလို့ new group ချက်ချင်းမပေါ်တဲ့ bug
      // ကို ကာကွယ်ပေးတယ်)
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupActionSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
    }
  }

  // Edit Group -> PUT /groups/{id}
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

  // Delete Group -> DELETE /groups/{id}
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

  // Add Member -> POST /groups/{id}/members
  Future<void> _onAddMember(
      AddMemberRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.addMember(
        id: event.groupId,
        email: event.email,
      );
      // My Groups list ထဲက member count ကိုပါ up-to-date ဖြစ်အောင်၊ နှင့်
      // GroupsScreen ပြန်ရောက်တဲ့အခါ list မပျောက်သွားအောင် ပြန် refresh
      // လုပ်မယ် (MemberActionSuccess ကို dialog pop trigger အဖြစ် သုံးမှာ
      // ဖြစ်လို့ ဒီ list ကို အရင်ဆုံး update လုပ်ထားမယ်)
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(MemberActionSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }

  // Remove Member -> DELETE /groups/{id}/members/{userId}
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

  // Generate / Regenerate Invite Code -> POST /groups/{id}/join-code
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

  // Join Group -> POST /groups/join
  Future<void> _onJoinGroup(
      JoinGroupRequested event, Emitter<GroupStateBase> emit) async {
    emit(GroupLoading());
    try {
      final group = await _repository.joinGroup(code: event.code);
      // join ဝင်ပြီးတာနဲ့ "My Groups" list ထဲမှာ ချက်ချင်းပေါ်လာအောင်
      // GroupJoinSuccess (dialog pop trigger) မထုတ်ခင် အရင် refresh လုပ်မယ်
      final groups = await _repository.getGroups();
      emit(GroupLoaded(groups));
      emit(GroupJoinSuccess(group));
    } catch (e) {
      emit(GroupError(e.toString().replaceAll("Exception: ", "")));
    }
  }
}