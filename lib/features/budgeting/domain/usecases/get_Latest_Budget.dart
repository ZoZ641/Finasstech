import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/noparams.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../repository/budget_repository.dart';

class GetLatestBudget implements UseCase<Budget?, NoParams> {
  final BudgetRepository budgetRepository;

  const GetLatestBudget(this.budgetRepository);

  @override
  Future<Either<Failure, Budget?>> call(NoParams params) async {
    return await budgetRepository.getLatestBudget();
  }
}
