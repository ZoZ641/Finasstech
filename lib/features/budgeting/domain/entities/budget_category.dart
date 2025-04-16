import 'package:hive_ce/hive.dart';

@HiveType(typeId: 3)
class BudgetCategory extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double percentage;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final double minRecommendedPercentage;

  @HiveField(4)
  final double maxRecommendedPercentage;

  BudgetCategory({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.minRecommendedPercentage,
    required this.maxRecommendedPercentage,
  });
}
