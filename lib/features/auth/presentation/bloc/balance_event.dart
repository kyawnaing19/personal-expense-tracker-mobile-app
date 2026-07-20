abstract class BalanceEvent {}

class LoadGroupBalance extends BalanceEvent {
  final String groupId;
  LoadGroupBalance({required this.groupId});
}

class LoadMemberBalanceDetail extends BalanceEvent {
  final String groupId;
  final String userId;
  LoadMemberBalanceDetail({required this.groupId, required this.userId});
}

class LoadSettlementHistory extends BalanceEvent {
  final String groupId;
  final String userId;
  LoadSettlementHistory({required this.groupId, required this.userId});
}