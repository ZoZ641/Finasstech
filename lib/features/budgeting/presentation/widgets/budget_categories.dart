import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../data/models/budget_category_model.dart';
import '../../domain/entities/budget.dart';
import 'budget_category_item_create.dart';
import 'budget_category_item_settings.dart';

class BudgetCategoriesScreen extends StatelessWidget {
  final Budget budget;
  final Map<String, BudgetCategoryModel> categories;
  final VoidCallback onSave;
  final Function(String, BudgetCategoryModel) onCategoryChanged;
  final Function(String) onCategoryDeleted;
  final Function(BudgetCategoryModel) onCategoryAdded;
  final bool isSettingsPage;

  const BudgetCategoriesScreen({
    super.key,
    required this.budget,
    required this.categories,
    required this.onSave,
    required this.onCategoryChanged,
    required this.onCategoryDeleted,
    required this.onCategoryAdded,
    this.isSettingsPage = false,
  });

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final minPercentageController = TextEditingController(text: '0.0');
    final maxPercentageController = TextEditingController(text: '100.0');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: minPercentageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Minimum Percentage',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxPercentageController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum Percentage',
                    border: OutlineInputBorder(),
                    suffixText: '%',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final minPercentage =
                      double.tryParse(minPercentageController.text) ?? 0.0;
                  final maxPercentage =
                      double.tryParse(maxPercentageController.text) ?? 100.0;

                  if (name.isNotEmpty && minPercentage <= maxPercentage) {
                    final newCategory = BudgetCategoryModel(
                      name: name,
                      percentage: 0,
                      amount: 0,
                      usage: 0,
                      minRecommendedPercentage: minPercentage,
                      maxRecommendedPercentage: maxPercentage,
                    );
                    onCategoryAdded(newCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adjust Your Budget Categories')),
      floatingActionButton:
          isSettingsPage
              ? FloatingActionButton(
                onPressed: () => _showAddCategoryDialog(context),
                child: const Icon(Icons.add),
              )
              : null,
      body: Column(
        children: [
          if (!isSettingsPage)
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
          if (isSettingsPage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Categories Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (!isSettingsPage) const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final key = categories.keys.elementAt(index);
                final category = categories[key]!;

                if (isSettingsPage) {
                  // Use the settings version for the settings page
                  return BudgetCategoryItemSettings(
                    category: category,
                    onNameChanged: (newName) {
                      onCategoryChanged(key, category.copyWith(name: newName));
                    },
                    onMinMaxChanged: (min, max) {
                      onCategoryChanged(
                        key,
                        category.copyWith(
                          minRecommendedPercentage: min,
                          maxRecommendedPercentage: max,
                        ),
                      );
                    },
                    onDelete: () => onCategoryDeleted(key),
                  );
                } else {
                  // Use the create version for budget creation
                  return BudgetCategoryItemCreate(
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
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
