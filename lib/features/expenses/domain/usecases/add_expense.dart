import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class AddExpense implements UseCase<void, Expense> {
  final ExpenseRepository expenseRepository;

  AddExpense(this.expenseRepository);

  @override
  Future<Either<Failure, void>> call(Expense expense) async {
    return await expenseRepository.addExpense(expense: expense);
  }
}
