import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/group_model.dart';
import '../bloc/group_bloc.dart';
import '../bloc/group_event.dart';
import '../bloc/group_state.dart';
import 'group_detail_screen.dart';

const Color kGroupBg = Color(0xFFE8DEF8);
const Color kGroupPurple = Color(0xFF6200EE);

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<GroupModel> _groups = [];

  @override
  void initState() {
    super.initState();
    context.read<GroupBloc>().add(LoadGroups());
  }

  void _openGroup(GroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupDetailScreen(group: group)),
    ).then((_) {
      if (mounted) context.read<GroupBloc>().add(LoadGroups());
    });
  }

  Future<void> _openCreateForm() async {
    final created = await showDialog<GroupModel>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CreateGroupDialog(),
    );
    if (created != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${created.name}" group created')),
      );
    }
  }

  Future<void> _openJoinGroupForm() async {
    final joined = await showDialog<GroupModel>(
      context: context,
      builder: (_) => const _JoinGroupDialog(),
    );
    if (joined != null && mounted) {
      context.read<GroupBloc>().add(LoadGroups());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined "${joined.name}" group')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGroupBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocConsumer<GroupBloc, GroupStateBase>(
                listener: (context, state) {
                  if (state is GroupError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GroupLoaded) _groups = state.groups;
                  final groups = _groups;
                  bool isLoading = state is GroupLoading && groups.isEmpty;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/images/group_illustration.jpg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _CreateNewCard(onTap: _openCreateForm),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _JoinGroupCard(onTap: _openJoinGroupForm),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'My Groups',
                          style:
                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (isLoading && groups.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (groups.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No groups yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: groups
                                .map(
                                  (g) => _GroupCard(
                                    group: g,
                                    onTap: () => _openGroup(g),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  );
                },
              ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }
}

const double kGroupCardWidth = 150;
const double kGroupCardHeight = 150;

class _GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback onTap;
  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: kGroupCardWidth,
        height: kGroupCardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kGroupBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.groups_outlined, color: kGroupPurple),
            ),
            const SizedBox(height: 10),
            Text(
              group.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: kGroupPurple,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateNewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: kGroupCardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: kGroupPurple, size: 28),
            SizedBox(height: 8),
            Text(
              'Create New',
              style: TextStyle(color: kGroupPurple, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
class _JoinGroupCard extends StatelessWidget {
  final VoidCallback onTap;
  const _JoinGroupCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: kGroupCardHeight,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, color: Colors.black87, size: 28),
            SizedBox(height: 8),
            Text(
              'Join Group',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinGroupDialog extends StatefulWidget {
  const _JoinGroupDialog();

  @override
  State<_JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<_JoinGroupDialog> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData('text/plain');
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      setState(() {
        _codeController.text = text.toUpperCase();
        _codeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _codeController.text.length),
        );
      });
    }
  }

  void _submit(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group code required')),
      );
      return;
    }
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group code must be 6 characters')),
      );
      return;
    }
    context.read<GroupBloc>().add(JoinGroupRequested(code: code));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BlocConsumer<GroupBloc, GroupStateBase>(
        listener: (context, state) {
          if (state is GroupJoinSuccess) {
            Navigator.pop(context, state.group);
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
              left: 24,
              right: 24,
              top: 28,
              bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Join New Group',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the unique 6-digit code shared by your friend to join their financial group.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 22),
                const Text('Group Code',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  enabled: !isSubmitting,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'E.G. AB1234',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    filled: true,
                    fillColor: kGroupBg.withOpacity(0.4),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste_rounded, size: 20),
                      color: Colors.grey[500],
                      onPressed: isSubmitting ? null : _pasteCode,
                      tooltip: 'Paste code',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
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
                        onPressed: isSubmitting ? null : () => _submit(context),
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
                            : const Text('Join',
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

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedIconIndex = 0;

  final List<IconData> _groupIcons = const [
    Icons.person_outline,
    Icons.people_outline,
    Icons.groups_outlined,
  ];

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
    context.read<GroupBloc>().add(CreateGroupRequested(name: name));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BlocConsumer<GroupBloc, GroupStateBase>(
        listener: (context, state) {
          if (state is GroupActionSuccess) {
            Navigator.pop(context, state.group);
          } else if (state is GroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is GroupLoading;
          return SingleChildScrollView(
            child: _CreateGroupForm(
              nameController: _nameController,
              icons: _groupIcons,
              selectedIconIndex: _selectedIconIndex,
              onIconSelected: (i) => setState(() => _selectedIconIndex = i),
              isSubmitting: isSubmitting,
              onCancel: () => Navigator.pop(context),
              onDone: _submit,
            ),
          );
        },
      ),
    );
  }
}

class _CreateGroupForm extends StatelessWidget {
  final TextEditingController nameController;
  final List<IconData> icons;
  final int selectedIconIndex;
  final ValueChanged<int> onIconSelected;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  const _CreateGroupForm({
    required this.nameController,
    required this.icons,
    required this.selectedIconIndex,
    required this.onIconSelected,
    required this.isSubmitting,
    required this.onCancel,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Create New Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Group Name', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: nameController,
            enabled: !isSubmitting,
            decoration: InputDecoration(
              hintText: 'Enter group name',
              filled: true,
              fillColor: kGroupBg.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Group Icon',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Row(
            children: List.generate(icons.length, (i) {
              final isSelected = i == selectedIconIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: isSubmitting ? null : () => onIconSelected(i),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        isSelected ? kGroupPurple : kGroupBg.withOpacity(0.6),
                    child: Icon(
                      icons[i],
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kGroupPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onDone,
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
                      : const Text('Done',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
