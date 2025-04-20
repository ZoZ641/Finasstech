import 'dart:ffi';

import 'package:finasstech/core/error/exceptions.dart';
import 'package:hive_ce/hive.dart';

import '../models/budget_category_model.dart';
import '../models/budget_model.dart';

abstract interface class BudgetLocalDataSource {
  Future<bool> hasExistingBudgetData();
  Future<BudgetModel> createInitialBudget({required double lastYearSales});
  Future<BudgetModel> createBudgetWithProphetForecast();
  Future<BudgetModel> updateBudgetCategories({
    required String budgetId,
    required Map<String, BudgetCategoryModel> categories,
  });
  Future<BudgetModel?> getLatestBudget();
  Future<void> calculateBudgetUsageFromExpenses();
  Future<List<Map<String, dynamic>>> getTransactionsHistoryForProphet();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Box<BudgetModel> budgetBox;
  final Box transactionsBox;

  const BudgetLocalDataSourceImpl({
    required this.budgetBox,
    required this.transactionsBox,
  });

  @override
  Future<bool> hasExistingBudgetData() async {
    try {
      return budgetBox.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<BudgetModel> createInitialBudget({
    required double lastYearSales,
  }) async {
    try {
      final forecastedSales = lastYearSales * 1.2;
      final categories = _createDefaultBudgetCategories(forecastedSales);
      final budget = BudgetModel(
        //Todo change id to uuid
        // id: Uuid().v4(),
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
        forecastedSales: forecastedSales,
        categories: categories,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await budgetBox.put(budget.id, budget);
      return budget;
    } catch (e) {
      throw ServerException('Failed to create initial budget: ${e.toString()}');
    }
  }

  @override
  Future<BudgetModel> createBudgetWithProphetForecast() async {
    try {
      final transactionHistory = await getTransactionsHistoryForProphet();
      final forecastedSales = 100000.0; // Replace later with Prophet forecast

      final categories = _createDefaultBudgetCategories(forecastedSales);
      final budget = BudgetModel(
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
        forecastedSales: forecastedSales,
        categories: categories,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await budgetBox.put(budget.id, budget);
      return budget;
    } catch (e) {
      throw ServerException(
        'Failed to create budget with Prophet: ${e.toString()}',
      );
    }
  }

  @override
  Future<BudgetModel> updateBudgetCategories({
    required String budgetId,
    required Map<String, BudgetCategoryModel> categories,
  }) async {
    try {
      final budget = budgetBox.get(budgetId);
      if (budget == null) throw ServerException('Budget not found');

      final updatedBudget = BudgetModel(
        id: budget.id,
        forecastedSales: budget.forecastedSales,
        categories: categories,
        createdAt: budget.createdAt,
        updatedAt: DateTime.now(),
      );

      await budgetBox.put(budgetId, updatedBudget);
      return updatedBudget;
    } catch (e) {
      throw ServerException(
        'Failed to update budget categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<BudgetModel?> getLatestBudget() async {
    try {
      if (budgetBox.isEmpty) return null;
      final budgets = budgetBox.values.toList();
      final latestBudget = budgets.reduce(
        (curr, next) => curr.updatedAt.isAfter(next.updatedAt) ? curr : next,
      );
      return BudgetModel(
        id: latestBudget.id,
        forecastedSales: latestBudget.forecastedSales,
        categories: latestBudget.categories,
        createdAt: latestBudget.createdAt,
        updatedAt: latestBudget.updatedAt,
      );
    } catch (e) {
      throw ServerException('Failed to get budget: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactionsHistoryForProphet() async {
    try {
      return transactionsBox.values
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      throw ServerException(
        'Failed to get transaction history: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> calculateBudgetUsageFromExpenses() async {
    if (budgetBox.isEmpty) return;
    final budget = budgetBox.getAt(0)!;

    final Map<String, double> usageMap = {};

    for (final expense in transactionsBox.values) {
      if (!usageMap.containsKey(expense.category)) {
        usageMap[expense.category] = 0;
      }
      usageMap[expense.category] = usageMap[expense.category]! + expense.amount;
    }

    final updatedCategories = {
      for (final entry in budget.categories.entries)
        entry.key: BudgetCategoryModel(
          name: entry.value.name,
          percentage: entry.value.percentage,
          amount: entry.value.amount,
          usage: usageMap[entry.key] ?? 0.0,
          minRecommendedPercentage: entry.value.minRecommendedPercentage,
          maxRecommendedPercentage: entry.value.maxRecommendedPercentage,
        ),
    };

    final updatedBudget = budget.copyWith(
      categories: updatedCategories,
      updatedAt: DateTime.now(),
    );

    await budgetBox.putAt(0, updatedBudget);
  }
}

// Helper method to create default budget categories
Map<String, BudgetCategoryModel> _createDefaultBudgetCategories(
  double forecastedSales,
) {
  return {
    'salaries': BudgetCategoryModel(
      name: 'Salaries',
      percentage: 30.0, // Default percentage
      usage: 0,
      amount: forecastedSales * 0.3, // 30% of forecasted sales
      minRecommendedPercentage: 20.0,
      maxRecommendedPercentage: 50.0,
    ),
    'stock': BudgetCategoryModel(
      name: 'Stock',
      percentage: 40.0,
      usage: 0,
      amount: forecastedSales * 0.4,
      minRecommendedPercentage: 30.0,
      maxRecommendedPercentage: 70.0,
    ),
    'advertisement': BudgetCategoryModel(
      name: 'Advertisement',
      percentage: 5.0,
      usage: 0,
      amount: forecastedSales * 0.05,
      minRecommendedPercentage: 2.0,
      maxRecommendedPercentage: 10.0,
    ),
    'rent': BudgetCategoryModel(
      name: 'Rent',
      percentage: 8.0,
      usage: 0,
      amount: forecastedSales * 0.08,
      minRecommendedPercentage: 2.0,
      maxRecommendedPercentage: 15.0,
    ),
    'insurance': BudgetCategoryModel(
      name: 'Insurance',
      percentage: 3.0,
      usage: 0,
      amount: forecastedSales * 0.03,
      minRecommendedPercentage: 1.0,
      maxRecommendedPercentage: 5.0,
    ),
    'electricity': BudgetCategoryModel(
      name: 'Electricity',
      percentage: 2.0,
      usage: 0,
      amount: forecastedSales * 0.02,
      minRecommendedPercentage: 1.0,
      maxRecommendedPercentage: 5.0,
    ),
    'water': BudgetCategoryModel(
      name: 'Water',
      percentage: 1.0,
      usage: 0,
      amount: forecastedSales * 0.01,
      minRecommendedPercentage: 0.5,
      maxRecommendedPercentage: 2.0,
    ),
    'equipment': BudgetCategoryModel(
      name: 'Equipment',
      percentage: 7.0,
      usage: 0,
      amount: forecastedSales * 0.07,
      minRecommendedPercentage: 2.0,
      maxRecommendedPercentage: 15.0,
    ),
    'maintenance': BudgetCategoryModel(
      name: 'Maintenance',
      percentage: 4.0,
      usage: 0,
      amount: forecastedSales * 0.04,
      minRecommendedPercentage: 1.0,
      maxRecommendedPercentage: 10.0,
    ),
  };
}
