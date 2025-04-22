import 'package:finasstech/features/dashboard/presentaion/widgets/graph_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../budgeting/presentation/bloc/budget_bloc.dart';
import '../../../budgeting/presentation/pages/create_budget_page.dart';
import '../../../expenses/presentation/pages/add_expense.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<BudgetBloc>().add(CheckForExistingBudgetData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateBudgetPage()),
          );
        } else if (state is BudgetDataExistsState && state.hasExistingData) {
          context.read<BudgetBloc>().add(GetLatestBudgetEvent());
        }
      },
      child: Scaffold(
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
            GraphWidget(title: 'Income', amount: '2,500', isGraph: false),
            GraphWidget(title: 'Expenses', amount: '1,200'),
            GraphWidget(title: 'Cash Flow', amount: '1,300'),
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
      ),
    );
  }
}
