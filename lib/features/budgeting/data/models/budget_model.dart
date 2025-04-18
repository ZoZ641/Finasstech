import 'package:hive_ce/hive.dart';
import '../../domain/entities/budget.dart';
import 'budget_category_model.dart';

@HiveType(typeId: 2)
class BudgetModel extends Budget with HiveObjectMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double forecastedSales;

  @HiveField(2)
  final Map<String, BudgetCategoryModel> categories;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.forecastedSales,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
         id: id,
         forecastedSales: forecastedSales,
         categories: categories,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    final cats = (map['categories'] as Map<String, dynamic>?) ?? {};
    final categories = cats.map(
      (key, value) => MapEntry(
        key,
        BudgetCategoryModel.fromMap(Map<String, dynamic>.from(value)),
      ),
    );

    return BudgetModel(
      id: map['id'] ?? '',
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
    final catMap = categories.map((key, value) => MapEntry(key, value.toMap()));

    return {
      'id': id,
      'forecastedSales': forecastedSales,
      'categories': catMap,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromEntity(Budget entity) {
    return BudgetModel(
      id: entity.id,
      forecastedSales: entity.forecastedSales,
      categories: entity.categories.map(
        (key, value) => MapEntry(key, BudgetCategoryModel.fromEntity(value)),
      ),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Budget toEntity() => Budget(
    id: id,
    forecastedSales: forecastedSales,
    categories: categories,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
