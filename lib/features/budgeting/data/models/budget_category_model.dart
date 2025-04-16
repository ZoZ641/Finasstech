import '../../domain/entities/budget_category.dart';

class BudgetCategoryModel extends BudgetCategory {
  BudgetCategoryModel({
    required super.name,
    required super.percentage,
    required super.amount,
    required super.minRecommendedPercentage,
    required super.maxRecommendedPercentage,
  });
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

  BudgetCategoryModel copyWith({
    String? name,
    double? percentage,
    double? amount,
    double? minRecommendedPercentage,
    double? maxRecommendedPercentage,
  }) {
    return BudgetCategoryModel(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      minRecommendedPercentage:
          minRecommendedPercentage ?? this.minRecommendedPercentage,
      maxRecommendedPercentage:
          maxRecommendedPercentage ?? this.maxRecommendedPercentage,
    );
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
