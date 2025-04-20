import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class GetExpenseById implements UseCase<Expense?, String> {
  final ExpenseRepository expenseRepository;

  GetExpenseById(this.expenseRepository);

  @override
  Future<Either<Failure, Expense?>> call(String id) async {
    return await expenseRepository.getExpenseById(id: id);
  }
}
