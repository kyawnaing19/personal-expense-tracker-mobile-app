import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/group_model.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import 'group_settings_screen.dart';

const Color kGroupBg = Color(0xFFE8DEF8);
const Color kGroupPurple = Color(0xFF6200EE);

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late GroupModel _group;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    // member list, join_code စတာတွေအပါအဝင် အသေးစိတ်ကို ခေါ်မယ်
    context.read<GroupBloc>().add(LoadGroupDetail(id: _group.id));
  }

  void _refresh() {
    context.read<GroupBloc>().add(LoadGroupDetail(id: _group.id));
  }

  // "Group Expenses" ခေါင်းစီးဘေးက person-add icon ကို နှိပ်ရင်
  // "Generate Invite Code" နှင့် "Add Members" ဆိုတဲ့ ရွေးချယ်စရာ ၂ခု ပြမယ်
  // ("It's just you here" card နဲ့ တူညီတဲ့ button style ကို သုံးထားတယ်)
  Future<void> _openInviteChoiceSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Icon(Icons.person_add_alt_1_outlined,
                        color: kGroupPurple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Invite Members',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Invite friends to join and split expenses together.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openGenerateInviteCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Generate Invite Code',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text('Or', style: TextStyle(color: Colors.grey[500])),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _openAddMembers();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 18),
                    label: const Text('Add members',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openGenerateInviteCode() async {
    // Dialog ကိုယ်တိုင်က ဖွင့်တာနဲ့ code auto-generate လုပ်ပြီး
    // JoinCodeGenerated ကနေတဆင့် _group ကို listener က update ပေးနှင့်ပြီးသား
    // ဖြစ်လို့ ဒီနေရာမှာ ထပ် _refresh() လုပ်စရာမလိုပါဘူး - (ထပ်လုပ်ခဲ့ရင်
    // LoadGroupDetail က GroupsScreen အတွက် ပြင်ပေးထားတဲ့ GroupLoaded state ကို
    // ထပ်ဖျက်ပြီး "My Groups" list ပြန်ပျောက်စေတဲ့ bug ဖြစ်စေတယ်)
    await showDialog(
      context: context,
      builder: (_) => _GenerateInviteCodeDialog(groupId: _group.id),
    );
  }

  Future<void> _openAddMembers() async {
    // Member ထည့်အောင်မြင်ရင် MemberActionSuccess ကနေတဆင့် _group ကို
    // listener က update ပေးနှင့်ပြီးသား ဖြစ်လို့ ဒီနေရာမှာလည်း ထပ်
    // _refresh() လုပ်စရာမလိုပါဘူး
    await showDialog(
      context: context,
      builder: (_) => _AddMembersDialog(groupId: _group.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kGroupPurple,
        onPressed: () {
          // TODO: expense add flow - ဆက်လက်ဆောင်ရွက်ရန်
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocConsumer<GroupBloc, GroupStateBase>(
          listener: (context, state) {
            if (state is GroupDetailLoaded && state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is MemberActionSuccess &&
                state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is JoinCodeGenerated &&
                state.group.id == _group.id) {
              setState(() => _group = state.group);
            } else if (state is GroupError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Group Expenses',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.person_add_alt_1_outlined,
                            onTap: _openInviteChoiceSheet,
                          ),
                          const SizedBox(width: 8),
                          _RoundIconButton(
                            icon: Icons.settings_outlined,
                            onTap: () async {
                              // Settings screen ကိုသွားမယ်။ Delete Group
                              // အောင်မြင်ရင် 'deleted' ကိုပြန်ပို့ပြီး
                              // detail screen ကိုပါ ပိတ်ပေးမယ်
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      GroupSettingsScreen(group: _group),
                                ),
                              );
                              if (result == 'deleted' && context.mounted) {
                                Navigator.pop(context);
                              } else {
                                _refresh();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kGroupBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.groups_outlined,
                              color: kGroupPurple),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _group.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Created by ${_group.creatorName}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Expense Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // TODO: expense list state - ဆက်လက်ဆောင်ရွက်ရန်
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 36, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text(
                          'No expenses or group members yet. Start\nadding expenses to track balance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
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

// ---------------- Generate Invite Code popup ----------------

class _GenerateInviteCodeDialog extends StatefulWidget {
  final String groupId;
  const _GenerateInviteCodeDialog({required this.groupId});

  @override
  State<_GenerateInviteCodeDialog> createState() =>
      _GenerateInviteCodeDialogState();
}

class _GenerateInviteCodeDialogState
    extends State<_GenerateInviteCodeDialog> {
  // Bloc ရဲ့ "current state" ကိုပဲမမှီခိုပဲ code ကို local state အနေနဲ့
  // ကိုယ်တိုင်မှတ်ထားမယ်။ JoinCodeGenerated ရောက်ပြီးတဲ့နောက်
  // GroupLoaded ကို ချက်ချင်းထပ်ပို့တာကြောင့် code စာသား
  // ချက်ချင်းပျောက်သွားတဲ့ bug ကို ဒီလိုမှတ်ထားခြင်းနဲ့ ကာကွယ်တယ်
  String? _code;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // popup ပွင့်တာနဲ့ code တစ်ခုချက်ချင်း ထုတ်ပေးမယ်
    context
        .read<GroupBloc>()
        .add(GenerateJoinCodeRequested(groupId: widget.groupId));
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocListener<GroupBloc, GroupStateBase>(
        listener: (context, state) {
          if (state is GroupLoading) {
            setState(() => _isLoading = true);
          } else if (state is JoinCodeGenerated &&
              state.group.id == widget.groupId) {
            // code ကိုရလာတာနဲ့ local state ထဲ သိမ်းထားမယ် -
            // ဒါမှသာ နောက်ပိုင်း GroupLoaded state ရောက်လာလည်း
            // ဒီ popup ပေါ်က code စာသားက ပျောက်မသွားတော့ဘူး
            setState(() {
              _code = state.group.joinCode;
              _isLoading = false;
            });
          } else if (state is GroupError) {
            setState(() => _isLoading = false);
          }
        },
        child: Builder(builder: (context) {
          final String? code = _code;
          final bool isLoading = _isLoading;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Group Invite Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share this code so friends can join',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.5),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: kGroupBg.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code ?? '------',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: kGroupPurple,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                context.read<GroupBloc>().add(
                                    GenerateJoinCodeRequested(
                                        groupId: widget.groupId));
                              },
                              child: const Icon(Icons.refresh,
                                  color: kGroupPurple, size: 20),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: code == null ? null : () => _copyCode(code!),
                              child: const Icon(Icons.copy,
                                  color: kGroupPurple, size: 18),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Members enter this code in Join Group to join the group',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11.5),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGroupPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child:
                        const Text('Done', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ---------------- Add Members popup ----------------

class _AddMembersDialog extends StatefulWidget {
  final String groupId;
  const _AddMembersDialog({required this.groupId});

  @override
  State<_AddMembersDialog> createState() => _AddMembersDialogState();
}

class _AddMembersDialogState extends State<_AddMembersDialog> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gmail account ထည့်ပေးပါ')),
      );
      return;
    }
    context
        .read<GroupBloc>()
        .add(AddMemberRequested(groupId: widget.groupId, email: email));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: BlocConsumer<GroupBloc, GroupStateBase>(
        listener: (context, state) {
          if (state is MemberActionSuccess &&
              state.group.id == widget.groupId) {
            Navigator.pop(context);
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is GroupLoading;
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              // keyboard ပွင့်လာရင် dialog ကို ခုန်တက်ပေးဖို့ - မဟုတ်ရင်
              // TextField ကို keyboard ဖုံးလွှမ်းပြီး bottom overflow တက်တယ်
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emailController,
                  enabled: !isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'friend@gmail.com',
                    filled: true,
                    fillColor: kGroupBg.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.black87)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGroupPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                            : const Text('Add',
                                style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
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