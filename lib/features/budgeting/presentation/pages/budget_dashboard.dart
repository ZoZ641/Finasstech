import 'package:flutter/material.dart';

import '../../domain/entities/budget.dart';
import '../widgets/budget_category_card.dart';

class BudgetDashboard extends StatelessWidget {
  final Budget budget;
  final Map<String, double>? usage;
  final bool isHistory;
  const BudgetDashboard({
    super.key,
    required this.budget,
    this.usage,
    this.isHistory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Budget Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: budget.categories.length,
            itemBuilder: (context, index) {
              final categoryKey = budget.categories.keys.elementAt(index);
              final category = budget.categories[categoryKey]!;

              // Skip categories with 0 percentage (user chose to ignore them)
              if (category.percentage == 0) {
                return const SizedBox.shrink();
              }

              // For historical budgets, use the usage from the category itself
              // For current budgets, use the usage from the state
              final usageAmount =
                  isHistory ? category.usage : (usage?[categoryKey] ?? 0.0);

              return BudgetCategoryCard(
                category: category,
                usageAmount: usageAmount,
                isHistory: isHistory,
              );
            },
          ),
        ),
      ],
    );
  }
}
