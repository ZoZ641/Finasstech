import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/usecase/noparams.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_all_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import '../../../../core/services/notification_service.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpense addExpense;
  final UpdateExpense updateExpense;
  final DeleteExpense deleteExpense;
  final GetAllExpenses getAllExpenses;
  final NotificationService _notificationService = NotificationService();

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

  /// Handles [LoadExpenses] event by retrieving all expenses from the repository.
  /// Emits an [ExpenseLoading] state initially. If the retrieval is successful,
  /// it emits an [ExpenseLoaded] state with the list of expenses. If the operation
  /// fails, it emits an [ExpenseFailure] state with the error message.

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

  /// Handles [AddExpenseEvent] event by adding a new expense to the repository.
  /// Emits an [ExpenseLoading] state initially. If the operation is successful,
  /// it emits an [ExpenseLoaded] state with the updated list of expenses. If the
  /// operation fails, it emits an [ExpenseFailure] state with the error message.
  ///
  /// After the operation is complete, it adds a [LoadExpenses] event to the queue
  /// to reload the expenses from the repository. This ensures that the expenses
  /// are up-to-date.
  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    final currentState = state;
    emit(ExpenseLoading());

    final result = await addExpense(event.expense);
    result.fold(
      (failure) {
        emit(ExpenseFailure(failure.message));
      },
      (_) {
        // Preserve existing expenses in state
        if (currentState is ExpenseLoaded) {
          // Add the new expense to the list
          final updatedExpenses = [...currentState.expenses, event.expense];
          emit(ExpenseLoaded(updatedExpenses));
        }
        add(LoadExpenses());
      },
    );
  }

  /// Handles [UpdateExpenseEvent] event by updating an expense in the repository.
  /// Emits an [ExpenseLoading] state initially. If the operation is successful,
  /// it emits an [ExpenseLoaded] state with the updated list of expenses. If the
  /// operation fails, it emits an [ExpenseFailure] state with the error message.
  ///
  /// After the operation is complete, it adds a [LoadExpenses] event to the queue
  /// to reload the expenses from the repository. This ensures that the expenses
  /// are up-to-date.
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

  /// Handles [DeleteExpenseEvent] event by deleting an expense from the repository.
  /// Emits an [ExpenseLoading] state initially. If the operation is successful,
  /// it emits an [ExpenseLoaded] state with the updated list of expenses. If the
  /// operation fails, it emits an [ExpenseFailure] state with the error message.
  ///
  /// After the operation is complete, it adds a [LoadExpenses] event to the queue
  /// to reload the expenses from the repository. This ensures that the expenses
  /// are up-to-date.
  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final result = await deleteExpense(event.id);
    result.fold((failure) => emit(ExpenseFailure(failure.message)), (_) {
      // Cancel the notification for this expense
      _notificationService.cancelNotification(
        id: _notificationService.generateNotificationIdFromUuidPartial(
          event.id,
        ),
      );
      add(LoadExpenses());
    });
  }
}
