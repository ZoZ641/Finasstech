import 'package:flutter/material.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

//TODO Make it clean architecture
class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final TextEditingController _budgetNameController = TextEditingController();
  final Map<String, double> _expenses = {
    "Salaries": 0,
    "Rent": 0,
    "Office supplies": 0,
    "Utilities": 0,
  };

  void _addExpense(String category) {
    //TODO Add logic to modify expense values
    setState(() {
      _expenses[category] = (_expenses[category] ?? 0) + 100; // Example logic
    });
  }

  void _createBudget() {
    //TODO Logic for creating a budget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Budget",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Name Input
            const Text(
              "Budget name",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _budgetNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: "New budget",
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Adjustable Expense Categories
            const Text(
              "Adjustable expense categories",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Expense List
            ..._expenses.keys.map(
              (category) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Currently \$${_expenses[category]}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () => _addExpense(category),
                      child: const Text("Add"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Create Budget Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createBudget,
                child: const Text(
                  "Create Budget",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
