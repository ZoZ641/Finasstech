import 'package:hive_ce/hive.dart';
import '../../domain/entities/budget_category.dart';

class BudgetCategoryModel extends BudgetCategory with HiveObjectMixin {
  final String name;

  final double percentage;

  final double amount;

  final double usage;

  final double minRecommendedPercentage;

  final double maxRecommendedPercentage;

  BudgetCategoryModel({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.usage,
    required this.minRecommendedPercentage,
    required this.maxRecommendedPercentage,
  }) : super(
         name: name,
         percentage: percentage,
         amount: amount,
         usage: usage,
         minRecommendedPercentage: minRecommendedPercentage,
         maxRecommendedPercentage: maxRecommendedPercentage,
       );

  factory BudgetCategoryModel.fromMap(Map<String, dynamic> map) {
    return BudgetCategoryModel(
      name: map['name'],
      percentage: map['percentage']?.toDouble() ?? 0.0,
      amount: map['amount']?.toDouble() ?? 0.0,
      usage: map['usage']?.toDouble() ?? 0.0,
      minRecommendedPercentage:
          map['minRecommendedPercentage']?.toDouble() ?? 0.0,
      maxRecommendedPercentage:
          map['maxRecommendedPercentage']?.toDouble() ?? 0.0,
    );
  }

  /// Converts the [BudgetCategoryModel] to a map representation that can be used for
  /// JSON serialization.
  ///
  /// The map contains the following keys:
  ///
  /// - `name`: The name of the category.
  /// - `percentage`: The percentage of the category.
  /// - `amount`: The amount allocated to the category.
  /// - `usage`: The usage of the category.
  /// - `minRecommendedPercentage`: The minimum recommended percentage of the category.
  /// - `maxRecommendedPercentage`: The maximum recommended percentage of the category.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'percentage': percentage,
      'amount': amount,
      'usage': usage,
      'minRecommendedPercentage': minRecommendedPercentage,
      'maxRecommendedPercentage': maxRecommendedPercentage,
    };
  }

  factory BudgetCategoryModel.fromEntity(BudgetCategory entity) {
    return BudgetCategoryModel(
      name: entity.name,
      percentage: entity.percentage,
      amount: entity.amount,
      usage: entity.usage,
      minRecommendedPercentage: entity.minRecommendedPercentage,
      maxRecommendedPercentage: entity.maxRecommendedPercentage,
    );
  }

  BudgetCategoryModel copyWith({
    String? name,
    double? percentage,
    double? amount,
    double? usage,
    double? minRecommendedPercentage,
    double? maxRecommendedPercentage,
  }) {
    return BudgetCategoryModel(
      name: name ?? this.name,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      usage: usage ?? this.usage,
      minRecommendedPercentage:
          minRecommendedPercentage ?? this.minRecommendedPercentage,
      maxRecommendedPercentage:
          maxRecommendedPercentage ?? this.maxRecommendedPercentage,
    );
  }
}
