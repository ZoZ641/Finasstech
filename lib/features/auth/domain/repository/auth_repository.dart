import 'package:finasstech/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';

/* Here we define the interface for the AuthRepository and its implementation is in the Data layer */
abstract interface class AuthRepository {
  /// Sign up a new user with email and password
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign in a user with email and password
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  ///Check if the user is authenticated
  Stream<User?> authStateChanges();

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();
}
