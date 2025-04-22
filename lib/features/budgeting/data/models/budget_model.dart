import 'package:hive_ce/hive.dart';
import '../../domain/entities/budget.dart';
import 'budget_category_model.dart';

class BudgetModel extends Budget with HiveObjectMixin {
  final String id;

  final double forecastedSales;

  final Map<String, BudgetCategoryModel> categories;

  final DateTime createdAt;

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

  /// Converts the [BudgetModel] to a map representation that can be used for
  /// JSON serialization.
  ///
  /// The map contains the following keys:
  ///
  /// - `id`: The id of the budget.
  /// - `forecastedSales`: The forecasted sales of the budget.
  /// - `categories`: A map of the categories of the budget, where the key is
  ///    the id of the category and the value is a map representation of the
  ///    category, as obtained by [BudgetCategoryModel.toMap].
  /// - `createdAt`: The creation date of the budget, in ISO 8601 format.
  /// - `updatedAt`: The last update date of the budget, in ISO 8601 format.
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

  /// Converts the [BudgetModel] to a [Budget] entity object.
  Budget toEntity() => Budget(
    id: id,
    forecastedSales: forecastedSales,
    categories: categories,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  /// Creates a copy of the [BudgetModel] with the given fields replaced with
  /// the new values.
  //
  /// The fields that can be replaced are:
  //
  /// - `id`: The id of the budget.
  /// - `forecastedSales`: The forecasted sales of the budget.
  /// - `categories`: The categories of the budget.
  /// - `createdAt`: The creation date of the budget.
  /// - `updatedAt`: The last update date of the budget.
  //
  /// If a field is not provided, the value of the current [BudgetModel]
  /// instance is used instead.
  BudgetModel copyWith({
    String? id,
    double? forecastedSales,
    Map<String, BudgetCategoryModel>? categories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      forecastedSales: forecastedSales ?? this.forecastedSales,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
