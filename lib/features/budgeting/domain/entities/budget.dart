import 'budget_category.dart';

class Budget {
  final String id;
  final double forecastedSales;
  final Map<String, BudgetCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.forecastedSales,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });
}
