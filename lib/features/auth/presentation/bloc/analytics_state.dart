import 'package:expense_tracker/models/analytics_model.dart';


abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}
class AnalyticsLoading extends AnalyticsState {}
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsResponse response;
  AnalyticsLoaded(this.response);
}
class AnalyticsEmpty extends AnalyticsState {}
class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}