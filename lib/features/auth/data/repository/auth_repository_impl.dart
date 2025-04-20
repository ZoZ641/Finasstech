import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/features/auth/data/datasources/auth_firebase_data_source.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import '../../../../core/common/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseSource firebaseSource;
  const AuthRepositoryImpl(this.firebaseSource);

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await firebaseSource.signInWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await firebaseSource.signUpWithEmailPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      final user = await fn();
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(Failure(_mapFirebaseError(e)));
    } catch (e) {
      return Left(Failure('Unexpected error occurred.'));
    }
  }

  String _mapFirebaseError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return firebaseSource.idTokenChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
    });
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure('Sign out failed: ${e.toString()}'));
    }
  }
}
