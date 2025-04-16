import 'package:finasstech/features/budgeting/domain/entities/budget.dart';
import 'package:finasstech/features/budgeting/domain/entities/budget_category.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/common/entities/user.dart';

@GenerateAdapters([
  AdapterSpec<User>(),
  AdapterSpec<Budget>(),
  AdapterSpec<BudgetCategory>(),
])
part 'hive_adapters.g.dart';
