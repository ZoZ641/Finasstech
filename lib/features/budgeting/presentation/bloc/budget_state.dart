part of 'budget_bloc.dart';

@immutable
sealed class BudgetState {
  const BudgetState();
}

/// Initial state before any action is taken
final class BudgetInitial extends BudgetState {}

final class BudgetChecking extends BudgetState {}

final class BudgetEmpty extends BudgetState {}

/// Generic loading state for asynchronous operations
final class BudgetLoading extends BudgetState {}

/// Indicates if budget data already exists
final class BudgetDataExistsState extends BudgetState {
  final bool hasExistingData;

  const BudgetDataExistsState(this.hasExistingData);
}

/// State after a budget has been created and needs category input
final class BudgetCreatedNeedsCategorization extends BudgetState {
  final Budget budget;

  const BudgetCreatedNeedsCategorization(this.budget);
}

/// State after a budget has been created (e.g., via Prophet)
final class BudgetCreated extends BudgetState {
  final Budget budget;

  const BudgetCreated(this.budget);
}

/// State after an existing budget has been fully loaded
final class BudgetLoaded extends BudgetState {
  final Budget budget;

  const BudgetLoaded(this.budget);
}

/// State after the budget categories have been updated
final class BudgetUpdated extends BudgetState {
  final Budget budget;

  const BudgetUpdated(this.budget);
}

/// State after recalculating usage across all categories
final class BudgetUsageCalculated extends BudgetState {
  final Budget budget;
  final Map<String, double> usageByCategory;

  const BudgetUsageCalculated({
    required this.budget,
    required this.usageByCategory,
  });
}

/// State for when an error occurs in any operation
final class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});
}
