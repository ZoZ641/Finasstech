import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class UpdateExpense implements UseCase<void, Expense> {
  final ExpenseRepository expenseRepository;

  UpdateExpense(this.expenseRepository);

  @override
  Future<Either<Failure, void>> call(Expense expense) {
    return expenseRepository.updateExpense(expense: expense);
  }
}
