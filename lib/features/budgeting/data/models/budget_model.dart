import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_category.dart';

class BudgetModel extends Budget {
  BudgetModel({
    required super.id,
    //required String userId,
    required super.forecastedSales,
    required super.categories,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    Map<String, BudgetCategory> categories = {};

    if (map['categories'] != null) {
      (map['categories'] as Map<String, dynamic>).forEach((key, value) {
        categories[key] = BudgetCategory(
          name: value['name'],
          percentage: value['percentage'],
          amount: value['amount'],
          minRecommendedPercentage: value['minRecommendedPercentage'],
          maxRecommendedPercentage: value['maxRecommendedPercentage'],
        );
      });
    }

    return BudgetModel(
      id: map['id'] ?? '',
      //userId: map['userId'] ?? '',
      forecastedSales: map['forecastedSales']?.toDouble() ?? 0.0,
      categories: categories,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> categoriesMap = {};
    categories.forEach((key, value) {
      categoriesMap[key] = {
        'name': value.name,
        'percentage': value.percentage,
        'amount': value.amount,
        'minRecommendedPercentage': value.minRecommendedPercentage,
        'maxRecommendedPercentage': value.maxRecommendedPercentage,
      };
    });

    return {
      'id': id,
      //'userId': userId,
      'forecastedSales': forecastedSales,
      'categories': categoriesMap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? userId,
    double? forecastedSales,
    Map<String, BudgetCategory>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      //userId: userId ?? this.userId,
      forecastedSales: forecastedSales ?? this.forecastedSales,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
