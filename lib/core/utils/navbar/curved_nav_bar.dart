import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:finasstech/core/theme/app_pallete.dart';

/// A custom navigation bar widget that provides a curved bottom navigation interface.
///
/// This widget:
/// - Displays a list of pages with a curved navigation bar
/// - Handles page switching through a callback function
/// - Maintains the current page state
///
/// Parameters:
/// - [pages]: The list of pages to display in the navigation
/// - [onPageChanged]: Callback function triggered when page changes
class CurvedNavBar extends StatefulWidget {
  /// List of pages to be displayed in the navigation
  final List<Widget> pages;

  /// Callback function that is called when the page changes
  final Function(int) onPageChanged;

  /// Creates a new instance of [CurvedNavBar]
  ///
  /// Parameters:
  /// - [key]: Optional widget key
  /// - [pages]: Required list of pages to display
  /// - [onPageChanged]: Required callback for page changes
  const CurvedNavBar({
    super.key,
    required this.pages,
    required this.onPageChanged,
  });

  @override
  State<CurvedNavBar> createState() => _CurvedNavBarState();
}

/// The state class for [CurvedNavBar] that manages the navigation state and UI.
///
/// This class:
/// - Maintains the current page index
/// - Handles dark mode detection
/// - Manages page switching logic
/// - Builds the curved navigation bar UI
class _CurvedNavBarState extends State<CurvedNavBar> {
  /// The index of the currently selected page
  int currentPage = 2;

  /// Determines if the app is in dark mode based on the system settings.
  ///
  /// Parameters:
  /// - [context]: The build context to access theme information
  ///
  /// Returns true if dark mode is enabled, false otherwise.
  bool isDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Updates the current page index and notifies the parent widget.
  ///
  /// Parameters:
  /// - [index]: The new page index to set
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
