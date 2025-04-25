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
  Future<List<BudgetModel>> getAllBudgets();
  Future<void> calculateBudgetUsageFromExpenses();
  Future<Map<String, dynamic>> getTransactionsHistoryForProphet(String period);
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final Box<BudgetModel> budgetBox;
  final Box transactionsBox;

  const BudgetLocalDataSourceImpl({
    required this.budgetBox,
    required this.transactionsBox,
  });

  @override
  /// Checks if there is existing budget data in the local storage.
  ///
  /// Returns true if there is existing budget data, false otherwise.
  ///
  /// If there is an error when checking if there is existing budget data,
  /// it returns false.
  Future<bool> hasExistingBudgetData() async {
    try {
      return budgetBox.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  /// Creates an initial budget with a given last year's sales.
  ///
  /// The initial budget will have a forecasted sales of 1.2 times the last year's sales.
  /// The budget will have the following categories:
  ///
  /// - Salaries
  /// - Stock
  /// - Advetisement
  /// - Rent
  /// - Insurance
  /// - Electricity
  /// - Water
  /// - Equipment
  /// - Maintenance
  ///
  /// The categories will have a default allocation of 30%, 40%, 5%, 8%, 3%, 2%, 1%, 7%, and 4% respectively.
  ///
  /// If there is an error when creating the initial budget, it throws a [ServerException].
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
  /// Creates a new budget using a Prophet forecast for sales.
  ///
  /// It retrieves the transaction history for the past year and uses it to
  /// generate a sales forecast. The forecasted sales value is then used to
  /// create default budget categories and their allocations.
  ///
  /// The budget is saved to the local storage and returned.
  ///
  /// If there is an error during the process, a [ServerException] is thrown.
  Future<BudgetModel> createBudgetWithProphetForecast() async {
    try {
      //TODO: call prophet to get forecast
      final transactionHistory = await getTransactionsHistoryForProphet("365");
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
  /// Updates the categories of an existing budget with the given [budgetId].
  ///
  /// Replaces the current categories with the provided [categories] map.
  ///
  /// Throws a [ServerException] if the budget is not found or if there is
  /// an error during the update process.
  ///
  /// Returns the updated [BudgetModel] upon successful update.
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
  /// Retrieves the latest budget from the local storage.
  ///
  /// If there are no budgets stored, it returns null. Otherwise, it finds
  /// the budget with the most recent `updatedAt` timestamp and returns it
  /// as a [BudgetModel].
  ///
  /// Throws a [ServerException] if there is an error during retrieval.
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
  /// Retrieves the transaction history for the given [period] to be used in the
  /// Prophet forecast.
  //
  /// The [period] should be a string representing the forecast period in days.
  //
  /// It returns a map containing the sales for the given period and the
  /// forecast period.
  //
  /// The sales are filtered by category 'sales' and date range of the current year.
  //
  /// If there is an error during retrieval, it throws a [ServerException].
  Future<Map<String, dynamic>> getTransactionsHistoryForProphet(
    String period,
  ) async {
    try {
      final now = DateTime.now();
      final thisYearStart = DateTime(now.year);
      final thisYearEnd = DateTime(now.year + 1);
      final filteredSales = transactionsBox.values.where(
        (e) =>
            e.category.toLowerCase() == 'sales' &&
            e.date.isAfter(thisYearStart) &&
            e.date.isBefore(thisYearEnd),
      );

      final salesList =
          filteredSales
              .map(
                (e) => {"amount": e.amount, "date": e.date.toIso8601String()},
              )
              .toList();

      return {"sales": salesList, "forecast_period": period};
    } catch (e) {
      throw ServerException(
        'Failed to get transaction history: ${e.toString()}',
      );
    }
  }

  @override
  /// Calculates the budget usage from the given expenses.
  //
  /// It will update the budget in the database with the calculated usage.
  //
  /// The usage is calculated by summing the amounts of each expense by category.
  //
  /// If there is no budget in the database, it will not do anything.
  //
  /// If there is an error during the calculation, it throws a [ServerException].
  Future<void> calculateBudgetUsageFromExpenses() async {
    if (budgetBox.isEmpty) return;
    //TODO: call get latest budget
    final budget = budgetBox.getAt(0)!;

    final Map<String, double> usageMap = {};

    final now = DateTime.now();
    final thisYearStart = DateTime(now.year);
    final thisYearEnd = DateTime(now.year + 1);
    for (final expense in transactionsBox.values.where(
      (e) => e.date.isAfter(thisYearStart) && e.date.isBefore(thisYearEnd),
    )) {
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

  @override
  Future<List<BudgetModel>> getAllBudgets() async {
    try {
      if (budgetBox.isEmpty) return [];
      final budgets = budgetBox.values.toList();
      budgets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return budgets;
    } catch (e) {
      throw ServerException('Failed to get budgets: ${e.toString()}');
    }
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
