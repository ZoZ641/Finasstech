import 'package:finasstech/features/dashboard/presentaion/widgets/graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../budgeting/presentation/bloc/budget_bloc.dart';
import '../../../budgeting/presentation/pages/create_budget_page.dart';
import '../../../expenses/presentation/bloc/expense_bloc.dart';
import '../../../expenses/presentation/pages/add_expense.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
    context.read<DashboardBloc>().add(CalculateDashboardMetrics());
    _checkYearEnd();
  }

  /// Checks if the current year is different from the budget's creation year.
  /// If it is, shows a dialog prompting the user to create a new budget.
  ///
  /// This method is called during initialization to ensure users are prompted
  /// to create a new budget at the start of each year.
  void _checkYearEnd() {
    final now = DateTime.now();
    final budgetState = context.read<BudgetBloc>().state;
    if (budgetState is BudgetLoaded) {
      if (budgetState.budget.createdAt.year < now.year) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  title: const Text('New Year, New Budget'),
                  content: const Text(
                    'It\'s a new year! Create a new budget to stay on track with your financial goals.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateBudgetPage(),
                          ),
                        );
                      },
                      child: const Text('Create Budget'),
                    ),
                  ],
                ),
          );
        });
      }
    }
  }

  /// Handles the change of time period for the income widget.
  ///
  /// This method dispatches a [ChangeDashboardWidgetTimePeriod] event to the [DashboardBloc]
  /// with the specified [period] for the income widget type.
  ///
  /// @param period The new time period to be applied to the income widget
  void _handleIncomeTimePeriodChanged(TimePeriod period) {
    context.read<DashboardBloc>().add(
      ChangeDashboardWidgetTimePeriod(
        widgetType: DashboardWidgetType.income,
        timePeriod: period,
      ),
    );
  }

  /// Handles the change of time period for the expenses widget.
  ///
  /// This method dispatches a [ChangeDashboardWidgetTimePeriod] event to the [DashboardBloc]
  /// with the specified [period] for the expenses widget type.
  ///
  /// @param period The new time period to be applied to the expenses widget
  void _handleExpensesTimePeriodChanged(TimePeriod period) {
    context.read<DashboardBloc>().add(
      ChangeDashboardWidgetTimePeriod(
        widgetType: DashboardWidgetType.expenses,
        timePeriod: period,
      ),
    );
  }

  /// Handles the change of time period for the cash flow widget.
  ///
  /// This method dispatches a [ChangeDashboardWidgetTimePeriod] event to the [DashboardBloc]
  /// with the specified [period] for the cash flow widget type.
  ///
  /// @param period The new time period to be applied to the cash flow widget
  void _handleCashFlowTimePeriodChanged(TimePeriod period) {
    context.read<DashboardBloc>().add(
      ChangeDashboardWidgetTimePeriod(
        widgetType: DashboardWidgetType.cashFlow,
        timePeriod: period,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseLoaded) {
          // Recalculate dashboard metrics when expenses change
          context.read<DashboardBloc>().add(CalculateDashboardMetrics());
        }
      },
      child: BlocListener<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateBudgetPage()),
            );
          } else if (state is BudgetDataExistsState && state.hasExistingData) {
            context.read<BudgetBloc>().add(GetLatestBudgetEvent());
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text("Dashboard")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Capture the bloc reference before the async gap
              final dashboardBloc = context.read<DashboardBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpensePage()),
              ).then((_) {
                if (mounted) {
                  dashboardBloc.add(CalculateDashboardMetrics());
                }
              });
            },
            child: const Icon(Icons.add),
          ),
          body: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardFailure) {
                return Center(child: Text(state.message));
              } else if (state is DashboardLoaded) {
                return ListView(
                  children: [
                    GraphWidget(
                      title: 'Income',
                      amount: state.income.toStringAsFixed(0),
                      isGraph: false,
                      onTimePeriodChanged: _handleIncomeTimePeriodChanged,
                    ),
                    GraphWidget(
                      title: 'Expenses',
                      amount: (state.expenses == 0
                              ? state.expenses
                              : state.expenses * -1)
                          .toStringAsFixed(0),
                      data: state.expensesData,
                      onTimePeriodChanged: _handleExpensesTimePeriodChanged,
                    ),
                    GraphWidget(
                      title: 'Cash Flow',
                      amount: state.cashFlow.toStringAsFixed(0),
                      data: state.cashFlowData,
                      onTimePeriodChanged: _handleCashFlowTimePeriodChanged,
                    ),
                    SizedBox(height: 70),
                  ],
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
