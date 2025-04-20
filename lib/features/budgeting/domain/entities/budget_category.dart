class BudgetCategory {
  final String name;
  final double percentage;
  final double usage;
  final double amount;
  final double minRecommendedPercentage;
  final double maxRecommendedPercentage;

  BudgetCategory({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.usage,
    required this.minRecommendedPercentage,
    required this.maxRecommendedPercentage,
  });
}
