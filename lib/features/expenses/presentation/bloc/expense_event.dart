part of 'expense_bloc.dart';

@immutable
sealed class ExpenseEvent {}

final class LoadExpenses extends ExpenseEvent {}

final class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;

  AddExpenseEvent(this.expense);
}

final class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;

  UpdateExpenseEvent(this.expense);
}

final class DeleteExpenseEvent extends ExpenseEvent {
  final String id;

  DeleteExpenseEvent(this.id);
}
