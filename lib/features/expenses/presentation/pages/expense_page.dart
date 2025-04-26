import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import 'add_expense.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenses")),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            final grouped = _groupExpenses(state.expenses);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (grouped['thisWeek']!.isNotEmpty)
                  _buildSection("This Week", grouped['thisWeek']!),
                if (grouped['thisMonth']!.isNotEmpty)
                  _buildSection("This Month", grouped['thisMonth']!),
                if (grouped['thisYear']!.isNotEmpty)
                  _buildSection("This Year", grouped['thisYear']!),
                if (grouped['later']!.isNotEmpty)
                  _buildSection("Later", grouped['later']!),
                if (grouped.values.every((list) => list.isEmpty))
                  const Center(child: Text("No expenses recorded.")),
              ],
            );
          } else if (state is ExpenseFailure) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Expense> expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...expenses.map((e) => ExpenseCard(expense: e)).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Map<String, List<Expense>> _groupExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month);
    final thisYearStart = DateTime(now.year);

    final Map<String, List<Expense>> result = {
      'thisWeek': [],
      'thisMonth': [],
      'thisYear': [],
      'later': [],
    };

    for (var expense in expenses) {
      if (expense.date.isAfter(thisYearStart)) {
        if (expense.date.isAfter(thisMonthStart)) {
          if (expense.date.isAfter(thisWeekStart)) {
            result['thisWeek']!.add(expense);
          } else {
            result['thisMonth']!.add(expense);
          }
        } else {
          result['thisYear']!.add(expense);
        }
      } else {
        result['later']!.add(expense);
      }
    }

    return result;
  }
}

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
        color: Colors.red,
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
              color: expense.amount < 0 ? Colors.red : AppPallete.primaryColor,
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
                  //TODO: decide if you still want this
                  /* if (expense.recurrence > 0)
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
                    ),*/
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
