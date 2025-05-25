import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../data/models/budget_category_model.dart';
import '../../domain/entities/budget.dart';
import 'budget_category_item_create.dart';

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
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category name cannot be empty'),
                      ),
                    );
                    return;
                  }

                  // Check if the category already exists
                  if (categories.containsKey(name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category with this name already exists'),
                      ),
                    );
                    return;
                  }

                  final minPercentage =
                      double.tryParse(minPercentageController.text) ?? 0.0;
                  final maxPercentage =
                      double.tryParse(maxPercentageController.text) ?? 100.0;

                  if (minPercentage <= maxPercentage) {
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Minimum percentage must be less than or equal to maximum percentage',
                        ),
                      ),
                    );
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
      appBar:
          isSettingsPage
              ? null
              : AppBar(
                centerTitle: false,
                title: const Text(
                  'Adjust Your Budget Categories',
                  style: TextStyle(fontSize: 20),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (!isSettingsPage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Forecasted Sales: £${budget.forecastedSales.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          double totalPercentage = categories.values.fold(
                            0.0,
                            (sum, category) => sum + category.percentage,
                          );
                          Color containerColor = AppPallete.primaryColor;
                          if (totalPercentage > 100) {
                            containerColor = AppPallete.errorColor;
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: containerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${totalPercentage.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: onSave,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text('Save Budget'),
                    ),
                  ),
                ],
              ),
            ),
          if (!isSettingsPage) const Divider(),
          Expanded(
            child:
                categories.isEmpty
                    ? const Center(
                      child: Text(
                        'No budget categories. Add one to get started.',
                      ),
                    )
                    : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final key = categories.keys.elementAt(index);
                        final category = categories[key]!;
                        // Add delete capability for budget creation
                        return Stack(
                          children: [
                            BudgetCategoryItemCreate(
                              key: ValueKey(key),
                              category: category,
                              forecastedSales: budget.forecastedSales,
                              onPercentageChanged: (newPercentage) {
                                final updatedAmount =
                                    budget.forecastedSales *
                                    (newPercentage / 100);
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
                            ),
                            Positioned(
                              top: 13,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppPallete.errorColor,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Category'),
                                        content: Text(
                                          'Are you sure you want to delete "${category.name}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              onCategoryDeleted(key);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
