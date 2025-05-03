import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:finasstech/core/theme/app_pallete.dart';

class CurvedNavBar extends StatefulWidget {
  final List<Widget> pages;
  final Function(int) onPageChanged;

  const CurvedNavBar({
    super.key,
    required this.pages,
    required this.onPageChanged,
  });

  @override
  State<CurvedNavBar> createState() => _CurvedNavBarState();
}

class _CurvedNavBarState extends State<CurvedNavBar> {
  int currentPage = 2;
  bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  void setPage(int index) {
    setState(() {
      currentPage = index;
    });
    widget.onPageChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode(context)
              ? AppPallete.darkBackgroundColorgal
              : AppPallete.lightBackgroundColorchat,
      body: widget.pages[currentPage],
      bottomNavigationBar: CurvedNavigationBar(
        index: currentPage,
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor:
            isDarkMode(context)
                ? AppPallete.darkBackgroundColorgal
                : AppPallete.lightBackgroundColorchat,
        buttonBackgroundColor: AppPallete.primaryColor,
        color:
            isDarkMode(context) ? AppPallete.darkNavbarColor : Colors.blueGrey,
        onTap: setPage,
        items: [
          Icon(Icons.card_membership),
          Icon(Icons.money_rounded),
          Icon(Icons.home),
          Icon(Icons.auto_graph),
          Icon(Icons.settings),
        ],
      ),
    );
  }
}
