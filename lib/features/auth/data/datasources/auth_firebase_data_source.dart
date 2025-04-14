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
  // Future<void> signOut();
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
}

/*
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

abstract interface class AuthFirebaseSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String companyName,
    required String email,
    required String password,
  });
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  });
  // Future<String> signInWithGoogle();
  //
  // Future<String> signInWithApple();
  //
  // Future<void> signOut();
}

*/
/*Firebase implementation of the AuthFirebaseSource interface */ /*

class AuthFirebaseSourceImpl implements AuthFirebaseSource {
  final FirebaseAuth firebaseAuth;
  const AuthFirebaseSourceImpl(this.firebaseAuth);

  @override
  Future<String> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user!.uid;
    } catch (e) {
      throw FirebaseAuthException(code: 'auth-error', message: e.toString());
    }
  }

  */
/* Calls Firebase's createUserWithEmailAndPassword().
    Updates the user's display name.
    Returns the user ID or throws an error.*/ /*


  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String companyName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //ToDo: hive here
      // Store user data in Firestore
      // await _firestore.collection('users').doc(userCredential.user!.uid).set({
      //   'name': name,
      //   'companyName': companyName,
      //   'email': email,
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      return UserModel.fromFirebaseUser(userCredential.user!.);
    } catch (e) {
      throw FirebaseAuthException(code: 'auth-error', message: e.toString());
    }
  }
}
*/
