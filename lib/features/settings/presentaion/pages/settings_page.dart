import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../budgeting/data/models/budget_category_model.dart';
import '../../../budgeting/domain/entities/budget.dart';
import '../../../budgeting/presentation/bloc/budget_bloc.dart';
import '../../../budgeting/presentation/widgets/budget_categories.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetError) {
            showSnackBar(context, 'Error', state.message, ContentType.failure);
          } else if (state is BudgetUpdated) {
            showSnackBar(
              context,
              'Success',
              'Budget categories updated successfully',
              ContentType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetLoading) {
            return const Center(child: Loader());
          }

          if (state is BudgetLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOut());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPallete.inputFieldErrorColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // Budget Categories Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Budget Categories',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Flexible(
                  child: BudgetCategoriesScreen(
                    budget: state.budget,
                    categories: state.budget.categories.map(
                      (key, value) =>
                          MapEntry(key, BudgetCategoryModel.fromEntity(value)),
                    ),
                    onSave: () {
                      context.read<BudgetBloc>().add(
                        UpdateBudgetCategoriesEvent(
                          budgetId: state.budget.id,
                          categories: state.budget.categories,
                        ),
                      );
                    },
                    onCategoryChanged: (key, category) {
                      final updatedCategories =
                          Map<String, BudgetCategoryModel>.from(
                            state.budget.categories,
                          );
                      updatedCategories[key] = category;
                      context.read<BudgetBloc>().add(
                        UpdateBudgetCategoriesEvent(
                          budgetId: state.budget.id,
                          categories: updatedCategories,
                        ),
                      );
                    },
                    onCategoryAdded: (newCategory) {
                      final updatedCategories =
                          Map<String, BudgetCategoryModel>.from(
                            state.budget.categories,
                          );
                      updatedCategories[newCategory.name] = newCategory;
                      context.read<BudgetBloc>().add(
                        UpdateBudgetCategoriesEvent(
                          budgetId: state.budget.id,
                          categories: updatedCategories,
                        ),
                      );
                    },
                    onCategoryDeleted: (key) {
                      final updatedCategories =
                          Map<String, BudgetCategoryModel>.from(
                            state.budget.categories,
                          );
                      updatedCategories.remove(key);
                      context.read<BudgetBloc>().add(
                        UpdateBudgetCategoriesEvent(
                          budgetId: state.budget.id,
                          categories: updatedCategories,
                        ),
                      );
                    },
                    isSettingsPage: true,
                  ),
                ),
                const Divider(height: 32),

                // Sign Out Button
              ],
            );
          }

          return const Center(child: Text('No budget data available'));
        },
      ),
    );
  }
}
