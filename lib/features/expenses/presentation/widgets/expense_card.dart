import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:finasstech/features/expenses/domain/entities/expense.dart';
import 'package:finasstech/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:finasstech/features/expenses/presentation/pages/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  const ExpenseCard({super.key, required this.expense});

  void _editExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpensePage(editingExpense: expense),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppPallete.errorColor,
                ),
                onPressed: () {
                  context.read<ExpenseBloc>().add(
                    DeleteExpenseEvent(expense.id),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppPallete.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        _confirmDelete(context);
        return false;
      },
      child: Card(
        elevation: 2,
        child: ListTile(
          onTap: () => _editExpense(context),
          leading: const Icon(Icons.currency_pound_sharp),
          title: Text(
            "£${expense.amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  expense.amount < 0
                      ? AppPallete.errorColor
                      : AppPallete.primaryColor,
            ),
          ),
          subtitle: Text(
            expense.category[0].toUpperCase() + expense.category.substring(1),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('dd-MM-yyyy').format(expense.date),
                style: const TextStyle(fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min, // Important to wrap content
                children: [
                  if (expense.recurrence > 0)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppPallete.primaryColor.withAlpha(230),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: 16.0),
                          Text(
                            expense.recurrence == 1 ? 'Weekly' : 'Monthly',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                    child: Text(
                      expense.vendor[0].toUpperCase() +
                          expense.vendor.substring(1),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
