import 'package:expense_tracker/core/services/current_user_service..dart';
import 'package:expense_tracker/features/auth/data/balance_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/balance_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/screens/members_balance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/group_model.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';

const Color kGroupBg = Color(0xFFE8DEF8);
const Color kGroupPurple = Color(0xFF6200EE);

class GroupSettingsScreen extends StatefulWidget {
  final GroupModel group;
  const GroupSettingsScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late GroupModel _group;
  String? _myUserId;
  String? _myEmail;
  bool _loadingMe = true;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    context.read<GroupBloc>().add(LoadGroupDetail(id: _group.id));
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final me = await CurrentUserService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _myUserId = me['id'];
      _myEmail = me['email'];
      _loadingMe = false;
    });
  }
  GroupMember? get _myMembership {
    for (final m in _group.members) {
      if ((_myUserId != null && m.id == _myUserId) ||
          (_myEmail != null &&
              m.email.toLowerCase() == _myEmail!.toLowerCase())) {
        return m;
      }
    }
    return null;
  }

  bool get _isAdmin => _myMembership?.isAdmin ?? false;

  Future<void> _openEditGroup() async {
    final updated = await Navigator.push<GroupModel>(
      context,
      MaterialPageRoute(builder: (_) => EditGroupScreen(group: _group)),
    );
    if (updated != null) {
      setState(() => _group = _group.copyWith(name: updated.name));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group name changed to "${updated.name}"')),
        );
      }
    }
  }

  void _openDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _DeleteGroupDialog(
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<GroupBloc>().add(DeleteGroupRequested(id: _group.id));
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  void _openRemoveMemberDialog(GroupMember member) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _RemoveMemberDialog(
        onConfirm: () {
          Navigator.pop(dialogContext);
          context.read<GroupBloc>().add(
                RemoveMemberRequested(groupId: _group.id, userId: member.id),
              );
        },
        onCancel: () => Navigator.pop(dialogContext),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
      body: SafeArea(
        child: BlocConsumer<GroupBloc, GroupStateBase>(
          listener: (context, state) {
            if (state is GroupDetailLoaded && state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is MemberActionSuccess &&
                state.group.id == _group.id) {
              setState(() => _group = state.group);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member removed')),
              );
            } else if (state is GroupDeleteSuccess &&
                state.groupId == _group.id) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"${_group.name}" group deleted')),
              );
              Navigator.pop(context, 'deleted');
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          // builder: (context, state) {
          //   final isBusy = state is GroupLoading || _loadingMe;
          //   return Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: SingleChildScrollView(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(
          //             children: [
          //               _RoundIconButton(
          //                 icon: Icons.arrow_back_ios_outlined,
          //                 onTap: () => Navigator.pop(context),
          //               ),
          //               const Expanded(
          //                 child: Center(
          //                   child: Text(
          //                     'Settings',
          //                     style: TextStyle(
          //                         fontSize: 18, fontWeight: FontWeight.bold),
          //                   ),
          //                 ),
          //               ),
          //               const SizedBox(width: 40),
          //             ],
          //           ),
          //           const SizedBox(height: 20),

          //           Container(
          //             width: double.infinity,
          //             padding: const EdgeInsets.all(16),
            builder: (context, state) {
            final isBusy = state is GroupLoading || _loadingMe;
            return Column(
              children: [
                // ── Static Nav Bar ── (scroll လုပ်လည်း မရွှေ့တော့ပါ)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Settings',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Scrollable Content ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kGroupBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.groups_outlined,
                                color: kGroupPurple),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            _group.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Icon(Icons.groups_outlined,
                            size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kGroupPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_group.members.length}',
                            style: const TextStyle(
                                color: kGroupPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Members list
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: state is GroupDetailLoading || _loadingMe
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : _group.members.isEmpty
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'No members yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                )
                              : Column(
                                  children: _group.members
                                      .map(
                                        (m) => _MemberTile(
                                          member: m,
                                          isYou: (_myUserId != null &&
                                                  m.id == _myUserId) ||
                                              (_myEmail != null &&
                                                  m.email.toLowerCase() ==
                                                      _myEmail!.toLowerCase()),
                                          canRemove: _isAdmin &&
                                              !((_myUserId != null &&
                                                      m.id == _myUserId) ||
                                                  (_myEmail != null &&
                                                      m.email.toLowerCase() ==
                                                          _myEmail!
                                                              .toLowerCase())),
                                          onRemove: () =>
                                              _openRemoveMemberDialog(m),
                                        ),
                                      )
                                      .toList(),
                                ),
                    ),
                    const SizedBox(height: 20),

                    // Group Balance / Settle Up
                    _SettingsRowButton(
                      label: "Members' Balance",
                      onTap: () {
                        Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => BalanceBloc(BalanceRepository()),
          child: MembersBalanceScreen(groupId: _group.id),
        ),
      ),
    );
                      },
                    ),
                    
                    if (_isAdmin) ...[
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _openEditGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGroupPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Edit Group',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isBusy ? null : _openDeleteDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGroupPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
child: const Text('Delete Group',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final GroupMember member;
  final bool isYou;
  final bool canRemove;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    this.isYou = false,
    this.canRemove = false,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    final isAdmin = member.isAdmin;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kGroupPurple,
            backgroundImage:
                (member.avatar != null && member.avatar!.isNotEmpty)
                    ? NetworkImage(member.avatar!)
                    : null,
            child: (member.avatar == null || member.avatar!.isEmpty)
                ? Text(
                    initial,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 4),
                      Text('(You)',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? kGroupPurple.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAdmin ? 'Admin' : 'Member',
                        style: TextStyle(
                          color: isAdmin ? kGroupPurple : Colors.grey[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      
          if (canRemove)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[500]),
              onSelected: (value) {
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_alt_1_outlined,
                          color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Remove from group',
                          style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SettingsRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SettingsRowButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}


class EditGroupScreen extends StatefulWidget {
  final GroupModel group;
  const EditGroupScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group name ထည့်ပေးပါ')),
      );
      return;
    }
    context.read<GroupBloc>().add(
          UpdateGroupRequested(id: widget.group.id, name: name),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
      body: SafeArea(
        child: BlocConsumer<GroupBloc, GroupStateBase>(
          listener: (context, state) {
            if (state is GroupUpdateSuccess &&
                state.group.id == widget.group.id) {
              Navigator.pop(context, state.group);
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is GroupLoading;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_ios_outlined,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Edit Group',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Group Name',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            hintText: 'Enter group name',
                            filled: true,
                            fillColor: kGroupBg.withOpacity(0.3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: kGroupPurple),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: kGroupPurple),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: kGroupPurple, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGroupPurple,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Save Change',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGroupPurple,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class _DeleteGroupDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _DeleteGroupDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delete Group',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: onCancel,
                  child: const Icon(Icons.close, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF5B5B5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Warning: This action cannot be undone',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Deleting this group will permanently remove all expenses, balances and members data associated with it.',
                    style: TextStyle(color: Colors.red, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _RemoveMemberDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _RemoveMemberDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                SizedBox(width: 8),
                Text(
                  'Remove Member?',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Are you sure you want to remove this member?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}
