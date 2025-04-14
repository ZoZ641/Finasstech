import 'package:finasstech/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';

/* Here we define the interface for the AuthRepository and its implementation is in the Data layer */
abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Stream<User?> authStateChanges();
}
