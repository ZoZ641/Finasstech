import 'package:finasstech/core/error/failures.dart';
import 'package:finasstech/features/budgeting/data/models/budget_model.dart';
import 'package:finasstech/features/budgeting/domain/repository/budget_repository.dart';
import 'package:fpdart/src/either.dart';

import '../../domain/entities/budget.dart';
import '../../domain/entities/budget_category.dart';
import '../datasources/budget_local_data_source.dart';
import '../models/budget_category_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  //todo: rename hiveDataSource to localDataSource
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
  Future<Either<Failure, BudgetModel>> createInitialBudget({
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
  Future<Either<Failure, BudgetModel>> createBudgetWithProphetForecast() async {
    try {
      final budget = await hiveDataSource.createBudgetWithProphetForecast();
      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BudgetModel>> updateBudgetCategories({
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
  Future<Either<Failure, BudgetModel?>> getLatestBudget() async {
    try {
      final budget = await hiveDataSource.getLatestBudget();
      return Right(budget);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> calculateBudgetUsage({
    required Budget budget,
  }) async {
    try {
      await hiveDataSource.calculateBudgetUsageFromExpenses();
      return right(null);
    } catch (e) {
      return left(Failure('Failed to calculate usage: $e'));
    }
  }
}
