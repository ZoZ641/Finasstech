enum Recurrence { none, weekly, monthly }

class Expense {
  final String id;
  final double amount;
  final DateTime date;
  final String vendor;
  final String category;
  final int recurrence; // 0 = none, 1 = weekly, 2 = monthly

  const Expense({
    required this.id,
    required this.amount,
    required this.date,
    required this.vendor,
    required this.category,
    this.recurrence = 0,
  });
}
