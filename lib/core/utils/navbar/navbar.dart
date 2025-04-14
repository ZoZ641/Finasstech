import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final List<Widget> pages;
  final Function(int) onPageChanged; // Callback function

  const Navbar({super.key, required this.pages, required this.onPageChanged});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentPage = 2;

  void setPage(int index) {
    setState(() {
      currentPage = index;
    });
    widget.onPageChanged(index); // Notify parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[currentPage],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPage,
        onDestinationSelected: setPage,
        destinations: [
          tab(icon: Icons.card_membership, label: 'Transactions'),
          tab(icon: Icons.money_rounded, label: 'Budget'),
          tab(icon: Icons.home, label: 'Home'),
          tab(icon: Icons.auto_graph, label: 'AI Insights'),
          tab(icon: Icons.settings, label: 'Settings'),
        ],
      ),
    );
  }
}

NavigationDestination tab({required IconData icon, required String label}) =>
    NavigationDestination(icon: Icon(icon), label: label);
