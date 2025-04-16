import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../repository/budget_repository.dart';

class CreateInitialBudget implements UseCase<Budget, double> {
  final BudgetRepository budgetRepository;

  const CreateInitialBudget(this.budgetRepository);

  @override
  Future<Either<Failure, Budget>> call(double lastYearSales) async {
    return await budgetRepository.createInitialBudget(
      lastYearSales: lastYearSales,
    );
  }
}
