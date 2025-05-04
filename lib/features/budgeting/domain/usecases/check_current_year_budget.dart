import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/noparams.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/budget_repository.dart';

class CheckCurrentYearBudget implements UseCase<bool, NoParams> {
  final BudgetRepository budgetRepository;

  const CheckCurrentYearBudget(this.budgetRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    try {
      final budgetResult = await budgetRepository.getLatestBudget();

      return budgetResult.fold((failure) => Right(false), (budgetModel) {
        if (budgetModel == null) return Right(false);
        final currentYear = DateTime.now().year;
        return Right(budgetModel.createdAt.year == currentYear);
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
