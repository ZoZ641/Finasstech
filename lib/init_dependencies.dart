import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/core/services/notification_service.dart';
import 'package:finasstech/features/auth/data/datasources/auth_firebase_data_source.dart';
import 'package:finasstech/features/auth/data/repository/auth_repository_impl.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_up.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_in.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:finasstech/features/budgeting/domain/usecases/calculate_budget_usage.dart';
import 'package:finasstech/features/budgeting/domain/usecases/get_all_budgets.dart';
import 'package:finasstech/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'core/services/gemini_service.dart';
import 'features/analytics/presentation/bloc/gemini_bloc.dart';
import 'features/auth/domain/usecases/user_sign_out.dart';
import 'features/budgeting/data/datasources/budget_local_data_source.dart';
import 'features/budgeting/data/repository/budget_repository_impl.dart';
import 'features/budgeting/domain/repository/budget_repository.dart';
import 'features/budgeting/domain/usecases/check_existing_budget_data.dart';
import 'features/budgeting/domain/usecases/create_budget_with_prophet.dart';
import 'features/budgeting/domain/usecases/create_initial_budget.dart';
import 'features/budgeting/domain/usecases/get_Latest_Budget.dart';
import 'features/budgeting/domain/usecases/update_budget_categories.dart';
import 'features/budgeting/domain/usecases/check_current_year_budget.dart';
import 'features/dashboard/presentaion/bloc/dashboard_bloc.dart';
import 'features/expenses/data/datasources/expense_local_data_source.dart';
import 'features/expenses/data/models/expense_model.dart';
import 'features/expenses/data/repository/expense_repository_impl.dart';
import 'features/expenses/domain/repository/expense_repository.dart';
import 'features/expenses/domain/usecases/add_expense.dart';
import 'features/expenses/domain/usecases/delete_expense.dart';
import 'features/expenses/domain/usecases/get_all_expenses.dart';
import 'features/expenses/domain/usecases/update_expense.dart';
import 'features/expenses/presentation/bloc/expense_bloc.dart';
import 'firebase_options.dart';
import 'core/database/hive/hive_adapters.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  //initiate hive
  Hive
    ..init(appDocDir.path)
    ..registerAdapter(ExpenseModelAdapter())
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(BudgetModelAdapter())
    ..registerAdapter(BudgetCategoryModelAdapter());
  //auth feature dependencies
  await Hive.openBox<User>('user');
  // Budget feature dependencies
  final budgetBox = await Hive.openBox<BudgetModel>('budgets');
  final expensesBox = await Hive.openBox<ExpenseModel>('expenses');

  //DotEnv initialize
  await dotenv.load(fileName: ".env");
  //auth feature dependencies
  _initAuth();

  //budget feature dependencies
  _initBudget(budgetBox, expensesBox);

  _initExpense(expensesBox);
  _initDashboard();

  _initGemini();

  /* Services */
  // Register GeminiService
  serviceLocator.registerLazySingleton(
    () => GeminiService(dotenv.env['GeminiAPIKey']!),
  );

  // Register NotificationService
  serviceLocator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  /* Firebase setup  */
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);

  /* Core */
  serviceLocator.registerLazySingleton(() => AppUserCubit(serviceLocator()));
}

void _initAuth() {
  serviceLocator
    //datasource
    ..registerFactory<AuthFirebaseSource>(
      () => AuthFirebaseSourceImpl(serviceLocator()),
    )
    //repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    //Use cases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserSingIn(serviceLocator()))
    ..registerFactory(() => UserSignOut(serviceLocator()))
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSingIn: serviceLocator(),
        appUserCubit: serviceLocator(),
        userSignOut: serviceLocator(),
      ),
    );
}

void _initBudget(Box<BudgetModel> budgetBox, Box transactionsBox) {
  serviceLocator
    ..registerFactory<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(
        budgetBox: budgetBox,
        transactionsBox: transactionsBox,
      ),
    )
    ..registerFactory<BudgetRepository>(
      () => BudgetRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => CheckExistingBudgetData(serviceLocator()))
    ..registerFactory(() => CheckCurrentYearBudget(serviceLocator()))
    ..registerFactory(() => CreateInitialBudget(serviceLocator()))
    ..registerFactory(() => CreateBudgetWithProphet(serviceLocator()))
    ..registerFactory(() => UpdateBudgetCategories(serviceLocator()))
    ..registerFactory(() => GetLatestBudget(serviceLocator()))
    ..registerFactory(() => GetAllBudgets(serviceLocator()))
    ..registerLazySingleton(() => CalculateBudgetUsage(serviceLocator()))
    ..registerLazySingleton(
      () => BudgetBloc(
        checkExistingBudgetData: serviceLocator(),
        checkCurrentYearBudget: serviceLocator(),
        createInitialBudget: serviceLocator(),
        createBudgetWithProphet: serviceLocator(),
        updateBudgetCategories: serviceLocator(),
        getLatestBudget: serviceLocator(),
        calculateBudgetUsage: serviceLocator(),
        getAllBudgets: serviceLocator(),
      ),
    );
}

void _initExpense(Box<ExpenseModel> expensesBox) {
  serviceLocator
    ..registerFactory<ExpenseLocalDataSource>(
      () => ExpenseLocalDataSourceImpl(expenseBox: expensesBox),
    )
    ..registerFactory<ExpenseRepository>(
      () => ExpenseRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => AddExpense(serviceLocator()))
    ..registerFactory(() => UpdateExpense(serviceLocator()))
    ..registerFactory(() => DeleteExpense(serviceLocator()))
    ..registerFactory(() => GetAllExpenses(serviceLocator()))
    ..registerLazySingleton(
      () => ExpenseBloc(
        addExpense: serviceLocator(),
        updateExpense: serviceLocator(),
        deleteExpense: serviceLocator(),
        getAllExpenses: serviceLocator(),
        /*calculateBudgetUsage: serviceLocator(),
        budgetBloc: serviceLocator<BudgetBloc>(),*/
      ),
    );
}

void _initDashboard() {
  serviceLocator.registerLazySingleton(
    () => DashboardBloc(getAllExpenses: serviceLocator()),
  );
}

void _initGemini() {
  serviceLocator.registerLazySingleton(() => GeminiBloc(serviceLocator()));
}
