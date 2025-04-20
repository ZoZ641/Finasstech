import 'package:finasstech/core/common/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils/money_formater.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_category.dart';
import '../bloc/budget_bloc.dart';
import '../widgets/budget_category_item.dart';
import 'budget_dashboard.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final TextEditingController _lastYearSalesController =
      TextEditingController();
  late User currentUser;
  bool isFirstTimeUser = true;
  Budget? existingBudget;
  Map<String, BudgetCategory> categories = {};

  @override
  void initState() {
    super.initState();

    // Check if the user has existing data
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
  }

  @override
  void dispose() {
    _lastYearSalesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetCreated ||
            state is BudgetCreatedNeedsCategorization) {
          // Handle both normal creation and the specialized state the same way
          final budget =
              state is BudgetCreated
                  ? state.budget
                  : (state as BudgetCreatedNeedsCategorization).budget;

          setState(() {
            existingBudget = budget;
            categories = Map.from(budget.categories);
            isFirstTimeUser = false; // Ensure we show categories view
          });

          showSnackBar(
            context,
            'Success',
            'Please customize your budget categories',
            ContentType.success,
          );
        } else if (state is BudgetUpdated) {
          final budget = state.budget;

          // Navigate to dashboard after categories are updated
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BudgetDashboard(budget: budget),
            ),
          );

          showSnackBar(
            context,
            'Success',
            'Budget has been updated successfully!',
            ContentType.success,
          );
        } else if (state is BudgetLoaded) {
          // This is for existing budgets when app is reopened
          setState(() {
            existingBudget = state.budget;
            categories = Map.from(state.budget.categories);
          });

          // Calculate usage for loaded budget
          context.read<BudgetBloc>().add(
            CalculateBudgetUsageEvent(budget: state.budget),
          );
        } /*else if (state is BudgetUsageCalculated) {
          // Only navigate to dashboard after usage is calculated
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => BudgetDashboard(
                    budget: state.budget,
                    usage: state.usageByCategory,
                  ),
            ),
          );
        }*/
      },
      builder: (context, state) {
        print("Current state: $state"); // Add this for debugging

        if (state is BudgetLoading) {
          return const Loader();
        }

        // Add specific handling for our state
        if (state is BudgetCreatedNeedsCategorization) {
          return _buildBudgetCategoriesView();
        }

        if (isFirstTimeUser && existingBudget == null) {
          return _buildFirstTimeUserView();
        } else if (existingBudget != null) {
          return _buildBudgetCategoriesView();
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildFirstTimeUserView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Budget Setup!'),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'To create your initial budget, please enter your average sales from last year.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _lastYearSalesController,
              keyboardType: TextInputType.number,
              inputFormatters: [MoneyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Last Year Average Sales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_pound),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final salesText =
                    _lastYearSalesController.text
                        .replaceAll(',', '')
                        .replaceAll('£', '')
                        .trim();
                if (salesText.isEmpty) {
                  showSnackBar(
                    context,
                    'error',
                    'Please enter your last year sales',
                    ContentType.failure,
                  );
                  return;
                }

                final sales = double.tryParse(salesText);
                if (sales == null || sales <= 0) {
                  showSnackBar(
                    context,
                    'error',
                    'Please enter a valid amount',
                    ContentType.failure,
                  );
                  return;
                }

                context.read<BudgetBloc>().add(
                  CreateInitialBudgetEvent(lastYearSales: sales),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Budget',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCategoriesView() {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forecasted Sales: \$${existingBudget!.forecastedSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveCategories,
                  child: const Text('Save Budget'),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final categoryKey = categories.keys.elementAt(index);
                  final category = categories[categoryKey]!;

                  return BudgetCategoryItem(
                    category: category,
                    forecastedSales: existingBudget!.forecastedSales,
                    onPercentageChanged: (newPercentage) {
                      setState(() {
                        if (newPercentage == 0) {
                          // If user sets to 0, we keep category but set values to 0
                          categories[categoryKey] = BudgetCategory(
                            name: category.name,
                            percentage: 0,
                            usage: 0,
                            amount: 0,
                            minRecommendedPercentage:
                                category.minRecommendedPercentage,
                            maxRecommendedPercentage:
                                category.maxRecommendedPercentage,
                          );
                        } else {
                          categories[categoryKey] = BudgetCategory(
                            name: category.name,
                            percentage: newPercentage,
                            amount:
                                existingBudget!.forecastedSales *
                                (newPercentage / 100),
                            usage: 0,
                            minRecommendedPercentage:
                                category.minRecommendedPercentage,
                            maxRecommendedPercentage:
                                category.maxRecommendedPercentage,
                          );
                        }
                      });
                    },
                    onAmountChanged: (newAmount) {
                      setState(() {
                        if (newAmount == 0) {
                          // If user sets to 0, we keep category but set values to 0
                          categories[categoryKey] = BudgetCategory(
                            name: category.name,
                            percentage: 0,
                            amount: 0,
                            usage: 0,
                            minRecommendedPercentage:
                                category.minRecommendedPercentage,
                            maxRecommendedPercentage:
                                category.maxRecommendedPercentage,
                          );
                        } else {
                          final newPercentage =
                              (newAmount / existingBudget!.forecastedSales) *
                              100;
                          categories[categoryKey] = BudgetCategory(
                            name: category.name,
                            percentage: newPercentage,
                            amount: newAmount,
                            usage: 0,
                            minRecommendedPercentage:
                                category.minRecommendedPercentage,
                            maxRecommendedPercentage:
                                category.maxRecommendedPercentage,
                          );
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategories() {
    if (existingBudget != null) {
      // First update the categories
      context.read<BudgetBloc>().add(
        UpdateBudgetCategoriesEvent(
          budgetId: existingBudget!.id,
          categories: categories,
        ),
      );
    }
  }
}
