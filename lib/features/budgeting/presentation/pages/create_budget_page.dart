import 'package:finasstech/core/common/widgets/loader.dart';
import 'package:finasstech/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../core/utils/money_formater.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../data/models/budget_category_model.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_category.dart';
import '../bloc/budget_bloc.dart';
import '../widgets/budget_categories.dart';
import 'budget_dashboard.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final TextEditingController _lastYearSalesController =
      TextEditingController();
  Budget? existingBudget;
  Map<String, BudgetCategoryModel> categories = {};
  bool awaitingCategorySetup = false;

  /*@override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
  }*/

  @override
  void dispose() {
    _lastYearSalesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetCreatedNeedsCategorization) {
          debugPrint('✅ Switching to Budget Category Setup View...');
          setState(() {
            existingBudget = state.budget;
            categories = Map.from(state.budget.categories);
            awaitingCategorySetup = true;
          });

          debugPrint('awaitingCategorySetup: $awaitingCategorySetup');
          debugPrint('existingBudget: $existingBudget');
          debugPrint('categories length: ${categories.length}');

          Future.microtask(() {
            if (mounted) {
              showSnackBar(
                context,
                'Success',
                'Customize your budget categories below.',
                ContentType.success,
              );
            }
          });
        } else if (state is BudgetUpdated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BudgetDashboard(budget: state.budget),
            ),
          );

          showSnackBar(
            context,
            'Success',
            'Budget updated successfully!',
            ContentType.success,
          );
        } else if (state is BudgetLoaded) {
          setState(() {
            existingBudget = state.budget;
            categories = Map.from(state.budget.categories);
            awaitingCategorySetup = true;
          });

          context.read<BudgetBloc>().add(
            CalculateBudgetUsageEvent(budget: state.budget),
          );
        } else if (state is BudgetEmpty) {
          debugPrint('🆕 No budget found, showing setup screen.');
          setState(() {
            existingBudget = null;
            categories = {};
            awaitingCategorySetup = false;
          });
        }
      },
      builder: (context, state) {
        debugPrint('awaitingCategorySetup: $awaitingCategorySetup');
        debugPrint('existingBudget: $existingBudget');
        debugPrint('categories length: ${categories.length}');
        if (state is BudgetLoading && !awaitingCategorySetup) {
          return const Loader();
        }

        if (awaitingCategorySetup && existingBudget != null) {
          debugPrint('✅ Rendering BudgetCategoriesScreen');
          return BudgetCategoriesScreen(
            budget: existingBudget!,
            categories: categories,
            onSave: _saveCategories,
            onCategoryChanged: (key, updatedCategory) {
              setState(() => categories[key] = updatedCategory);
            },
            onCategoryAdded: (newCategory) {
              setState(() {
                categories[newCategory.name] = newCategory;
              });
            },
            onCategoryDeleted: (key) {
              setState(() {
                categories.remove(key);
              });
            },
          );
        }

        // This includes initial empty case and returning user
        return _buildFirstTimeUserView();
      },
    );
  }

  Widget _buildFirstTimeUserView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Budget Setup!',
          style: TextStyle(fontSize: 24),
          overflow: TextOverflow.visible,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter your total sales from last year to begin.'),
            const SizedBox(height: 24),
            TextField(
              controller: _lastYearSalesController,
              keyboardType: TextInputType.number,
              inputFormatters: [MoneyInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Last Year Sales',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_pound),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleSalesSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Create Budget',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSalesSubmit() {
    final salesText =
        _lastYearSalesController.text
            .replaceAll(',', '')
            .replaceAll('£', '')
            .trim();

    if (salesText.isEmpty) {
      showSnackBar(
        context,
        'Error',
        'Please enter your last year sales.',
        ContentType.failure,
      );
      return;
    }

    final sales = double.tryParse(salesText);
    if (sales == null || sales <= 0) {
      showSnackBar(
        context,
        'Error',
        'Please enter a valid amount.',
        ContentType.failure,
      );
      return;
    }

    debugPrint('📤 Dispatching CreateInitialBudgetEvent with: £$sales');
    context.read<BudgetBloc>().add(
      CreateInitialBudgetEvent(lastYearSales: sales),
    );
  }

  void _saveCategories() {
    if (existingBudget == null) {
      debugPrint('❗ Tried to save but existingBudget is null');
      return;
    }

    debugPrint('💾 Saving budget with ${categories.length} categories...');
    context.read<BudgetBloc>().add(
      UpdateBudgetCategoriesEvent(
        budgetId: existingBudget!.id,
        categories: categories,
      ),
    );
    showSnackBar(
      context,
      'Success',
      'Budget created successfully!',
      ContentType.success,
    );
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
  }
}
