import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/noparams.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../repository/budget_repository.dart';

class GetAllBudgets implements UseCase<List<Budget>, NoParams> {
  final BudgetRepository budgetRepository;

  const GetAllBudgets(this.budgetRepository);

  @override
  Future<Either<Failure, List<Budget>>> call(NoParams params) async {
    return await budgetRepository.getAllBudgets();
  }
}
