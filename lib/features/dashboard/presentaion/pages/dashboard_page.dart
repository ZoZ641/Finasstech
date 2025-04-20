import 'package:finasstech/features/budgeting/presentation/pages/create_budget_page.dart';
import 'package:finasstech/features/dashboard/presentaion/widgets/graph_widget.dart';
import 'package:flutter/material.dart';

import '../../../expenses/presentation/pages/add_expense.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpensePage()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: ListView(
        children: [
          GraphWidget(
            title: 'Income',
            amount: '2,500',
            duration: 'This week',
            isGraph: false,
          ),
          GraphWidget(
            title: 'Expenses',
            duration: 'This week',
            amount: '1,200',
          ),
          GraphWidget(
            title: 'Cash Flow',
            duration: 'This week',
            amount: '1,300',
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Divider(thickness: 2, color: Color(0xFF3f5043)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Budget Watch',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
