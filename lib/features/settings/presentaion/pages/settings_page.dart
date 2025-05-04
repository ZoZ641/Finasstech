import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/common/widgets/loader.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../budgeting/data/models/budget_category_model.dart';
import '../../../budgeting/presentation/bloc/budget_bloc.dart';
import '../../../budgeting/presentation/widgets/budget_categories.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import '../../../budgeting/presentation/pages/create_budget_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Track changes locally before saving
  Map<String, BudgetCategoryModel>? _tempCategories;
  // Track if unsaved changes exist
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(GetLatestBudgetEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          // Show save indicator if changes exist
          if (_hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save changes',
                onPressed: () {
                  _saveChanges();
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSignOutButton(),
          const Divider(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateBudgetPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add_chart),
              label: const Text('Create New Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          const Divider(height: 16),
          // Temporarily disabled budget category editing
          /*
          _buildBudgetContent(),
          */
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Check for unsaved changes before signing out
          if (_hasUnsavedChanges) {
            _showUnsavedChangesDialog();
          } else {
            context.read<AuthBloc>().add(AuthSignOut());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
            'You have unsaved changes. What would you like to do?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveChanges();
              },
              child: const Text('Save Changes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _hasUnsavedChanges = false;
                });
                context.read<AuthBloc>().add(AuthSignOut());
              },
              child: const Text('Discard Changes'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    if (_tempCategories != null) {
      final budgetState = context.read<BudgetBloc>().state;
      if (budgetState is BudgetLoaded) {
        context.read<BudgetBloc>().add(
          UpdateBudgetCategoriesEvent(
            budgetId: budgetState.budget.id,
            categories: _tempCategories!,
          ),
        );
        setState(() {
          _hasUnsavedChanges = false;
        });
      }
    }
  }

  Widget _buildBudgetCategories(BudgetLoaded state) {
    // Initialize temp categories if not already done
    _tempCategories ??= Map<String, BudgetCategoryModel>.from(
      state.budget.categories,
    );

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget Categories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _hasUnsavedChanges ? _saveChanges : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _hasUnsavedChanges
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateBudgetPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_chart),
                  label: const Text('Create New Budget'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: BudgetCategoriesScreen(
              budget: state.budget,
              categories: _tempCategories!,
              onSave: _saveChanges,
              onCategoryChanged: (key, category) {
                // Update our local state only
                setState(() {
                  _tempCategories![key] = category;
                  _hasUnsavedChanges = true;
                });
              },
              onCategoryAdded: (newCategory) {
                // Update our local state only
                setState(() {
                  _tempCategories![newCategory.name] = newCategory;
                  _hasUnsavedChanges = true;
                });
              },
              onCategoryDeleted: (key) {
                // Update our local state only
                setState(() {
                  _tempCategories!.remove(key);
                  _hasUnsavedChanges = true;
                });
              },
              isSettingsPage: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetContent() {
    return BlocConsumer<BudgetBloc, BudgetState>(
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
          // Refresh the budget after successful update
          context.read<BudgetBloc>().add(GetLatestBudgetEvent());
        }
      },
      builder: (context, state) {
        if (state is BudgetLoading) {
          return const Expanded(child: Center(child: Loader()));
        } else if (state is BudgetLoaded) {
          return _buildBudgetCategories(state);
        }
        return const Expanded(child: Center(child: Loader()));
      },
    );
  }
}
