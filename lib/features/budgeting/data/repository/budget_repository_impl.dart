import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/features/budgeting/domain/entities/budget.dart';
import 'package:finasstech/features/budgeting/domain/entities/budget_category.dart';
import 'package:finasstech/features/budgeting/domain/repository/budget_repository.dart';
import 'package:fpdart/src/either.dart';

import '../datasources/budget_local_data_source.dart';
import '../models/budget_category_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource hiveDataSource;

  const BudgetRepositoryImpl(this.hiveDataSource);

  @override
  Future<Either<Failure, bool>> hasExistingBudgetData() async {
    try {
      final result = await hiveDataSource.hasExistingBudgetData();
      return Right(result);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> createInitialBudget({
    required double lastYearSales,
  }) async {
    try {
      final budget = await hiveDataSource.createInitialBudget(
        lastYearSales: lastYearSales,
      );
      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> createBudgetWithProphetForecast() async {
    try {
      final budget = await hiveDataSource.createBudgetWithProphetForecast();
      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget>> updateBudgetCategories({
    required String budgetId,
    required Map<String, BudgetCategory> categories,
  }) async {
    try {
      final modelCategories = categories.map(
        (key, value) => MapEntry(key, BudgetCategoryModel.fromEntity(value)),
      );

      final budget = await hiveDataSource.updateBudgetCategories(
        budgetId: budgetId,
        categories: modelCategories,
      );

      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Budget?>> getLatestBudget() async {
    try {
      final budget = await hiveDataSource.getLatestBudget();
      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  //todo fix this method after creating expenses feature
  @override
  Future<Either<Failure, Map<String, double>>> calculateBudgetUsage({
    required Budget budget,
  }) async {
    try {
      final transactions =
          await hiveDataSource.getTransactionsHistoryForProphet();

      Map<String, double> usageByCategory = {
        for (var key in budget.categories.keys) key: 0.0,
      };

      for (var transaction in transactions) {
        final category = transaction['category'] as String?;
        final amount = transaction['amount'] as double?;

        if (category != null &&
            amount != null &&
            usageByCategory.containsKey(category)) {
          usageByCategory[category] = (usageByCategory[category] ?? 0) + amount;
        }
      }

      return Right(usageByCategory);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
