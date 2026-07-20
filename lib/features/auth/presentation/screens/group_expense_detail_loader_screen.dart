import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/auth/data/expense_repository.dart';
import 'package:expense_tracker/features/auth/data/group_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/expense_bloc.dart'; 
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/group_model.dart';
import 'package:expense_tracker/features/auth/presentation/screens/group_expense_detail_screen.dart';

class GroupExpenseDetailLoaderScreen extends StatefulWidget {
  final String? expenseId;
  final String? groupId;

  const GroupExpenseDetailLoaderScreen({
    Key? key,
    this.expenseId,
    this.groupId,
  }) : super(key: key);

  @override
  State<GroupExpenseDetailLoaderScreen> createState() =>
      _GroupExpenseDetailLoaderScreenState();
}

class _GroupExpenseDetailLoaderScreenState
    extends State<GroupExpenseDetailLoaderScreen> {
  ExpenseModel? _expense;
  GroupModel? _group;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.expenseId == null ||
        widget.expenseId!.isEmpty ||
        widget.groupId == null ||
        widget.groupId!.isEmpty) {
      setState(() {
        _error = 'Expense ID or Group ID not found.';
        _loading = false;
      });
      return;
    }

    try {
      final expenseRepo = RepositoryProvider.of<ExpenseRepository>(context);
      final groupRepo = RepositoryProvider.of<GroupRepository>(context);

      final results = await Future.wait([
        expenseRepo.getExpenseDetail(widget.expenseId!),
        groupRepo.getGroupDetail(widget.groupId!),
      ]);

      if (!mounted) return;
      setState(() {
        _expense = results[0] as ExpenseModel;
        _group = results[1] as GroupModel;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Cannot get information.';
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

    if (_error != null || _expense == null || _group == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFE8DEF8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('Expense', style: TextStyle(color: Colors.black)),
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

    return BlocProvider<ExpenseBloc>(
      create: (context) => ExpenseBloc(
        RepositoryProvider.of<ExpenseRepository>(context),
      ),
      child: GroupExpenseDetailScreen(
        expenseId: widget.expenseId!,
        groupId: widget.groupId!,
        group: _group!,
      ),
    );
  }
}