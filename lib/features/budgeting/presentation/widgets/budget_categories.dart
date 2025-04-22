import 'package:flutter/material.dart';

import '../../data/models/budget_category_model.dart';
import '../../domain/entities/budget.dart';
import 'budget_category_item.dart';

class BudgetCategoriesScreen extends StatelessWidget {
  final Budget budget;
  final Map<String, BudgetCategoryModel> categories;
  final VoidCallback onSave;
  final Function(String, BudgetCategoryModel) onCategoryChanged;

  const BudgetCategoriesScreen({
    super.key,
    required this.budget,
    required this.categories,
    required this.onSave,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adjust Your Budget Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forecasted Sales: £${budget.forecastedSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: onSave,
                  child: const Text('Save Budget'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final key = categories.keys.elementAt(index);
                final category = categories[key]!;

                return BudgetCategoryItem(
                  category: category,
                  forecastedSales: budget.forecastedSales,
                  onPercentageChanged: (newPercentage) {
                    final updatedAmount =
                        budget.forecastedSales * (newPercentage / 100);
                    onCategoryChanged(
                      key,
                      category.copyWith(
                        percentage: newPercentage,
                        amount: updatedAmount,
                      ),
                    );
                  },
                  onAmountChanged: (newAmount) {
                    final newPercentage =
                        (newAmount / budget.forecastedSales) * 100;
                    onCategoryChanged(
                      key,
                      category.copyWith(
                        amount: newAmount,
                        percentage: newPercentage,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
