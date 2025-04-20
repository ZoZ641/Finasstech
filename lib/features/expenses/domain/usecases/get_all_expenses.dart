import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/noparams.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class GetAllExpenses implements UseCase<List<Expense>, NoParams> {
  final ExpenseRepository expenseRepository;

  GetAllExpenses(this.expenseRepository);

  @override
  Future<Either<Failure, List<Expense>>> call(NoParams noParams) {
    return expenseRepository.getAllExpenses();
  }
}
