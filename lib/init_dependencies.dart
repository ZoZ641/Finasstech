import 'package:finasstech/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:finasstech/features/auth/data/datasources/auth_firebase_data_source.dart';
import 'package:finasstech/features/auth/data/repository/auth_repository_impl.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_up.dart';
import 'package:finasstech/features/auth/domain/usecases/user_sign_in.dart';
import 'package:finasstech/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:finasstech/hive/hive_registrar.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'firebase_options.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  //initiate hive
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox<User>('user');

  //create a box
  _initAuth();

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
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSingIn: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
