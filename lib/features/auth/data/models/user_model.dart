import '../../../../core/common/entities/user.dart';

class UserModel extends User {
  UserModel({required String uid, required String email}) : super(uid, email);

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
