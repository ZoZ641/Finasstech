part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardEvent {}

class CalculateDashboardMetrics extends DashboardEvent {
  final TimePeriod? incomePeriod;
  final TimePeriod? expensesPeriod;
  final TimePeriod? cashFlowPeriod;

  CalculateDashboardMetrics({
    this.incomePeriod,
    this.expensesPeriod,
    this.cashFlowPeriod,
  });
}

/*// New event to refresh metrics with current time periods (used after adding/editing expenses)
class RefreshDashboardMetrics extends DashboardEvent {}*/

// New enum to identify which widget is changing its time period
enum DashboardWidgetType { income, expenses, cashFlow }

// New event to change time period for a specific widget
class ChangeDashboardWidgetTimePeriod extends DashboardEvent {
  final DashboardWidgetType widgetType;
  final TimePeriod timePeriod;

  ChangeDashboardWidgetTimePeriod({
    required this.widgetType,
    required this.timePeriod,
  });
}

// Keep this for backward compatibility (can be removed later)
class ChangeDashboardTimePeriod extends DashboardEvent {
  final TimePeriod timePeriod;

  ChangeDashboardTimePeriod(this.timePeriod);
}
