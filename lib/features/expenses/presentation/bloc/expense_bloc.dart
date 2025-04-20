import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/usecase/noparams.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/update_expense.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final GetAllExpenses getAllExpenses;

  ExpenseBloc({
    required this.addExpense,
    required this.updateExpense,
    required this.deleteExpense,
    required this.getAllExpenses,
  }) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await getAllExpenses(NoParams());
    result.fold(
      (failure) => emit(ExpenseFailure(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    print('Adding: ${event.expense}');
    final result = await addExpense(event.expense);
    result.fold(
      (failure) {
        print('Add Failed: ${failure.message}');
        emit(ExpenseFailure(failure.message));
      },
      (_) {
        print('Add Success');
        add(LoadExpenses());
      },
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await updateExpense(event.expense);
    result.fold(
      (failure) => emit(ExpenseFailure(failure.message)),
      (_) => add(LoadExpenses()),
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await deleteExpense(event.id);
    result.fold(
      (failure) => emit(ExpenseFailure(failure.message)),
      (_) => add(LoadExpenses()),
    );
  }
}
