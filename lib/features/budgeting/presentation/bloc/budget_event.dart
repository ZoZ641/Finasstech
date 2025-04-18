part of 'budget_bloc.dart';

@immutable
sealed class BudgetEvent {}

final class CheckForExistingBudgetData extends BudgetEvent {
  CheckForExistingBudgetData();
}

final class CreateInitialBudgetEvent extends BudgetEvent {
  final double lastYearSales;

  CreateInitialBudgetEvent({required this.lastYearSales});
}

class CreateBudgetWithProphetEvent extends BudgetEvent {
  CreateBudgetWithProphetEvent();
}

class UpdateBudgetCategoriesEvent extends BudgetEvent {
  final String budgetId;
  final Map<String, BudgetCategory> categories;

  UpdateBudgetCategoriesEvent({
    required this.budgetId,
    required this.categories,
  });
}

class GetLatestBudgetEvent extends BudgetEvent {
  GetLatestBudgetEvent();
}

class CalculateBudgetUsageEvent extends BudgetEvent {
  final Budget budget;

  CalculateBudgetUsageEvent({required this.budget});
}
