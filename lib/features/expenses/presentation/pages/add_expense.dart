import 'package:flutter/material.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedAccount;
  String? _selectedCategory;

  final List<String> _accounts = ["Cash", "Bank", "Credit Card"];
  final List<String> _categories = ["Food", "Transport", "Entertainment"];

  void _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _addAccount() {
    // Future: Add account functionality
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Account Name'),
            content: TextField(),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      // Save expense logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  hintText: '£100',
                  suffixIcon: Icon(Icons.money),
                ),
                validator: (value) => value!.isEmpty ? "Enter amount" : null,
              ),

              const SizedBox(height: 30),

              // Date Picker
              TextFormField(
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: InputDecoration(
                  labelText: "Date",
                  suffixIcon: Icon(Icons.calendar_today),
                ),

                controller: TextEditingController(
                  text:
                      _selectedDate == null
                          ? "Select a date"
                          : "${_selectedDate!.toLocal()}".split(' ')[0],
                ),
              ),

              const SizedBox(height: 30),

              // Account Dropdown
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                decoration: const InputDecoration(
                  labelText: "Account",
                  suffixIcon: Icon(Icons.credit_card),
                ),
                items:
                    _accounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account,
                            child: Text(account),
                          ),
                        )
                        .toList()
                      ..add(
                        DropdownMenuItem(
                          value: "Add Account",
                          child: Text("➕ Add Account"),
                          onTap: () => _addAccount,
                        ),
                      ),
                onChanged: (value) {
                  if (value == "Add Account") {
                    _addAccount();
                  } else {
                    setState(() {
                      _selectedAccount = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 30),

              // Vendor Field
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: "Vendor",
                  suffixIcon: Icon(Icons.villa),
                ),
                validator: (value) => value!.isEmpty ? "Enter vendor" : null,
              ),

              const SizedBox(height: 30),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  suffixIcon: Icon(Icons.sell_outlined),
                ),
                items:
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: const Text("Add"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
