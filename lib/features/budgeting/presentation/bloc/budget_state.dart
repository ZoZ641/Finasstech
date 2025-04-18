part of 'budget_bloc.dart';

@immutable
sealed class BudgetState {
  const BudgetState();
}

final class BudgetInitial extends BudgetState {}

final class BudgetLoading extends BudgetState {}

final class BudgetDataExistsState extends BudgetState {
  final bool hasExistingData;

  const BudgetDataExistsState(this.hasExistingData);
}

final class BudgetCreated extends BudgetState {
  final Budget budget;

  const BudgetCreated(this.budget);
}

final class BudgetLoaded extends BudgetState {
  final Budget budget;

  const BudgetLoaded(this.budget);
}

final class BudgetUpdated extends BudgetState {
  final Budget budget;

  const BudgetUpdated(this.budget);
}

final class BudgetUsageCalculated extends BudgetState {
  final Budget budget;
  final Map<String, double> usageByCategory;

  const BudgetUsageCalculated({
    required this.budget,
    required this.usageByCategory,
  });
}

final class BudgetError extends BudgetState {
  final String message;

  const BudgetError({required this.message});
}

final class BudgetCreatedNeedsCategorization extends BudgetState {
  final Budget budget;

  const BudgetCreatedNeedsCategorization(this.budget);
}
