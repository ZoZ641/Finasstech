import 'package:hive_ce/hive.dart';

import '../../../../core/common/entities/user.dart';

class UserModel extends User with HiveObjectMixin {
  final String uid;

  final String email;

  UserModel({required this.uid, required this.email})
    : super(uid: uid, email: email);

  // Create UserModel from Firebase Auth user (only email + uid)
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(uid: firebaseUser.uid, email: firebaseUser.email ?? '');
  }

  // Convert from local Hive (or Firestore if you use it later)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(uid: map['uid'] ?? '', email: map['email'] ?? '');
  }

  // Convert to map for local saving
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email};
  }
}
