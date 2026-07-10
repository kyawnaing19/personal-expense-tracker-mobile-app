abstract class AnalyticsEvent {}

class FetchAnalyticsEvent extends AnalyticsEvent {
  final String period; 
  final String subPeriod; 
  final String type; 
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

class ResetAnalyticsEvent extends AnalyticsEvent {}