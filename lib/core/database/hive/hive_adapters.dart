import 'package:finasstech/features/budgeting/data/models/budget_category_model.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:hive_ce/hive.dart';

import '../../../features/auth/data/models/user_model.dart';
import '../../../features/expenses/data/models/expense_model.dart';

/// Generates Hive adapters for the specified model classes.
///
/// This annotation is used to generate Hive type adapters for the following models:
/// - [UserModel]: For user authentication and profile data
/// - [BudgetModel]: For storing budget information
/// - [BudgetCategoryModel]: For categorizing budget items
/// - [ExpenseModel]: For tracking financial expenses
@GenerateAdapters([
  AdapterSpec<UserModel>(),
  AdapterSpec<BudgetModel>(),
  AdapterSpec<BudgetCategoryModel>(),
  AdapterSpec<ExpenseModel>(),
])
part 'hive_adapters.g.dart';
