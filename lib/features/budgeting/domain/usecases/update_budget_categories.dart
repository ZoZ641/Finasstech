import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget.dart';
import '../entities/budget_category.dart';
import '../repository/budget_repository.dart';

class UpdateBudgetCategories
    implements UseCase<Budget, UpdateBudgetCategoriesParams> {
  final BudgetRepository budgetRepository;

  const UpdateBudgetCategories(this.budgetRepository);

  @override
  Future<Either<Failure, Budget>> call(
    UpdateBudgetCategoriesParams params,
  ) async {
    return await budgetRepository.updateBudgetCategories(
      budgetId: params.budgetId,
      categories: params.categories,
    );
  }
}

class UpdateBudgetCategoriesParams {
  final String budgetId;
  final Map<String, BudgetCategory> categories;

  UpdateBudgetCategoriesParams({
    required this.budgetId,
    required this.categories,
  });
}
