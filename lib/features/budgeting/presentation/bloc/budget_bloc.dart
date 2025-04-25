import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/noparams.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_category.dart';
import '../../domain/usecases/calculate_budget_usage.dart';
import '../../domain/usecases/check_existing_budget_data.dart';
import '../../domain/usecases/create_budget_with_prophet.dart';
import '../../domain/usecases/create_initial_budget.dart';
import '../../domain/usecases/get_Latest_Budget.dart';
import '../../domain/usecases/get_all_budgets.dart';
import '../../domain/usecases/update_budget_categories.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final CheckExistingBudgetData checkExistingBudgetData;
  final CreateInitialBudget createInitialBudget;
  final CreateBudgetWithProphet createBudgetWithProphet;
  final UpdateBudgetCategories updateBudgetCategories;
  final GetLatestBudget getLatestBudget;
  final CalculateBudgetUsage calculateBudgetUsage;
  final GetAllBudgets getAllBudgets;

  Budget? _latestBudget;

  BudgetBloc({
    required this.checkExistingBudgetData,
    required this.createInitialBudget,
    required this.createBudgetWithProphet,
    required this.updateBudgetCategories,
    required this.getLatestBudget,
    required this.calculateBudgetUsage,
    required this.getAllBudgets,
  }) : super(BudgetChecking()) {
    on<CheckForExistingBudgetData>(_onCheckForExistingBudgetData);
    on<CreateInitialBudgetEvent>(_onCreateInitialBudget);
    on<CreateBudgetWithProphetEvent>(_onCreateBudgetWithProphet);
    on<UpdateBudgetCategoriesEvent>(_onUpdateBudgetCategories);
    on<GetLatestBudgetEvent>(_onGetLatestBudget);
    on<GetAllBudgetsEvent>(_onGetAllBudgets);
    on<CalculateBudgetUsageEvent>(_onCalculateBudgetUsage);
  }

  Budget? get budget => _latestBudget;

  /// Handles [CheckForExistingBudgetData] events by checking if there is
  /// existing budget data in the repository. Emits a [BudgetLoading] state
  /// while the check is in progress. If the check is successful and budget
  /// data exists, it emits a [BudgetDataExistsState] with a value of true.
  /// If no budget data exists, it emits a [BudgetEmpty] state. In case of
  /// a failure during the check, it emits a [BudgetError] state with an
  /// appropriate error message.

  Future<void> _onCheckForExistingBudgetData(
    CheckForExistingBudgetData event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    final result = await checkExistingBudgetData(NoParams());

    result.fold((failure) => emit(BudgetError(message: failure.message)), (
      hasData,
    ) {
      if (hasData) {
        emit(const BudgetDataExistsState(true));
      } else {
        emit(BudgetEmpty());
      }
    });
  }

  /// Handles [CreateInitialBudgetEvent] events by creating a new budget based
  /// on the given last year's sales and saving it to the repository. If the
  /// operation is successful, it emits a [BudgetCreatedNeedsCategorization]
  /// state with the newly created budget. This state explicitly indicates that
  /// categorization is needed. If the operation fails, it emits a
  /// [BudgetError] state with an error message.
  Future<void> _onCreateInitialBudget(
    CreateInitialBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await createInitialBudget(event.lastYearSales);

    result.fold((failure) => emit(BudgetError(message: failure.message)), (
      budget,
    ) {
      _latestBudget = budget;
      // Critical change: we explicitly need categorization
      return emit(BudgetCreatedNeedsCategorization(budget));
    });
  }

  //TODO: make this method only handles the forecasting then calls the _onCreateInitialBudget
  /// Handles [CreateBudgetWithProphetEvent] events by creating a new budget
  /// using Prophet forecasting and saving it to the repository. If the
  /// operation is successful, it emits a [BudgetCreatedNeedsCategorization]
  /// state with the newly created budget. This state explicitly indicates that
  /// categorization is needed. If the operation fails, it emits a
  /// [BudgetError] state with an error message.
  Future<void> _onCreateBudgetWithProphet(
    CreateBudgetWithProphetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await createBudgetWithProphet(NoParams());

    emit(
      result.fold((failure) => BudgetError(message: failure.message), (budget) {
        _latestBudget = budget;
        return BudgetCreated(budget);
      }),
    );
  }

  /// Handles [UpdateBudgetCategoriesEvent] by updating the categories of an
  /// existing budget. Emits a [BudgetLoading] state while the update is in
  /// progress. If the update is successful, it emits a [BudgetLoaded] state
  /// with the updated budget. In case of a failure during the update, it
  /// emits a [BudgetError] state with an appropriate error message.

  Future<void> _onUpdateBudgetCategories(
    UpdateBudgetCategoriesEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await updateBudgetCategories(
      UpdateBudgetCategoriesParams(
        budgetId: event.budgetId,
        categories: event.categories,
      ),
    );

    emit(
      result.fold((failure) => BudgetError(message: failure.message), (budget) {
        _latestBudget = budget;
        return BudgetLoaded(budget);
      }),
    );
  }

  /// Handles [GetLatestBudgetEvent] by retrieving the most recently updated
  /// budget from local storage. If the operation is successful, it emits a
  /// [BudgetLoaded] state with the loaded budget. If there is no budget found,
  /// it emits a [BudgetError] state with an appropriate error message. If the
  /// operation fails, it emits a [BudgetError] state with the error message
  /// from the failure.
  Future<void> _onGetLatestBudget(
    GetLatestBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await getLatestBudget(NoParams());

    emit(
      result.fold((failure) => BudgetError(message: failure.message), (budget) {
        _latestBudget = budget;
        return budget != null
            ? BudgetLoaded(budget)
            : const BudgetError(message: 'No budget found.');
      }),
    );
  }

  /// Handles [CalculateBudgetUsageEvent] by calculating the usage of each
  /// category in the given budget and emitting a [BudgetUsageCalculated]
  /// state with the budget and its usage by category. If the operation fails,
  /// it emits a [BudgetError] state with an error message.
  Future<void> _onCalculateBudgetUsage(
    CalculateBudgetUsageEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());

    final result = await calculateBudgetUsage(event.budget);

    emit(
      result.fold(
        (failure) => BudgetError(message: failure.message),
        (_) => BudgetUsageCalculated(
          budget: event.budget,
          usageByCategory: event.budget.categories.map(
            (k, v) => MapEntry(k, v.usage),
          ),
        ),
      ),
    );
  }

  Future<void> _onGetAllBudgets(
    GetAllBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    final result = await getAllBudgets(NoParams());
    result.fold(
      (failure) => emit(BudgetError(message: failure.message)),
      (budgets) => emit(AllBudgetsLoaded(budgets)),
    );
  }
}
