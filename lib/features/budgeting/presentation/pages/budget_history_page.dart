import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import 'budget_dashboard.dart';

class BudgetHistoryPage extends StatefulWidget {
  const BudgetHistoryPage({super.key});

  @override
  State<BudgetHistoryPage> createState() => _BudgetHistoryPageState();
}

class _BudgetHistoryPageState extends State<BudgetHistoryPage> {
  Map<String, double> _budgetUsage = {};

  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(const GetAllBudgetsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget History')),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is BudgetUsageCalculated) {
            setState(() {
              _budgetUsage = state.usageByCategory;
            });
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: Loader());
          }

          if (state is AllBudgetsLoaded) {
            if (state.budgets.isEmpty) {
              return const Center(child: Text('No budget history available'));
            }

            return ListView.builder(
              itemCount: state.budgets.length,
              itemBuilder: (context, index) {
                final budget = state.budgets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      'Budget for ${budget.createdAt.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Created: ${_formatDate(budget.createdAt)}\n'
                      'Forecasted Sales: £${budget.forecastedSales.toStringAsFixed(2)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.read<BudgetBloc>().add(
                        CalculateBudgetUsageEvent(budget: budget),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text(
                                    'the budget of ${budget.createdAt.year}',
                                  ),
                                ),
                                body: BudgetDashboard(
                                  budget: budget,
                                  usage: _budgetUsage,
                                ),
                              ),
                        ),
                      ).then((_) {
                        context.read<BudgetBloc>().add(
                          const GetAllBudgetsEvent(),
                        );
                      });
                    },
                  ),
                );
              },
            );
          }

          return const Center(child: Text('No budget history available'));
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
