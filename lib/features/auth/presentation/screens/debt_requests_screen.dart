import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/settlement_request_model.dart';
import '../../data/settlement_request_repository.dart';
import '../bloc/settlement_request_bloc.dart';
import '../bloc/settlement_request_event.dart';
import '../bloc/settlement_request_state.dart';

const Color kDebtBg = Color(0xFFE8DEF8);
const Color kDebtPurple = Color(0xFF6200EE);
const Color kPendingBg = Color(0xFFFCEBD0);
const Color kPendingText = Color(0xFFB8860B);
const Color kConfirmedBg = Color(0xFFD9F2E3);
const Color kConfirmedText = Color(0xFF2E9E5B);
const Color kRejectedBg = Color(0xFFFBDCE0);
const Color kRejectedText = Color(0xFFD8455D);

/// Profile -> "Debt Requests" ကနေဝင်ရင် ပေါ်မယ့် screen။
/// [BlocProvider] ကို widget ရဲ့ အပြင်ဘက်ကနေ wrap ပေးထားပြီးသား ဖြစ်ပါက
/// [DebtRequestsView] တစ်ခုတည်း တိုက်ရိုက်သုံးလို့ရပါတယ်။
class DebtRequestsScreen extends StatelessWidget {
  const DebtRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettlementRequestBloc(SettlementRequestRepository())
        ..add(LoadSettlementRequests(role: SettlementRequestRole.payer)),
      child: const DebtRequestsView(),
    );
  }
}

class DebtRequestsView extends StatelessWidget {
  const DebtRequestsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDebtBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            const SizedBox(height: 8),
            _buildRoleAndFilterBar(context),
            const SizedBox(height: 8),
            Expanded(
              child: BlocConsumer<SettlementRequestBloc,
                  SettlementRequestStateBase>(
                listener: (context, state) {
                  if (state is SettlementRequestActionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  return _buildBody(context, state);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
const _RoundedIconButton(
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Debt Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // back button နဲ့ balance ဖြစ်အောင်
        ],
      ),
    );
  }

  Widget _buildRoleAndFilterBar(BuildContext context) {
    return BlocBuilder<SettlementRequestBloc, SettlementRequestStateBase>(
      builder: (context, state) {
        final role = _roleOf(state);
        final statusFilter = _statusFilterOf(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _RoleToggle(
                      selectedRole: role,
                      onChanged: (newRole) {
                        context
                            .read<SettlementRequestBloc>()
                            .add(ChangeSettlementRequestRole(newRole));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  _RoundedIconButton(
                    active: statusFilter != null,
                    onTap: () => _openFilterSheet(context, statusFilter),
                    child: Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: statusFilter != null ? Colors.white : const Color.fromARGB(221, 117, 105, 105),
                    ),
                  ),
                ],
              ),
            ),
            if (statusFilter != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context
                          .read<SettlementRequestBloc>()
                          .add(ApplyStatusFilter(null)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              statusFilter.label,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.close,
                                size: 14, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context
                          .read<SettlementRequestBloc>()
                          .add(ApplyStatusFilter(null)),
                      child: const Text(
                        'Clear Filter',
                        style: TextStyle(
                          color: kDebtPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  SettlementRequestRole _roleOf(SettlementRequestStateBase state) {
    if (state is SettlementRequestLoaded) return state.role;
    if (state is SettlementRequestLoading) return state.role;
    if (state is SettlementRequestError) return state.role;
    return SettlementRequestRole.payer;
  }

  SettlementRequestStatus? _statusFilterOf(SettlementRequestStateBase state) {
    if (state is SettlementRequestLoaded) return state.statusFilter;
    if (state is SettlementRequestLoading) return state.statusFilter;
    if (state is SettlementRequestError) return state.statusFilter;
    return null;
  }

  Widget _buildBody(BuildContext context, SettlementRequestStateBase state) {
    if (state is SettlementRequestLoading ||
        state is SettlementRequestInitial) {
      return const Center(child: CircularProgressIndicator(color: kDebtPurple));
    }

    if (state is SettlementRequestError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context
                    .read<SettlementRequestBloc>()
                    .add(LoadSettlementRequests(role: state.role)),
                style: ElevatedButton.styleFrom(backgroundColor: kDebtPurple),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final loaded = state is SettlementRequestLoaded
        ? state
        : (state is SettlementRequestActionError
            ? SettlementRequestLoaded(
                role: state.role,
                statusFilter: state.statusFilter,
                requests: state.requests,
              )
            : null);
    if (loaded == null) return const SizedBox.shrink();

    if (loaded.requests.isEmpty) {
      return Center(
        child: Text(
          loaded.role == SettlementRequestRole.payer
              ? 'No requests waiting on you yet'
              : 'You haven\'t sent any settle requests yet',
          style: TextStyle(color: Colors.grey[700]),
        ),
      );
    }

    return RefreshIndicator(
      color: kDebtPurple,
      onRefresh: () async {
        context
            .read<SettlementRequestBloc>()
            .add(LoadSettlementRequests(role: loaded.role));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: loaded.requests.length,
        itemBuilder: (context, index) {
          final item = loaded.requests[index];
          final isProcessing =
              loaded.processingRequestIds.contains(item.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _RequestCard(
              request: item,
              role: loaded.role,
              isProcessing: isProcessing,
              onConfirm: () => context
                  .read<SettlementRequestBloc>()
                  .add(ConfirmSettlementRequested(item.id)),
              onReject: () => context
                  .read<SettlementRequestBloc>()
                  .add(RejectSettlementRequested(item.id)),
            ),
          );
        },
      ),
    );
  }

  void _openFilterSheet(
      BuildContext context, SettlementRequestStatus? currentFilter) {
    final bloc = context.read<SettlementRequestBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _FilterSheet(
          initialStatus: currentFilter,
          onApply: (status) {
            bloc.add(ApplyStatusFilter(status));
            Navigator.pop(sheetContext);
          },
        );
      },
    );
  }
}

class _RoleToggle extends StatelessWidget {
  final SettlementRequestRole selectedRole;
  final ValueChanged<SettlementRequestRole> onChanged;

  const _RoleToggle({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RoleTab(
              label: 'Received Requests',
              selected: selectedRole == SettlementRequestRole.payer,
              onTap: () => onChanged(SettlementRequestRole.payer),
            ),
          ),
          Expanded(
            child: _RoleTab(
              label: 'Sent Requests',
              selected: selectedRole == SettlementRequestRole.claimant,
              onTap: () => onChanged(SettlementRequestRole.claimant),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? kDebtPurple : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  final Widget child;
  final bool active;
  final VoidCallback? onTap;

  const _RoundedIconButton({
    required this.child,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? kDebtPurple : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(width: 18, height: 18, child: Center(child: child)),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final SettlementRequestStatus? initialStatus;
  final ValueChanged<SettlementRequestStatus?> onApply;

  const _FilterSheet({required this.initialStatus, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  SettlementRequestStatus? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Status',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final status in SettlementRequestStatus.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: InkWell(
                onTap: () => setState(() => _selected = status),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(status.label, style: const TextStyle(fontSize: 15)),
                    Radio<SettlementRequestStatus>(
                      value: status,
                      groupValue: _selected,
                      activeColor: kDebtPurple,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) => setState(() => _selected = value),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDebtPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SettlementRequestModel request;
  final SettlementRequestRole role;
  final bool isProcessing;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.role,
    required this.isProcessing,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final showActions =
        role == SettlementRequestRole.payer && request.isPending;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kDebtBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.groups_outlined,
                    color: kDebtPurple, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.group,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.expense,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: request.status),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == SettlementRequestRole.payer
                          ? 'Paid From'
                          : 'Paid To',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.otherPartyName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAmount(request.amount),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 14),
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            const SizedBox(height: 14),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDebtPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Confirm'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kRejectedText,
                        side: const BorderSide(color: kRejectedText),
                        minimumSize: const Size(double.infinity, 44),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _formatAmount(int amount) {
    final s = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color bg;
    Color fg;
    String label;
    switch (normalized) {
      case 'confirmed':
        bg = kConfirmedBg;
        fg = kConfirmedText;
        label = 'Confirmed';
        break;
      case 'rejected':
        bg = kRejectedBg;
        fg = kRejectedText;
        label = 'Rejected';
        break;
      default:
        bg = kPendingBg;
        fg = kPendingText;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}