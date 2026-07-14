abstract class BalanceEvent {}

// Members' Balance Screen ဝင်တာနဲ့ / refresh လုပ်တာနဲ့ balance list ကို ခေါ်ဖို့
class LoadGroupBalance extends BalanceEvent {
  final String groupId;
  LoadGroupBalance({required this.groupId});
}

// "View Balance Detail" ကို နှိပ်လိုက်ရင် member တစ်ယောက်ရဲ့ detail ကိုခေါ်ဖို့
class LoadMemberBalanceDetail extends BalanceEvent {
  final String groupId;
  final String userId;
  LoadMemberBalanceDetail({required this.groupId, required this.userId});
}

// balance_event.dart
class LoadSettlementHistory extends BalanceEvent {
  final String groupId;
  final String userId;
  LoadSettlementHistory({required this.groupId, required this.userId});
}