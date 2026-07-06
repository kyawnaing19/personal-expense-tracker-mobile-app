abstract class AnalyticsEvent {}

class FetchAnalyticsEvent extends AnalyticsEvent {
  final String period; // 'week' သို့မဟုတ် 'month'
  final String subPeriod; // 'this' သို့မဟုတ် 'last'
  final String type; // 'expense' သို့မဟုတ် 'income'
   final DateTime? startDate; 
    final DateTime? endDate;   

  FetchAnalyticsEvent({
    required this.period,
    required this.subPeriod,
    required this.type,
    this.startDate,
    this.endDate,
   
  });
}

// analytics_event.dart ထဲတွင် အသစ်ထည့်ပါ
class ResetAnalyticsEvent extends AnalyticsEvent {}