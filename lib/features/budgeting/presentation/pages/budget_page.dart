import 'package:finasstech/core/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import 'budget_dashboard.dart';
import 'create_budget_page.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
  }

  Map<String, double> _budgetUsage = {};
  Budget? _latestBudget;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: (context, state) {
        debugPrint('📣 BudgetBloc State: ${state.runtimeType}');

        if (state is BudgetDataExistsState) {
          debugPrint('🔍 Budget exists: ${state.hasExistingData}');
          if (state.hasExistingData == true) {
            context.read<BudgetBloc>().add(GetLatestBudgetEvent());
          }
        }

        if (state is BudgetCreatedNeedsCategorization) {
          // Don't automatically calculate usage here
          _latestBudget = state.budget;
        }

        if (state is BudgetLoaded ||
            state is BudgetCreated ||
            state is BudgetUpdated) {
          final budget = (state as dynamic).budget;
          _latestBudget = budget;
          context.read<BudgetBloc>().add(
            CalculateBudgetUsageEvent(budget: budget),
          );
        }

        if (state is BudgetUsageCalculated) {
          setState(() {
            _budgetUsage = state.usageByCategory;
          });
        }
      },
      builder: (context, state) {
        if (state is BudgetChecking || state is BudgetLoading) {
          return const Loader();
        }

        // Critical: Check for BudgetCreatedNeedsCategorization first
        if (state is BudgetCreatedNeedsCategorization) {
          return CreateBudgetPage();
        }

        if (_latestBudget != null) {
          return BudgetDashboard(budget: _latestBudget!, usage: _budgetUsage);
        }

        if (state is BudgetEmpty) {
          return const CreateBudgetPage();
        }

        return const Loader();
      },
    );
  }
}
