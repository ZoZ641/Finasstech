import 'package:hive_ce/hive.dart';

import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense with HiveObjectMixin {
  final String id;

  final double amount;

  final DateTime date;

  final String vendor;

  final String category;

  final int recurrence;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.vendor,
    required this.category,
    this.recurrence = 0,
  }) : super(
         id: id,
         amount: amount,
         date: date,
         vendor: vendor,
         category: category,
       );

  Expense toEntity() => Expense(
    id: id,
    amount: amount,
    date: date,
    vendor: vendor,
    category: category,
    recurrence: recurrence,
  );

  factory ExpenseModel.fromEntity(Expense expense) => ExpenseModel(
    id: expense.id,
    amount: expense.amount,
    date: expense.date,
    vendor: expense.vendor,
    category: expense.category,
    recurrence: expense.recurrence,
  );
}
