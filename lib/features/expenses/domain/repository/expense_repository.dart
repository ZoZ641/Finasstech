import 'package:finasstech/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../entities/expense.dart';

abstract class ExpenseRepository {
  /// Get an expense by its ID from the database
  Future<Either<Failure, Expense?>> getExpenseById({required String id});

  //? May be used in the future or not needed at all
  /// Add a new expense to the database
  Future<Either<Failure, void>> addExpense({required Expense expense});

  /// Update an existing expense in the database
  Future<Either<Failure, void>> updateExpense({required Expense expense});

  /// Delete an expense from the database
  Future<Either<Failure, void>> deleteExpense({required String id});

  /// Get all expenses from the database
  Future<Either<Failure, List<Expense>>> getAllExpenses();
}
