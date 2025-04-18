import 'package:hive_ce/hive.dart';
import '../../domain/entities/budget_category.dart';

@HiveType(typeId: 3)
class BudgetCategoryModel extends BudgetCategory {
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

  BudgetCategoryModel({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.minRecommendedPercentage,
    required this.maxRecommendedPercentage,
  }) : super(
         name: name,
         percentage: percentage,
         amount: amount,
         minRecommendedPercentage: minRecommendedPercentage,
         maxRecommendedPercentage: maxRecommendedPercentage,
       );

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      name: map['name'],
      percentage: map['percentage']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
      minRecommendedPercentage:
          map['minRecommendedPercentage']?.toDouble() ?? 0.0,
      maxRecommendedPercentage:
          map['maxRecommendedPercentage']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'percentage': percentage,
      'amount': amount,
      'minRecommendedPercentage': minRecommendedPercentage,
      'maxRecommendedPercentage': maxRecommendedPercentage,
    };
  }

  factory BudgetCategoryModel.fromEntity(BudgetCategory entity) {
    return BudgetCategoryModel(
      name: entity.name,
      percentage: entity.percentage,
      amount: entity.amount,
      minRecommendedPercentage: entity.minRecommendedPercentage,
      maxRecommendedPercentage: entity.maxRecommendedPercentage,
    );
  }
}
