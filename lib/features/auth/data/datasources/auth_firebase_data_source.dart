/* Firebase Data Source interface and implementation for Data layer*/

import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Interface defining the contract for Firebase authentication operations
abstract interface class AuthFirebaseSource {
  /// Creates a new user account with the given email and password
  ///
  /// [email] - The email address for the new user account
  /// [password] - The password for the new user account
  /// Returns a [UserModel] representing the newly created user
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  /// Signs in an existing user with the given email and password
  ///
  /// [email] - The email address of the user
  /// [password] - The password of the user
  /// Returns a [UserModel] representing the authenticated user
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Stream of authentication state changes
  ///
  /// Returns a [Stream] of [User] objects that emits whenever the user's
  /// authentication state changes (sign in, sign out, token refresh)
  Stream<User?> idTokenChanges();

  /// Signs out the current user
  ///
  /// Returns a [Future] that completes when the sign out operation is finished
  Future<void> signOut();
}

/// Implementation of [AuthFirebaseSource] that uses Firebase Authentication
class AuthFirebaseSourceImpl implements AuthFirebaseSource {
  /// Firebase Authentication instance
  final FirebaseAuth firebaseAuth;

  /// Creates a new [AuthFirebaseSourceImpl] with the given [firebaseAuth]
  const AuthFirebaseSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Attempt to sign in with email and password
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Extract user from credential
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'auth-error',
          message: 'User credential is null',
        );
      }

      // Create and return user model
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      return userModel;
    } on FirebaseAuthException {
      // Rethrow Firebase-specific errors to preserve error details
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in FirebaseAuthException
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Create new user account with email and password
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Extract user from credential
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'auth-error',
          message: 'User credential is null',
        );
      }

      // Create and return user model
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Rethrow Firebase-specific errors to preserve error details
      rethrow;
    } catch (e) {
      // Wrap unexpected errors in FirebaseAuthException
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }

  @override
  Stream<User?> idTokenChanges() {
    // Return stream of authentication state changes
    return firebaseAuth.idTokenChanges();
  }

  @override
  Future<void> signOut() {
    try {
      // Sign out the current user
      return firebaseAuth.signOut();
    } catch (e) {
      // Wrap any errors in FirebaseAuthException
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }
}
