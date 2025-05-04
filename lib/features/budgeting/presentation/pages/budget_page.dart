import 'package:finasstech/core/common/widgets/loader.dart';
import 'package:finasstech/core/services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    if (widget.budget == null) {
      context.read<BudgetBloc>().add(const GetLatestBudgetEvent());
    } else {
      _latestBudget = widget.budget;
      _isLoading = false;
      // Calculate usage for the budget passed via constructor
      context.read<BudgetBloc>().add(
        CalculateBudgetUsageEvent(budget: widget.budget!),
      );
    }
    // Check for current year budget instead of direct check
    context.read<BudgetBloc>().add(const CheckCurrentYearBudgetEvent());
  }

  void _checkYearEnd() {
    final now = DateTime.now();
    if (_latestBudget != null && _latestBudget!.createdAt.year < now.year) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notificationService.showNotification(
          title: "Create New Budget",
          body:
              "It seems your latest budget was created last year. Create a new budget for the current year.",
          isYearly: true,
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
          } else if (state is CurrentYearBudgetState) {
            if (!state.hasCurrentYearBudget) {
              _notificationService.showNotification(
                title: "Create New Budget",
                body:
                    "You haven't created a budget for the current year yet. Create a new budget to stay on track.",
                isYearly: true,
              );
            }
          } else if (state is BudgetLoaded) {
            setState(() {
              _latestBudget = state.budget;
              _isLoading = false;
            });
            // Trigger usage calculation whenever a budget is loaded
            context.read<BudgetBloc>().add(
              CalculateBudgetUsageEvent(budget: state.budget),
            );
          } else if (state is BudgetEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CreateBudgetPage()),
            );
          } else if (state is BudgetUsageCalculated) {
            setState(() {
              _budgetUsage = state.usageByCategory;
            });
          } else if (state is BudgetError) {
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

          return BudgetDashboard(
            budget: _latestBudget!,
            usage: _budgetUsage,
            isHistory: false,
          );
        },
      ),
    );
  }
}
