import 'package:finasstech/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/expense.dart';
import '../../domain/repository/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  const ExpenseRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, void>> addExpense({required Expense expense}) async {
    try {
      await localDataSource.addExpense(expense: expense);
      return right(null);
    } catch (e) {
      return left(Failure('Failed to add expense: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense({required String id}) async {
    try {
      await localDataSource.deleteExpense(id: id);
      return right(null);
    } catch (e) {
      return left(Failure('Failed to delete expense: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final expenses = await localDataSource.getAllExpenses();
      return right(expenses);
    } catch (e) {
      return left(Failure('Failed to fetch expenses: $e'));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getExpenseById({required String id}) async {
    try {
      final result = await localDataSource.getExpenseById(id: id);
      return right(result);
    } catch (e) {
      return left(Failure('Failed to fetch expense: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense({
    required Expense expense,
  }) async {
    try {
      await localDataSource.updateExpense(expense: expense);
      return right(null);
    } catch (e) {
      return left(Failure('Failed to update expense: $e'));
    }
  }
}
