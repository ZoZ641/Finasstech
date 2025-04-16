import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/budget_repository.dart';

class CheckExistingBudgetData implements UseCase<bool, NoParams> {
  final BudgetRepository budgetRepository;

  const CheckExistingBudgetData(this.budgetRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await budgetRepository.hasExistingBudgetData();
  }
}

class NoParams {}
