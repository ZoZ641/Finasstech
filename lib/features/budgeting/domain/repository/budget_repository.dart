import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget.dart';
import '../entities/budget_category.dart';

abstract interface class BudgetRepository {
  /// Check if any previous budget-related data exists (e.g., transactions).
  Future<Either<Failure, bool>> hasExistingBudgetData();

  /// Create an initial budget using last year's sales with fixed category allocations.
  Future<Either<Failure, Budget>> createInitialBudget({
    required double lastYearSales,
  });

  /// Create a budget using Prophet forecast (or placeholder).
  Future<Either<Failure, Budget>> createBudgetWithProphetForecast();

  /// Update the existing budget categories.
  Future<Either<Failure, Budget>> updateBudgetCategories({
    required String budgetId,
    required Map<String, BudgetCategory> categories,
  });

  /// Fetch the latest (most recently updated) budget.
  Future<Either<Failure, Budget?>> getLatestBudget();

  /// Calculate how much of the budget is used in each category.
  Future<Either<Failure, Map<String, double>>> calculateBudgetUsage({
    required Budget budget,
  });
}
