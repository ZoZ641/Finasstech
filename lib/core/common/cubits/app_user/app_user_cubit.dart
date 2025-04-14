import 'package:bloc/bloc.dart';
import 'package:finasstech/core/common/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:meta/meta.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  AppUserCubit(this._firebaseAuth) : super(AppUserLoading()) {
    _firebaseAuth.idTokenChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        emit(AppUserUnauthenticated());
      } else {
        emit(
          AppUserAuthenticated(
            User(firebaseUser.uid, firebaseUser.email ?? ''),
          ),
        );
      }
    });
  }
}
