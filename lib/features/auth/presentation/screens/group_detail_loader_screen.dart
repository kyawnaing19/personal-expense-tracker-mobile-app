import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/data/group_repository.dart';
import 'package:expense_tracker/models/group_model.dart';
import 'package:expense_tracker/features/auth/presentation/screens/group_detail_screen.dart'; // ⚠️ path/name ကို သင့် project အတိုင်း ချိန်ညှိပါ

class GroupDetailLoaderScreen extends StatefulWidget {
  final String? groupId;
  const GroupDetailLoaderScreen({Key? key, this.groupId}) : super(key: key);

  @override
  State<GroupDetailLoaderScreen> createState() => _GroupDetailLoaderScreenState();
}

class _GroupDetailLoaderScreenState extends State<GroupDetailLoaderScreen> {
  GroupModel? _group;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  Future<void> _loadGroup() async {
    if (widget.groupId == null || widget.groupId!.isEmpty) {
      setState(() {
        _error = 'Group ID not found.';
        _loading = false;
      });
      return;
    }

    try {
      final repo = RepositoryProvider.of<GroupRepository>(context);
      final group = await repo.getGroupDetail(widget.groupId!);

      if (!mounted) return;
      setState(() {
        _group = group;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Cannot get group information.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _group == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEBE0FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('Group', style: TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _error ?? 'Something wrong.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return GroupDetailScreen(group: _group!);
  }
}