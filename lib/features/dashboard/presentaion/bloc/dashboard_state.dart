part of 'dashboard_bloc.dart';

@immutable
sealed class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double income;
  final double expenses;
  final double cashFlow;
  final List<FlSpot> incomeData;
  final List<FlSpot> expensesData;
  final List<FlSpot> cashFlowData;
  final TimePeriod incomePeriod;
  final TimePeriod expensesPeriod;
  final TimePeriod cashFlowPeriod;

  DashboardLoaded({
    required this.income,
    required this.expenses,
    required this.cashFlow,
    required this.incomeData,
    required this.expensesData,
    required this.cashFlowData,
    required this.incomePeriod,
    required this.expensesPeriod,
    required this.cashFlowPeriod,
  });
}

class DashboardFailure extends DashboardState {
  final String message;

  DashboardFailure(this.message);
}
