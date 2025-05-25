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
      // Calculate forecasted sales with a 20% growth projection from last year
      final forecastedSales = lastYearSales * 1.2;

      // Generate default budget categories based on the forecasted sales amount
      final categories = _createDefaultBudgetCategories(forecastedSales);

      // Create a new budget model with a unique timestamp-based ID
      final budget = BudgetModel(
        id: 'budget_${DateTime.now().millisecondsSinceEpoch}', // Generate unique ID using current timestamp
        forecastedSales: forecastedSales,
        categories: categories,
        createdAt: DateTime.now(), // Set creation timestamp
        updatedAt:
            DateTime.now(), // Set initial update timestamp (same as creation time)
      );

      // Persist the budget to storage using the budget box (likely Hive or similar)
      await budgetBox.put(budget.id, budget);

      // Return the newly created budget object
      return budget;
    } catch (e) {
      // If any error occurs during budget creation, throw a server exception with details
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
      // Retrieve the existing budget from storage using its ID
      final budget = budgetBox.get(budgetId);

      // Throw an exception if the budget doesn't exist
      if (budget == null) throw ServerException('Budget not found');

      // Create a new budget model with updated categories
      // Note: This creates a new instance rather than modifying the existing one,
      // which follows immutability best practices
      final updatedBudget = BudgetModel(
        id: budget.id, // Keep the same ID
        forecastedSales: budget.forecastedSales, // Preserve forecasted sales
        categories: categories, // Apply the new categories
        createdAt: budget.createdAt, // Keep original creation timestamp
        updatedAt: DateTime.now(), // Update the modification timestamp
      );

      // Save the updated budget back to storage
      await budgetBox.put(budgetId, updatedBudget);

      // Return the updated budget object to the caller
      return updatedBudget;
    } catch (e) {
      // If any error occurs during the update, wrap it in a ServerException
      // with context about what operation failed
      throw ServerException(
        'Failed to update budget categories: ${e.toString()}',
      );
    }
  }

  @override
  /// Retrieves the latest budget from the local storage.
  ///
  /// If there are no budgets stored, it returns null. Otherwise, it finds
  /// the budget with the most recent `createdAt` timestamp and returns it
  /// as a [BudgetModel].
  ///
  /// Throws a [ServerException] if there is an error during retrieval.
  Future<BudgetModel?> getLatestBudget() async {
    try {
      // If there are no budgets stored, return null
      if (budgetBox.isEmpty) return null;

      // Retrieve all budgets from the local storage
      final budgets = budgetBox.values.toList();

      // Find the budget with the most recent `createdAt` timestamp
      final latestBudget = budgets.reduce(
        (curr, next) => curr.createdAt.isAfter(next.createdAt) ? curr : next,
      );

      // Return the latest budget as a new [BudgetModel] object
      return BudgetModel(
        id: latestBudget.id,
        forecastedSales: latestBudget.forecastedSales,
        categories: latestBudget.categories,
        createdAt: latestBudget.createdAt,
        updatedAt: latestBudget.updatedAt,
      );
    } catch (e) {
      // Throw a [ServerException] if there is an error during retrieval
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
      final filteredSales = transactionsBox.values.where(
        (e) =>
            e.category.toLowerCase() == 'sales' &&
            e.date.isBefore(thisYearStart),
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
    // Early return if no budgets exist in the storage
    if (budgetBox.isEmpty) return;

    // Retrieve the most recent budget instead of using the first one
    final latestBudget = await getLatestBudget();
    if (latestBudget == null) return;

    // Initialize a map to track expense totals by category
    final Map<String, double> usageMap = {};

    // Define the current year's date range
    final now = DateTime.now();
    final thisYearStart = DateTime(now.year); // January 1st of current year
    final thisYearEnd = DateTime(now.year + 1); // January 1st of next year

    // Loop through all transactions that fall within the current year
    for (final expense in transactionsBox.values.where(
      (e) => e.date.isAfter(thisYearStart) && e.date.isBefore(thisYearEnd),
    )) {
      // Initialize category in the usage map if it doesn't exist yet
      if (!usageMap.containsKey(expense.category.toLowerCase())) {
        usageMap[expense.category.toLowerCase()] = 0;
      }

      // Add this expense amount to the running total for its category
      // The '!' tells Dart that we're certain the key exists (we just ensured it above)
      usageMap[expense.category.toLowerCase()] =
          usageMap[expense.category.toLowerCase()]! + expense.amount;
    }

    // Create updated category models with the calculated usage values
    final updatedCategories = {
      for (final entry in latestBudget.categories.entries)
        entry.key: BudgetCategoryModel(
          name: entry.value.name,
          percentage: entry.value.percentage,
          amount: entry.value.amount,
          // Apply the calculated usage from the usageMap, or 0.0 if none found
          usage: usageMap[entry.key.toLowerCase()] ?? 0.0,
          // Preserve the recommended percentage ranges from the original category
          minRecommendedPercentage: entry.value.minRecommendedPercentage,
          maxRecommendedPercentage: entry.value.maxRecommendedPercentage,
        ),
    };

    // Create a copy of the original budget with updated categories and timestamp
    final updatedBudget = latestBudget.copyWith(
      categories: updatedCategories,
      updatedAt: DateTime.now(), // Update the last modified timestamp
    );

    // Save the updated budget back to storage using the same ID
    await budgetBox.put(latestBudget.id, updatedBudget);
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
