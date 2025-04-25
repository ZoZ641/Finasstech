part of 'budget_bloc.dart';

@immutable
sealed class BudgetEvent {
  const BudgetEvent();
}

/// Checks if there is already saved budget data in Hive
final class CheckForExistingBudgetData extends BudgetEvent {
  const CheckForExistingBudgetData();
}

/// Creates an initial budget with last year's sales as base
final class CreateInitialBudgetEvent extends BudgetEvent {
  final double lastYearSales;

  const CreateInitialBudgetEvent({required this.lastYearSales});
}

/// Triggers creation of a new budget using Prophet forecasting
final class CreateBudgetWithProphetEvent extends BudgetEvent {
  const CreateBudgetWithProphetEvent();
}

/// Updates the categories of an existing budget
final class UpdateBudgetCategoriesEvent extends BudgetEvent {
  final String budgetId;
  final Map<String, BudgetCategory> categories;

  const UpdateBudgetCategoriesEvent({
    required this.budgetId,
    required this.categories,
  });
}

/// Loads the most recently updated budget from local storage
final class GetLatestBudgetEvent extends BudgetEvent {
  const GetLatestBudgetEvent();
}

/// Loads all budgets from local storage
final class GetAllBudgetsEvent extends BudgetEvent {
  const GetAllBudgetsEvent();
}

/// Recalculates category usage based on recorded expenses
final class CalculateBudgetUsageEvent extends BudgetEvent {
  final Budget budget;

  const CalculateBudgetUsageEvent({required this.budget});
}
