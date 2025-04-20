import 'package:finasstech/features/budgeting/data/models/budget_category_model.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:hive_ce/hive.dart';

import '../features/auth/data/models/user_model.dart';
import '../features/expenses/data/models/expense_model.dart';

@GenerateAdapters([
  AdapterSpec<UserModel>(),
  AdapterSpec<BudgetModel>(),
  AdapterSpec<BudgetCategoryModel>(),
  AdapterSpec<ExpenseModel>(),
])
part 'hive_adapters.g.dart';
