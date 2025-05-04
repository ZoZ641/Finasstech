import 'package:finasstech/core/services/notification_service.dart';
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

  void _handleIncomeTimePeriodChanged(TimePeriod period) {
    context.read<DashboardBloc>().add(
      ChangeDashboardWidgetTimePeriod(
        widgetType: DashboardWidgetType.income,
        timePeriod: period,
      ),
    );
  }

  void _handleExpensesTimePeriodChanged(TimePeriod period) {
    context.read<DashboardBloc>().add(
      ChangeDashboardWidgetTimePeriod(
        widgetType: DashboardWidgetType.expenses,
        timePeriod: period,
      ),
    );
  }

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddExpensePage()),
              ).then((_) {
                if (mounted) {
                  context.read<DashboardBloc>().add(
                    CalculateDashboardMetrics(),
                  );
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
                    // ElevatedButton(
                    //   onPressed: () {
                    //     NotificationService().showScheduleNotification(
                    //       id: 3,
                    //       title: "Test",
                    //       body: "test schedule notification",
                    //       dateTime: DateTime(2025, DateTime.may, 2, 3, 12),
                    //     );
                    //     /*showDialog(
                    //       context: context,
                    //       builder:
                    //           (context) => AlertDialog(
                    //             title: Text("test"),
                    //             content: Text('test content'),
                    //             actions: [
                    //               TextButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: const Text('Later'),
                    //               ),
                    //               TextButton(
                    //                 onPressed: () => Navigator.pop(context),
                    //                 child: const Text('Not later'),
                    //               ),
                    //             ],
                    //           ),
                    //     );*/
                    //   },
                    //   child: Text('Show Dialogue'),
                    // ),
                    GraphWidget(
                      title: 'Income',
                      amount: state.income.toStringAsFixed(0),
                      isGraph: false,
                      //initialTimePeriod: state.incomePeriod,
                      onTimePeriodChanged: _handleIncomeTimePeriodChanged,
                    ),
                    GraphWidget(
                      title: 'Expenses',
                      amount: (state.expenses == 0
                              ? state.expenses
                              : state.expenses * -1)
                          .toStringAsFixed(0),
                      data: state.expensesData,
                      //initialTimePeriod: state.expensesPeriod,
                      onTimePeriodChanged: _handleExpensesTimePeriodChanged,
                    ),
                    GraphWidget(
                      title: 'Cash Flow',
                      amount: state.cashFlow.toStringAsFixed(0),
                      data: state.cashFlowData,
                      //initialTimePeriod: state.cashFlowPeriod,
                      onTimePeriodChanged: _handleCashFlowTimePeriodChanged,
                    ),
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
