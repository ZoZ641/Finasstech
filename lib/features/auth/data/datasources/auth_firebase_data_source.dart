/* Firebase Data Source interface and implementation for Data layer*/

//ToDo: move hive to local datasource file

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

import '../models/user_model.dart';

abstract interface class AuthFirebaseSource {
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Stream<User?> idTokenChanges();
  // Future<String> signInWithGoogle();
  // Future<String> signInWithApple();
  Future<void> signOut();
}

class AuthFirebaseSourceImpl implements AuthFirebaseSource {
  final FirebaseAuth firebaseAuth;
  const AuthFirebaseSourceImpl(this.firebaseAuth);

  @override
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'auth-error',
          message: 'User credential is null',
        );
      }
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      return userModel;
    } on FirebaseAuthException {
      // ✅ Rethrow Firebase errors with their original message and code
      rethrow;
    } catch (e) {
      // ✅ Catch all other errors
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'auth-error',
          message: 'User credential is null',
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );

      final box = await Hive.openBox<UserModel>('users');
      await box.put(userModel.uid, userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      // ✅ Rethrow Firebase errors with their original message and code
      rethrow;
    } catch (e) {
      // ✅ Catch all other errors
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }

  @override
  Stream<User?> idTokenChanges() {
    return firebaseAuth.idTokenChanges();
  }

  @override
  Future<void> signOut() {
    try {
      return firebaseAuth.signOut();
    } catch (e) {
      throw FirebaseAuthException(code: 'error', message: e.toString());
    }
  }
}
