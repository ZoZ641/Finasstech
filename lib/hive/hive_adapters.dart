import 'package:finasstech/features/budgeting/data/models/budget_category_model.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/common/entities/user.dart';

@GenerateAdapters([
  AdapterSpec<User>(),
  AdapterSpec<BudgetModel>(),
  AdapterSpec<BudgetCategoryModel>(),
])
part 'hive_adapters.g.dart';
