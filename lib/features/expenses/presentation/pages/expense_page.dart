import 'package:finasstech/features/expenses/presentation/widgets/expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';

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
                  const Center(
                    child: Text(
                      "No expenses recorded.",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

    // Week starts on Saturday (weekday 6 in Dart)
    // Find the most recent Saturday (including today if it's Saturday)
    final int daysToSubtract = now.weekday == 6 ? 0 : (now.weekday + 1) % 7;
    final thisWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysToSubtract));

    // Month starts at first day of current month
    final thisMonthStart = DateTime(now.year, now.month, 1);

    // Year starts at first day of current year
    final thisYearStart = DateTime(now.year, 1, 1);

    final Map<String, List<Expense>> result = {
      'thisWeek': [],
      'thisMonth': [],
      'thisYear': [],
      'later': [],
    };

    for (var expense in expenses) {
      if (expense.date.isAfter(thisYearStart) ||
          isSameDay(expense.date, thisYearStart)) {
        if (expense.date.isAfter(thisMonthStart) ||
            isSameDay(expense.date, thisMonthStart)) {
          if (expense.date.isAfter(thisWeekStart) ||
              isSameDay(expense.date, thisWeekStart)) {
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

    // Sort each group from newest to oldest
    result['thisWeek']!.sort((a, b) => b.date.compareTo(a.date));
    result['thisMonth']!.sort((a, b) => b.date.compareTo(a.date));
    result['thisYear']!.sort((a, b) => b.date.compareTo(a.date));
    result['later']!.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  // Helper function to check if two dates are the same day
  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
