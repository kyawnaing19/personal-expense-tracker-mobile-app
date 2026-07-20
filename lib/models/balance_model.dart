class MemberBalanceModel {
  final String userId;
  final String name;
  final String? avatar;
  final int totalReceivable; 
  final int totalPayable; 

  MemberBalanceModel({
    required this.userId,
    required this.name,
    this.avatar,
    required this.totalReceivable,
    required this.totalPayable,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory MemberBalanceModel.fromJson(Map<String, dynamic> json) {
    return MemberBalanceModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      totalReceivable: _toInt(json['total_receivable']),
      totalPayable: _toInt(json['total_payable']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class BalanceSplitItem {
  final String splitId;
  final String expense; 
  final String personName; 
  final int amountOwed;
  final int amountPaid;
  final int remaining;

  BalanceSplitItem({
    required this.splitId,
    required this.expense,
    required this.personName,
    required this.amountOwed,
    required this.amountPaid,
    required this.remaining,
  });

  double get progress =>
      amountOwed == 0 ? 0 : (amountPaid / amountOwed).clamp(0, 1).toDouble();

  int get progressPercent => (progress * 100).round();

  factory BalanceSplitItem.fromJson(Map<String, dynamic> json) {
    return BalanceSplitItem(
      splitId: json['split_id']?.toString() ?? '',
      expense: json['expense']?.toString() ?? '',
      personName:
          (json['owed_by'] ?? json['paid_to'] ?? json['owed_to'] ?? '')
              .toString(),
      amountOwed: _toInt(json['amount_owed']),
      amountPaid: _toInt(json['amount_paid']),
      remaining: _toInt(json['remaining']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}


class MemberBalanceDetailModel {
  final List<BalanceSplitItem> owedToOthers; 
  final List<BalanceSplitItem> owedByOthers; 

  MemberBalanceDetailModel({
    required this.owedToOthers,
    required this.owedByOthers,
  });

  int get totalToReceive =>
      owedByOthers.fold(0, (sum, e) => sum + e.remaining);

  int get totalToPay => owedToOthers.fold(0, (sum, e) => sum + e.remaining);

  factory MemberBalanceDetailModel.fromJson(Map<String, dynamic> json) {
    final owedToOthersJson = json['owed_to_others'] as List<dynamic>? ?? [];
    final owedByOthersJson = json['owed_by_others'] as List<dynamic>? ?? [];
    return MemberBalanceDetailModel(
      owedToOthers: owedToOthersJson
          .whereType<Map<String, dynamic>>()
          .map((e) => BalanceSplitItem.fromJson(e))
          .toList(),
      owedByOthers: owedByOthersJson
          .whereType<Map<String, dynamic>>()
          .map((e) => BalanceSplitItem.fromJson(e))
          .toList(),
    );
  }
}

class SettlementHistoryItem {
  final String expense;
  final String otherPartyName; 
  final int amount;
  final DateTime? confirmedAt;

  SettlementHistoryItem({
    required this.expense,
    required this.otherPartyName,
    required this.amount,
    this.confirmedAt,
  });

  factory SettlementHistoryItem.fromJson(Map<String, dynamic> json) {
    return SettlementHistoryItem(
      expense: json['expense']?.toString() ?? 'N/A',
      otherPartyName:
          (json['paid_to'] ?? json['received_from'] ?? '').toString(),
      amount: _toInt(json['amount']),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'].toString())
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class SettlementHistoryModel {
  final List<SettlementHistoryItem> paidToOthers;
  final List<SettlementHistoryItem> receivedByOthers;

  SettlementHistoryModel({
    required this.paidToOthers,
    required this.receivedByOthers,
  });

  factory SettlementHistoryModel.fromJson(Map<String, dynamic> json) {
    final paidJson = json['paid_to_others'] as List<dynamic>? ?? [];
    final receivedJson = json['received_by_others'] as List<dynamic>? ?? [];
    return SettlementHistoryModel(
      paidToOthers: paidJson
          .whereType<Map<String, dynamic>>()
          .map((e) => SettlementHistoryItem.fromJson(e))
          .toList(),
      receivedByOthers: receivedJson
          .whereType<Map<String, dynamic>>()
          .map((e) => SettlementHistoryItem.fromJson(e))
          .toList(),
    );
  }
}