import 'package:hive_ce/hive.dart';

@HiveType(typeId: 1)
class User extends HiveObject {
  @HiveField(0)
  final String uid;
  @HiveField(1)
  final String email;

  User(this.uid, this.email);
}
