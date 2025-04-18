import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/features/auth/data/datasources/auth_firebase_data_source.dart';
import 'package:finasstech/features/auth/data/repository/auth_repository_impl.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_up.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_in.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:finasstech/features/budgeting/domain/usecases/calculate_budget_usage.dart';
import 'package:finasstech/features/budgeting/presentation/bloc/budget_bloc.dart';
import 'package:finasstech/hive/hive_register.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'features/auth/domain/usecases/user_sign_out.dart';
import 'features/budgeting/data/datasources/budget_local_data_source.dart';
import 'features/budgeting/data/repository/budget_repository_impl.dart';
import 'features/budgeting/domain/repository/budget_repository.dart';
import 'features/budgeting/domain/usecases/check_existing_budget_data.dart';
import 'features/budgeting/domain/usecases/create_budget_with_prophet.dart';
import 'features/budgeting/domain/usecases/create_initial_budget.dart';
import 'features/budgeting/domain/usecases/get_Latest_Budget.dart';
import 'features/budgeting/domain/usecases/update_budget_categories.dart';
import 'firebase_options.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  //initiate hive
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<User>('user');
  // Budget feature dependencies
  final budgetBox = await Hive.openBox<BudgetModel>('budgets');
  budgetBox.clear();
  final transactionsBox = await Hive.openBox('transactions');

  // final budget = budgetBox.values.toList();
  // print(budget);
  //auth feature dependencies
  _initAuth();

  //budget feature dependencies
  _initBudget(budgetBox, transactionsBox);

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
    ..registerFactory(() => CreateInitialBudget(serviceLocator()))
    ..registerFactory(() => CreateBudgetWithProphet(serviceLocator()))
    ..registerFactory(() => UpdateBudgetCategories(serviceLocator()))
    ..registerFactory(() => GetLatestBudget(serviceLocator()))
    ..registerLazySingleton(() => CalculateBudgetUsage(serviceLocator()))
    ..registerLazySingleton(
      () => BudgetBloc(
        checkExistingBudgetData: serviceLocator(),
        createInitialBudget: serviceLocator(),
        createBudgetWithProphet: serviceLocator(),
        updateBudgetCategories: serviceLocator(),
        getLatestBudget: serviceLocator(),
        calculateBudgetUsage: serviceLocator(),
      ),
    );
}
