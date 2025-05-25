import 'package:bloc/bloc.dart';
import 'package:finasstech/core/common/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

part 'app_user_state.dart';

/// A Cubit that manages the authentication state of the application user.
///
/// This Cubit listens to Firebase Auth state changes and emits appropriate states:
/// - [AppUserLoading] when initializing
/// - [AppUserUnauthenticated] when no user is signed in
/// - [AppUserAuthenticated] when a user is signed in with their [User] data
class AppUserCubit extends Cubit<AppUserState> {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AppUserCubit(this._firebaseAuth) : super(AppUserLoading()) {
    _firebaseAuth.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        emit(AppUserUnauthenticated());
      } else {
        emit(
          AppUserAuthenticated(
            User(uid: firebaseUser.uid, email: firebaseUser.email ?? ''),
          ),
        );
      }
    });
  }
}
