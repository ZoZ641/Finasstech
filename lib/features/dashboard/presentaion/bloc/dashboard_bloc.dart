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

    // Emit loading state while recalculating
    emit(DashboardLoading());

    // Recalculate all metrics with the updated time periods
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

  // Fix in _calculateAllMetrics method
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
    final expensesAmount =
        _calculateExpenses(
          expensesFilteredExpenses,
        ).abs(); // Use absolute value for display

    // Calculate cash flow properly as income minus expenses (without negating expenses)
    // Since expenses are already stored as positive values in the system
    final cashFlow =
        _calculateIncome(cashFlowFilteredExpenses) -
        _calculateExpenses(cashFlowFilteredExpenses).abs();

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
        // Week starts on Saturday (weekday 6 in Dart)
        // Find the most recent Saturday (including today if it's Saturday)
        final int daysToSubtract = now.weekday == 6 ? 0 : (now.weekday + 1) % 7;
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysToSubtract));
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
    }

    return expenses
        .where(
          (expense) =>
              expense.date.isAfter(startDate) ||
              isSameDay(expense.date, startDate),
        )
        .toList();
  }

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
    final spots = _generateGraphData(
      expenses.where((e) => e.category.toLowerCase() == 'sales').toList(),
      period,
    );
    // Return spots without converting to abs()
    return spots;
  }

  List<FlSpot> _generateExpensesData(
    List<Expense> expenses,
    TimePeriod period,
  ) {
    // Generate data points for expenses graph based on time period
    final spots = _generateGraphData(
      expenses.where((e) => e.category.toLowerCase() != 'sales').toList(),
      period,
    );
    // Return spots without converting to abs()
    return spots;
  }

  List<FlSpot> _generateCashFlowData(
    List<Expense> expenses,
    TimePeriod period,
  ) {
    if (expenses.isEmpty) {
      return _generateEmptyDataPoints(period);
    }

    final now = DateTime.now();
    final dataByDate = <DateTime, double>{};

    // Initialize data points based on the period
    switch (period) {
      case TimePeriod.week:
        // Week starts on Saturday (weekday 6 in Dart)
        // Find the most recent Saturday (including today if it's Saturday)
        final int daysToSubtract = now.weekday == 6 ? 0 : (now.weekday + 1) % 7;
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysToSubtract));
        for (int i = 0; i < 7; i++) {
          final currentDate = weekStart.add(Duration(days: i));
          dataByDate[currentDate] = 0.0; // Initialize with 0
        }
        break;
      case TimePeriod.month:
        // Generate 4 data points for the current month (weekly sums)
        final monthStart = DateTime(now.year, now.month, 1);
        for (int i = 0; i < 4; i++) {
          final weekStart = monthStart.add(Duration(days: i * 7));
          dataByDate[weekStart] = 0.0; // Initialize with 0
        }
        break;
      case TimePeriod.quarter:
        // Generate 3 data points for the current quarter (monthly sums)
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final quarterStart = DateTime(now.year, quarterStartMonth, 1);
        for (int i = 0; i < 3; i++) {
          final monthStart = DateTime(
            quarterStart.year,
            quarterStart.month + i,
            1,
          );
          dataByDate[monthStart] = 0.0; // Initialize with 0
        }
        break;
      case TimePeriod.year:
        // Generate 4 data points for the current year (quarterly sums)
        final yearStart = DateTime(now.year, 1, 1);
        for (int i = 0; i < 4; i++) {
          final quarterStart = DateTime(yearStart.year, i * 3 + 1, 1);
          dataByDate[quarterStart] = 0.0; // Initialize with 0
        }
        break;
    }

    // Calculate income and expenses for each date
    for (var expense in expenses) {
      final date = _normalizeDate(expense.date, period);
      if (dataByDate.containsKey(date)) {
        if (expense.category.toLowerCase() == 'sales') {
          // Income (sales) adds to cash flow
          dataByDate[date] = (dataByDate[date] ?? 0) + expense.amount;
        } else {
          // Expenses subtract from cash flow (keep as negative)
          dataByDate[date] = (dataByDate[date] ?? 0) - expense.amount.abs();
        }
      }
    }

    // Sort dates and create FlSpots
    final sortedDates = dataByDate.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      // Allow negative values to be shown in the chart
      spots.add(FlSpot(i.toDouble(), dataByDate[sortedDates[i]] ?? 0));
    }

    return spots;
  }

  List<FlSpot> _generateGraphData(List<Expense> expenses, TimePeriod period) {
    if (expenses.isEmpty) {
      print('No expenses for period: $period, returning empty data points');
      return _generateEmptyDataPoints(period);
    }

    final now = DateTime.now();
    final dataByDate = <DateTime, double>{};

    // Initialize data points based on the period
    switch (period) {
      case TimePeriod.week:
        // Week starts on Saturday (weekday 6 in Dart)
        // Find the most recent Saturday (including today if it's Saturday)
        final int daysToSubtract = now.weekday == 6 ? 0 : (now.weekday + 1) % 7;
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysToSubtract));
        for (int i = 0; i < 7; i++) {
          final currentDate = weekStart.add(Duration(days: i));
          dataByDate[currentDate] = 0.0; // Initialize with 0
        }
        break;
      case TimePeriod.month:
        // Generate 4 data points for the current month (weekly sums)
        final monthStart = DateTime(now.year, now.month, 1);
        print('Month view - start date: $monthStart');
        for (int i = 0; i < 4; i++) {
          final weekStart = monthStart.add(Duration(days: i * 7));
          dataByDate[weekStart] = 0.0; // Initialize with 0
          print('Month week $i: $weekStart initialized to 0.0');
        }
        break;
      case TimePeriod.quarter:
        // Generate 3 data points for the current quarter (monthly sums)
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        final quarterStart = DateTime(now.year, quarterStartMonth, 1);
        for (int i = 0; i < 3; i++) {
          final monthStart = DateTime(
            quarterStart.year,
            quarterStart.month + i,
            1,
          );
          dataByDate[monthStart] = 0.0; // Initialize with 0
        }
        break;
      case TimePeriod.year:
        // Generate 4 data points for the current year (quarterly sums)
        final yearStart = DateTime(now.year, 1, 1);
        for (int i = 0; i < 4; i++) {
          final quarterStart = DateTime(yearStart.year, i * 3 + 1, 1);
          dataByDate[quarterStart] = 0.0; // Initialize with 0
        }
        break;
    }

    // Group expenses by date according to period
    for (var expense in expenses) {
      final date = _normalizeDate(expense.date, period);
      if (dataByDate.containsKey(date)) {
        dataByDate[date] = (dataByDate[date] ?? 0) + expense.amount;
        if (period == TimePeriod.month) {
          print(
            'Month view - expense added: ${expense.date} normalized to $date, amount: ${expense.amount}, total: ${dataByDate[date]}',
          );
        }
      } else if (period == TimePeriod.month) {
        print(
          'Month view - expense date not found in dataByDate: ${expense.date} normalized to $date',
        );
      }
    }

    // Sort dates and create FlSpots
    final sortedDates = dataByDate.keys.toList()..sort();
    if (period == TimePeriod.month) {
      print('Month view - sorted dates: $sortedDates');
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedDates.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataByDate[sortedDates[i]] ?? 0));
      if (period == TimePeriod.month) {
        print(
          'Month view - spot $i: ${i.toDouble()}, ${dataByDate[sortedDates[i]]}',
        );
      }
    }

    if (period == TimePeriod.month) {
      print('Month view - final spots: $spots');
    }

    return spots;
  }

  List<FlSpot> _generateEmptyDataPoints(TimePeriod period) {
    // Generate empty data points for each period
    switch (period) {
      case TimePeriod.week:
        return List.generate(7, (index) => FlSpot(index.toDouble(), 0));
      case TimePeriod.month:
        return List.generate(4, (index) => FlSpot(index.toDouble(), 0));
      case TimePeriod.quarter:
        return List.generate(3, (index) => FlSpot(index.toDouble(), 0));
      case TimePeriod.year:
        return List.generate(4, (index) => FlSpot(index.toDouble(), 0));
    }
  }

  DateTime _normalizeDate(DateTime date, TimePeriod period) {
    final now = DateTime.now();
    switch (period) {
      case TimePeriod.week:
        // Week starts on Saturday (weekday 6 in Dart)
        // Find the most recent Saturday for this date
        final int daysToSubtract =
            date.weekday == 6 ? 0 : (date.weekday + 1) % 7;
        return DateTime(
          date.year,
          date.month,
          date.day,
        ).subtract(Duration(days: daysToSubtract));
      case TimePeriod.month:
        // Calculate which week of the month this date belongs to
        final monthStart = DateTime(date.year, date.month, 1);
        final daysSinceMonthStart = date.difference(monthStart).inDays;
        final weekOfMonth = daysSinceMonthStart ~/ 7; // 0, 1, 2, or 3

        // Get the first day of the corresponding week
        return DateTime(date.year, date.month, 1 + (weekOfMonth * 7));
      case TimePeriod.quarter:
        return DateTime(date.year, date.month, 1); // Monthly for quarter view
      case TimePeriod.year:
        // Get the start of the quarter for the given date
        final quarterStartMonth = ((date.month - 1) ~/ 3) * 3 + 1;
        return DateTime(date.year, quarterStartMonth, 1);
    }
  }
}
