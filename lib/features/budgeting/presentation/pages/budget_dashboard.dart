import 'package:flutter/material.dart';

import '../../domain/entities/budget.dart';

class BudgetDashboard extends StatelessWidget {
  final Budget budget;
  final Map<String, double>? usage;
  const BudgetDashboard({super.key, required this.budget, this.usage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budget Dashboard')),
      body: Column(
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

                final spent = usage![categoryKey] ?? 0.0;
                final remainingAmount = category.amount - spent;
                final usagePercentage =
                    category.amount > 0
                        ? (spent / category.amount).clamp(0.0, 2.0)
                        : 0.0;

                // Determine status color
                Color statusColor = Colors.green;
                if (usagePercentage > 0.85 && usagePercentage <= 1.0) {
                  statusColor = Colors.orange; // Approaching limit
                } else if (usagePercentage > 1.0) {
                  statusColor = Colors.red; // Over budget
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '\$${spent.toStringAsFixed(2)} / \$${category.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: usagePercentage,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: remainingAmount < 0 ? Colors.red : null,
                              ),
                            ),
                            Text(
                              usagePercentage > 1.0
                                  ? 'Over by ${((usagePercentage - 1.0) * 100).toStringAsFixed(1)}%'
                                  : '${(usagePercentage * 100).toStringAsFixed(1)}% used',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight:
                                    usagePercentage > 0.9
                                        ? FontWeight.bold
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
