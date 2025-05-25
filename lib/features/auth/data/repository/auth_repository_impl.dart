import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/features/auth/data/datasources/auth_firebase_data_source.dart';
import 'package:finasstech/features/auth/domain/repository/auth_repository.dart';
import '../../../../core/common/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fpdart/fpdart.dart';

/// Implementation of [AuthRepository] that uses Firebase Authentication
class AuthRepositoryImpl implements AuthRepository {
  /// Firebase Authentication data source
  final AuthFirebaseSource firebaseSource;

  /// Creates a new [AuthRepositoryImpl] with the given [firebaseSource]
  const AuthRepositoryImpl(this.firebaseSource);

  /// Signs in a user with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  /// Returns [Either] containing a [User] on success or [Failure] on error
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

  /// Creates a new user account with email and password
  ///
  /// [email] - The email address for the new account
  /// [password] - The password for the new account
  /// Returns [Either] containing a [User] on success or [Failure] on error
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

  /// Helper method to handle user authentication operations
  ///
  /// [fn] - The authentication function to execute
  /// Returns [Either] containing a [User] on success or [Failure] on error
  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      // Execute the authentication function
      final user = await fn();
      return Right(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      return Left(Failure(_mapFirebaseError(e)));
    } catch (e) {
      // Handle unexpected errors
      return Left(Failure('Unexpected error occurred.'));
    }
  }

  /// Maps Firebase authentication error codes to user-friendly messages
  ///
  /// [e] - The Firebase authentication exception
  /// Returns a user-friendly error message
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

  /// Stream of authentication state changes
  ///
  /// Returns a [Stream] of [User] objects that emits whenever the user's
  /// authentication state changes
  @override
  Stream<User?> idTokenChanges() {
    return firebaseSource.idTokenChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return User(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
    });
  }

  /// Signs out the current user
  ///
  /// Returns [Either] containing void on success or [Failure] on error
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
