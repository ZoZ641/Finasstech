import 'package:finasstech/core/utils/money_formater.dart';
import 'package:finasstech/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';
import 'package:finasstech/core/services/notification_service.dart';

import '../../../budgeting/presentation/bloc/budget_bloc.dart';
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? editingExpense;
  final String? expenseId;
  final bool? isRecurring;

  const AddExpensePage({
    super.key,
    this.editingExpense,
    this.expenseId,
    this.isRecurring = false,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  DateTime? _selectedDate;
  String? _selectedCategory;
  int _selectedRecurrence = 0;

  @override
  void initState() {
    super.initState();
    //_categories = ["Food", "Transport", "Entertainment", "Sales"];
    _selectedCategory = null;
    final editing = widget.editingExpense;
    if (editing != null) {
      _amountController.text = editing.amount.toStringAsFixed(2);
      _vendorController.text = editing.vendor;
      _selectedDate = editing.date;
      _selectedCategory = editing.category;
      _selectedRecurrence = editing.recurrence;
    }
  }

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _scheduleRecurringNotification(Expense expense) async {
    // Skip if expense is not recurring
    if (expense.recurrence == 0) return;

    // Generate a unique notification ID based on the expense ID
    final notificationId = _notificationService
        .generateNotificationIdFromUuidPartial(expense.id);

    // Set notification content
    final title = 'Recurring Expense';
    final body =
        'Hey you have a recurring ${expense.category} expense of £${expense.amount.toStringAsFixed(2)} '
        'to ${expense.vendor[0] + expense.vendor.substring(1).toLowerCase()}';

    // Schedule the notification
    // For weekly (recurrence = 1): schedule 7 days from expense date
    // For monthly (recurrence = 2): schedule 30 days from expense date
    await _notificationService.showScheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      dateTime:
          expense.recurrence == 1
              ? expense.date.add(const Duration(days: 7))
              : expense.date.add(const Duration(days: 30)),
      isMonthly: expense.recurrence == 2,
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedCategory != null) {
      final expense = Expense(
        id: widget.editingExpense?.id ?? const Uuid().v4(),
        amount: double.parse(
          _amountController.text.replaceAll(',', '').replaceAll('£', '').trim(),
        ),
        date: _selectedDate!,
        vendor: _vendorController.text,
        category: _selectedCategory!,
        recurrence: _selectedRecurrence,
      );

      if (widget.editingExpense != null) {
        context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
      } else {
        context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
      }

      // Schedule notification for recurring expenses
      _scheduleRecurringNotification(expense);

      // Always recalculate budget after expense changes
      final budget = context.read<BudgetBloc>().budget;
      if (budget != null) {
        context.read<BudgetBloc>().add(
          CalculateBudgetUsageEvent(budget: budget),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingExpense != null;
    final isRecurring = widget.isRecurring ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Edit Expense" : "Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Amount Field
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [MoneyInputFormatter()],
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    hintText: '£100',
                    suffixIcon: Icon(Icons.money),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter amount" : null,
                ),
                const SizedBox(height: 20),

                // Date Picker
                TextFormField(
                  readOnly: true,
                  onTap: () => _pickDate(context),
                  decoration: const InputDecoration(
                    labelText: "Date",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text:
                        _selectedDate == null
                            ? "Select a date"
                            : "${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}"
                                .split(' ')[0],
                  ),
                ),
                const SizedBox(height: 20),

                // Vendor Field
                TextFormField(
                  controller: _vendorController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: "Vendor",
                    suffixIcon: Icon(Icons.store),
                  ),
                  validator: (value) => value!.isEmpty ? "Enter vendor" : null,
                ),
                const SizedBox(height: 20),

                // Recurring Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedRecurrence,
                  decoration: const InputDecoration(
                    labelText: "Recurring",
                    suffixIcon: Icon(Icons.repeat),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('None')),
                    DropdownMenuItem(value: 1, child: Text('Weekly')),
                    DropdownMenuItem(value: 2, child: Text('Monthly')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRecurrence = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Category Dropdown
                BlocBuilder<BudgetBloc, BudgetState>(
                  builder: (context, state) {
                    List<String> dynamicCategories = [];

                    if (state is BudgetLoaded) {
                      dynamicCategories = state.budget.categories.keys.toList();
                    } else if (state is BudgetCreated) {
                      dynamicCategories = state.budget.categories.keys.toList();
                    } else if (state is BudgetUpdated) {
                      dynamicCategories = state.budget.categories.keys.toList();
                    } else if (state is BudgetUsageCalculated) {
                      dynamicCategories = state.usageByCategory.keys.toList();
                    }

                    final allCategories =
                        {...dynamicCategories, "Sales"}.toList();

                    return DropdownButtonFormField<String>(
                      value:
                          allCategories.contains(_selectedCategory)
                              ? _selectedCategory
                              : null,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        suffixIcon: Icon(Icons.category),
                      ),
                      items:
                          allCategories
                              .toSet()
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category[0].toUpperCase() +
                                        category.substring(1),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveExpense,
                    child: Text(isEditing && !isRecurring ? "Update" : "Add"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
