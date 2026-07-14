/// GET /settlement-requests?role=payer|claimant ရဲ့ list item တစ်ခုစီ
///
/// role=payer ("Received Requests" - ကိုယ်က ငွေရှင်/payer, သူများကျခံပြီးကြောင်း
/// claim တင်ထားတာကို confirm/reject လုပ်ဖို့) response ထဲမှာ:
///   { id, group, expense, claimed_by, amount, status, created_at }
///
/// role=claimant ("Sent Requests" - ကိုယ်တိုင်က settle request တင်ခဲ့တာ)
/// response ထဲမှာ:
///   { id, group, expense, paid_to, amount, status, created_at }
///
/// field နှစ်ခုလုံးကို တစ်ခုတည်းသော model ထဲမှာ ပေါင်းထားပြီး
/// [otherPartyName] getter ကနေတစ်ဆင့် card ပေါ်မှာ "Paid From"/"Paid To"
/// ဘယ်ဟာပြရမလဲဆိုတာ ခွဲသုံးနိုင်အောင် လုပ်ထားပါတယ်။
class SettlementRequestModel {
  final String id;
  final String group;
  final String expense;
  final String? claimedBy; // role=payer မှာသာပါမယ်
  final String? paidTo; // role=claimant မှာသာပါမယ်
  final int amount;
  final String status; // pending | confirmed | rejected
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

  /// "Received Requests" card မှာ "Paid From : <name>", "Sent Requests"
  /// card မှာ "Paid To : <name>" လို့ ပြဖို့ သုံးမယ့် name
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

/// Debt Requests screen ရဲ့ navigation bar (Received / Sent) နှင့်
/// backend ရဲ့ `role` query param ကို တွဲသုံးဖို့
enum SettlementRequestRole { payer, claimant }

extension SettlementRequestRoleX on SettlementRequestRole {
  String get apiValue =>
      this == SettlementRequestRole.payer ? 'payer' : 'claimant';
}

/// Filter bottom sheet က status ရွေးစရာ ၃မျိုး
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