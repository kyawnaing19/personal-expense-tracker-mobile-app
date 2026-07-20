class SettlementRequestModel {
  final String id;
  final String group;
  final String expense;
  final String? claimedBy; 
  final String? paidTo; 
  final int amount;
  final String status; 
  final DateTime? createdAt;

  SettlementRequestModel({
    required this.id,
    required this.group,
    required this.expense,
    this.claimedBy,
    this.paidTo,
    required this.amount,
    required this.status,
    this.createdAt,
  });

  String get otherPartyName => claimedBy ?? paidTo ?? '';

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory SettlementRequestModel.fromJson(Map<String, dynamic> json) {
    return SettlementRequestModel(
      id: json['id']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      expense: json['expense']?.toString() ?? '',
      claimedBy: json['claimed_by']?.toString(),
      paidTo: json['paid_to']?.toString(),
      amount: _toInt(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  SettlementRequestModel copyWith({String? status}) {
    return SettlementRequestModel(
      id: id,
      group: group,
      expense: expense,
      claimedBy: claimedBy,
      paidTo: paidTo,
      amount: amount,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

enum SettlementRequestRole { payer, claimant }

extension SettlementRequestRoleX on SettlementRequestRole {
  String get apiValue =>
      this == SettlementRequestRole.payer ? 'payer' : 'claimant';
}

enum SettlementRequestStatus { pending, confirmed, rejected }

extension SettlementRequestStatusX on SettlementRequestStatus {
  String get apiValue {
    switch (this) {
      case SettlementRequestStatus.pending:
        return 'pending';
      case SettlementRequestStatus.confirmed:
        return 'confirmed';
      case SettlementRequestStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case SettlementRequestStatus.pending:
        return 'Pending';
      case SettlementRequestStatus.confirmed:
        return 'Confirmed';
      case SettlementRequestStatus.rejected:
        return 'Rejected';
    }
  }
}