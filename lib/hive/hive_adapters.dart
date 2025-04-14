import 'package:hive_ce/hive.dart';

import '../../../../core/common/entities/user.dart';

@GenerateAdapters([AdapterSpec<User>()])
part 'hive_adapters.g.dart';
