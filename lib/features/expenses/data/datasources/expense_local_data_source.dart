import 'package:finasstech/features/expenses/data/models/expense_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseLocalDataSource {
  Future<void> addExpense({required Expense expense});
  Future<void> updateExpense({required Expense expense});
  Future<void> deleteExpense({required String id});
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById({required String id});
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final Box<ExpenseModel> expenseBox;

  ExpenseLocalDataSourceImpl({required this.expenseBox});

  @override
  Future<ExpenseModel> addExpense({required Expense expense}) async {
    try {
      final expenseModel = ExpenseModel(
        id: Uuid().v4(),
        amount: expense.amount,
        date: expense.date,
        vendor: expense.vendor,
        recurrence: expense.recurrence,
        category: expense.category,
      );

      await expenseBox.put(expenseModel.id, expenseModel);
      return expenseModel;
    } catch (e) {
      throw ServerException('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense({required Expense expense}) async {
    try {
      final expenseModel = ExpenseModel.fromEntity(expense);
      await expenseBox.put(expense.id, expenseModel);
    } catch (e) {
      throw ServerException('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense({required String id}) async {
    try {
      await expenseBox.delete(id);
    } catch (e) {
      throw ServerException('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      return expenseBox.values.toList();
    } catch (e) {
      throw ServerException('Failed to get all expenses: ${e.toString()}');
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById({required String id}) async {
    try {
      return expenseBox.get(id);
    } catch (e) {
      throw ServerException('Failed to get expense by id: ${e.toString()}');
    }
  }
}
