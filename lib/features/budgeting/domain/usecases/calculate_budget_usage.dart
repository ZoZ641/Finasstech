import 'package:finasstech/features/budgeting/domain/entities/budget.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/budget_repository.dart';

class CalculateBudgetUsage implements UseCase<void, Budget> {
  final BudgetRepository budgetRepository;

  const CalculateBudgetUsage(this.budgetRepository);

  @override
  Future<Either<Failure, void>> call(Budget budget) async {
    return await budgetRepository.calculateBudgetUsage(budget: budget);
  }
}
