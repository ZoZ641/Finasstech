import 'package:hive_ce/hive.dart';

import 'budget_category.dart';

@HiveType(typeId: 2)
class Budget extends HiveObject {
  @HiveField(0)
  final String id;

  /*@HiveField(1)
  final String userId;*/

  @HiveField(1)
  final double forecastedSales;

  @HiveField(2)
  final Map<String, BudgetCategory> categories;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  Budget({
    required this.id,
    //required this.userId,
    required this.forecastedSales,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });
}
