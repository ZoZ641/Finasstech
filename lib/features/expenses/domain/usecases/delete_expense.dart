import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/expense_repository.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository expenseRepository;

  DeleteExpense(this.expenseRepository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return expenseRepository.deleteExpense(id: id);
  }
}
