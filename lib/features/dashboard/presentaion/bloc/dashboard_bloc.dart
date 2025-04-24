import 'package:finasstech/core/usecase/noparams.dart';
import 'package:finasstech/features/dashboard/presentaion/widgets/graph_widget.dart';
import 'package:finasstech/features/expenses/domain/entities/expense.dart';
import 'package:finasstech/features/expenses/domain/usecases/get_all_expenses.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

// Move DashboardMetrics to top level
class DashboardMetrics {
  final double income;
  final double expenses;
  final double cashFlow;
  final List<FlSpot> incomeData;
  final List<FlSpot> expensesData;
  final List<FlSpot> cashFlowData;

  DashboardMetrics({
    required this.income,
    required this.expenses,
    required this.cashFlow,
    required this.incomeData,
    required this.expensesData,
    required this.cashFlowData,
  });
}

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAllExpenses getAllExpenses;
  List<Expense> _cachedExpenses = [];

  DashboardBloc({required this.getAllExpenses}) : super(DashboardInitial()) {
    on<CalculateDashboardMetrics>(_onCalculateDashboardMetrics);
    on<ChangeDashboardWidgetTimePeriod>(_onChangeDashboardWidgetTimePeriod);
    /*on<RefreshDashboardMetrics>(_onRefreshDashboardMetrics);*/
  }

  // Get initial metrics with separate time periods for each widget
  Future<void> _onCalculateDashboardMetrics(
    CalculateDashboardMetrics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final result = await getAllExpenses(NoParams());

    result.fold((failure) => emit(DashboardFailure(failure.message)), (
      expenses,
    ) {
      _cachedExpenses = expenses;

      final TimePeriod incomePeriod = event.incomePeriod ?? TimePeriod.week;
      final TimePeriod expensesPeriod = event.expensesPeriod ?? TimePeriod.week;
      final TimePeriod cashFlowPeriod = event.cashFlowPeriod ?? TimePeriod.week;

      final metrics = _calculateAllMetrics(
        incomePeriod: incomePeriod,
        expensesPeriod: expensesPeriod,
        cashFlowPeriod: cashFlowPeriod,
      );

      emit(
        DashboardLoaded(
          income: metrics.income,
          expenses: metrics.expenses,
          cashFlow: metrics.cashFlow,
          incomeData: metrics.incomeData,
          expensesData: metrics.expensesData,
          cashFlowData: metrics.cashFlowData,
          incomePeriod: incomePeriod,
          expensesPeriod: expensesPeriod,
          cashFlowPeriod: cashFlowPeriod,
        ),
      );
    });
  }

  /*  // Refresh metrics using cached expenses (used when expense updates happen)
  Future<void> _onRefreshDashboardMetrics(
    RefreshDashboardMetrics event,
    Emitter<DashboardState> emit,
  ) async {
    if (_cachedExpenses.isEmpty) {
      // If no cached expenses, fetch them first
      add(CalculateDashboardMetrics());
      return;
    }

    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
    }

    // Get current periods from state or use defaults
    TimePeriod incomePeriod = TimePeriod.week;
    TimePeriod expensesPeriod = TimePeriod.week;
    TimePeriod cashFlowPeriod = TimePeriod.week;

    if (state is DashboardLoaded) {
      final currentState = state as DashboardLoaded;
      incomePeriod = currentState.incomePeriod;
      expensesPeriod = currentState.expensesPeriod;
      cashFlowPeriod = currentState.cashFlowPeriod;
    }

    final metrics = _calculateAllMetrics(
      incomePeriod: incomePeriod,
      expensesPeriod: expensesPeriod,
      cashFlowPeriod: cashFlowPeriod,
    );

    emit(
      DashboardLoaded(
        income: metrics.income,
        expenses: metrics.expenses,
        cashFlow: metrics.cashFlow,
        incomeData: metrics.incomeData,
        expensesData: metrics.expensesData,
        cashFlowData: metrics.cashFlowData,
        incomePeriod: incomePeriod,
        expensesPeriod: expensesPeriod,
        cashFlowPeriod: cashFlowPeriod,
      ),
    );
  }*/

  // Change time period for a specific widget only
  Future<void> _onChangeDashboardWidgetTimePeriod(
    ChangeDashboardWidgetTimePeriod event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoaded) {
      return;
    }

    final currentState = state as DashboardLoaded;
    TimePeriod incomePeriod = currentState.incomePeriod;
    TimePeriod expensesPeriod = currentState.expensesPeriod;
    TimePeriod cashFlowPeriod = currentState.cashFlowPeriod;

    // Update only the time period for the specific widget
    switch (event.widgetType) {
      case DashboardWidgetType.income:
        incomePeriod = event.timePeriod;
        break;
      case DashboardWidgetType.expenses:
        expensesPeriod = event.timePeriod;
        break;
      case DashboardWidgetType.cashFlow:
        cashFlowPeriod = event.timePeriod;
        break;
    }

    final metrics = _calculateAllMetrics(
      incomePeriod: incomePeriod,
      expensesPeriod: expensesPeriod,
      cashFlowPeriod: cashFlowPeriod,
    );

    emit(
      DashboardLoaded(
        income: metrics.income,
        expenses: metrics.expenses,
        cashFlow: metrics.cashFlow,
        incomeData: metrics.incomeData,
        expensesData: metrics.expensesData,
        cashFlowData: metrics.cashFlowData,
        incomePeriod: incomePeriod,
        expensesPeriod: expensesPeriod,
        cashFlowPeriod: cashFlowPeriod,
      ),
    );
  }

  // Calculate all metrics with potentially different time periods for each widget
  DashboardMetrics _calculateAllMetrics({
    required TimePeriod incomePeriod,
    required TimePeriod expensesPeriod,
    required TimePeriod cashFlowPeriod,
  }) {
    // Filter expenses for each widget based on its own time period
    final incomeFilteredExpenses = _filterExpensesByTimePeriod(
      _cachedExpenses,
      incomePeriod,
    );
    final expensesFilteredExpenses = _filterExpensesByTimePeriod(
      _cachedExpenses,
      expensesPeriod,
    );
    final cashFlowFilteredExpenses = _filterExpensesByTimePeriod(
      _cachedExpenses,
      cashFlowPeriod,
    );

    // Calculate totals
    final income = _calculateIncome(incomeFilteredExpenses);
    final expensesAmount = _calculateExpenses(expensesFilteredExpenses);
    final cashFlow =
        _calculateIncome(cashFlowFilteredExpenses) -
        (_calculateExpenses(cashFlowFilteredExpenses) * -1);

    // Generate graph data
    final incomeData = _generateIncomeData(
      incomeFilteredExpenses,
      incomePeriod,
    );
    final expensesData = _generateExpensesData(
      expensesFilteredExpenses,
      expensesPeriod,
    );
    final cashFlowData = _generateCashFlowData(
      cashFlowFilteredExpenses,
      cashFlowPeriod,
    );

    return DashboardMetrics(
      income: income,
      expenses: expensesAmount,
      cashFlow: cashFlow,
      incomeData: incomeData,
      expensesData: expensesData,
      cashFlowData: cashFlowData,
    );
  }

  List<Expense> _filterExpensesByTimePeriod(
    List<Expense> expenses,
    TimePeriod period,
  ) {
    final now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case TimePeriod.week:
        startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
        break;
      case TimePeriod.month:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimePeriod.quarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, quarterStartMonth, 1);
        break;
      case TimePeriod.year:
        startDate = DateTime(now.year, 1, 1);
        break;
      case TimePeriod.custom:
        // Handle custom date range if needed
        startDate = DateTime(now.year, now.month, 1); // Default to month
        break;
    }

    return expenses
        .where((expense) => expense.date.isAfter(startDate))
        .toList();
  }

  double _calculateIncome(List<Expense> expenses) {
    return expenses
        .where((expense) => expense.category.toLowerCase() == 'sales')
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double _calculateExpenses(List<Expense> expenses) {
    return expenses
        .where((expense) => expense.category.toLowerCase() != 'sales')
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<FlSpot> _generateIncomeData(List<Expense> expenses, TimePeriod period) {
    // Generate data points for income graph based on time period
    return _generateGraphData(
      expenses.where((e) => e.category.toLowerCase() == 'sales').toList(),
      period,
    );
  }

  List<FlSpot> _generateExpensesData(
    List<Expense> expenses,
    TimePeriod period,
  ) {
    // Generate data points for expenses graph based on time period
    return _generateGraphData(
      expenses.where((e) => e.category.toLowerCase() != 'sales').toList(),
      period,
    );
  }

  List<FlSpot> _generateCashFlowData(
    List<Expense> expenses,
    TimePeriod period,
  ) {
    // Generate data points for cash flow (income - expenses) graph based on time period
    final incomeByDate = <DateTime, double>{};
    final expensesByDate = <DateTime, double>{};
    final cashFlowByDate = <DateTime, double>{};

    for (var expense in expenses) {
      final date = _normalizeDate(expense.date, period);

      if (expense.category.toLowerCase() == 'sales') {
        incomeByDate[date] = (incomeByDate[date] ?? 0) + expense.amount;
      } else {
        expensesByDate[date] = (expensesByDate[date] ?? 0) + expense.amount;
      }
    }

    // Combine all unique dates
    final allDates =
        {...incomeByDate.keys, ...expensesByDate.keys}.toList()..sort();

    // Calculate cash flow for each date
    for (var date in allDates) {
      cashFlowByDate[date] =
          (incomeByDate[date] ?? 0) - (expensesByDate[date] ?? 0);
    }

    // Convert to FlSpot list
    final spots = <FlSpot>[];
    for (var i = 0; i < allDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), cashFlowByDate[allDates[i]] ?? 0));
    }

    return spots;
  }

  List<FlSpot> _generateGraphData(List<Expense> expenses, TimePeriod period) {
    if (expenses.isEmpty) return [];

    final dataByDate = <DateTime, double>{};

    // Group expenses by date according to period
    for (var expense in expenses) {
      final date = _normalizeDate(expense.date, period);
      dataByDate[date] = (dataByDate[date] ?? 0) + expense.amount;
    }

    // Sort dates
    final sortedDates = dataByDate.keys.toList()..sort();

    // Create FlSpots
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataByDate[sortedDates[i]] ?? 0));
    }

    return spots;
  }

  DateTime _normalizeDate(DateTime date, TimePeriod period) {
    switch (period) {
      case TimePeriod.week:
        return DateTime(date.year, date.month, date.day); // Daily for week view
      case TimePeriod.month:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        ); // Weekly for month view
      case TimePeriod.quarter:
        return DateTime(date.year, date.month, 1); // Monthly for quarter view
      case TimePeriod.year:
        return DateTime(date.year, date.month, 1); // Monthly for year view
      case TimePeriod.custom:
        return DateTime(date.year, date.month, date.day); // Default to daily
    }
  }
}
