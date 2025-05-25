import 'package:hive_ce/hive.dart';

import '../../../../core/common/entities/user.dart';

/// A model class representing a user in the application.
/// Extends the base [User] class and mixes in [HiveObjectMixin] for local storage capabilities.
class UserModel extends User with HiveObjectMixin {
  /// Unique identifier for the user
  @override
  final String uid;

  /// Email address of the user
  @override
  final String email;

  /// Creates a new [UserModel] instance with the specified [uid] and [email].
  ///
  /// [uid] - The unique identifier for the user
  /// [email] - The email address of the user
  UserModel({required this.uid, required this.email})
    : super(uid: uid, email: email);

  /// Creates a [UserModel] instance from a Firebase Auth [User] object.
  ///
  /// [firebaseUser] - The Firebase Auth user to convert
  /// Returns a new [UserModel] with the user's uid and email
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email, // Fallback to empty string if email is null
    );
  }

  /// Creates a [UserModel] instance from a map of user data.
  ///
  /// [map] - A map containing user data with 'uid' and 'email' keys
  /// Returns a new [UserModel] with the mapped data
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '', // Fallback to empty string if uid is null
      email: map['email'] ?? '', // Fallback to empty string if email is null
    );
  }

  /// Converts the [UserModel] instance to a map for local storage.
  ///
  /// Returns a map containing the user's uid and email
  Map<String, dynamic> toMap() {
    return {'uid': uid, 'email': email};
  }
}
