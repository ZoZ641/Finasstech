import 'package:finasstech/core/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import 'budget_dashboard.dart';
import 'budget_history_page.dart';
import 'create_budget_page.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../../core/utils/show_snackbar.dart';

class BudgetPage extends StatefulWidget {
  final Budget? budget;
  final bool isHistory;

  const BudgetPage({super.key, this.budget, this.isHistory = true});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  Map<String, double> _budgetUsage = {};
  Budget? _latestBudget;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.budget == null) {
      context.read<BudgetBloc>().add(const GetLatestBudgetEvent());
    } else {
      _latestBudget = widget.budget;
      _isLoading = false;
    }
    _checkYearEnd();
  }

  void _checkYearEnd() {
    final now = DateTime.now();
    if (now.month == 12 && now.day >= 30) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Year End Budget Creation'),
                content: const Text(
                  'The current year is ending. Would you like to create a new budget for the upcoming year?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Later'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateBudgetPage(),
                        ),
                      );
                    },
                    child: const Text('Create Now'),
                  ),
                ],
              ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          Visibility(
            visible: widget.isHistory,
            child: IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BudgetHistoryPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetDataExistsState) {
            if (state.hasExistingData == true) {
              context.read<BudgetBloc>().add(const GetLatestBudgetEvent());
            }
          }

          if (state is BudgetCreatedNeedsCategorization) {
            setState(() {
              _isLoading = false;
              _latestBudget = state.budget;
            });
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CreateBudgetPage()),
            );
          }

          if (state is BudgetLoaded ||
              state is BudgetCreated ||
              state is BudgetUpdated) {
            final budget = (state as dynamic).budget;
            setState(() {
              _latestBudget = budget;
              _isLoading = false;
            });
            context.read<BudgetBloc>().add(
              CalculateBudgetUsageEvent(budget: budget),
            );
          }

          if (state is BudgetUsageCalculated) {
            setState(() {
              _budgetUsage = state.usageByCategory;
            });
          }

          if (state is BudgetError) {
            setState(() {
              _isLoading = false;
            });
            showSnackBar(context, 'Error', state.message, ContentType.failure);
          }
        },
        builder: (context, state) {
          if (_isLoading || state is BudgetChecking || state is BudgetLoading) {
            return const Loader();
          }

          if (_latestBudget == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No budget available',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
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
          }

          return BudgetDashboard(budget: _latestBudget!, usage: _budgetUsage);
        },
      ),
    );
  }
}
