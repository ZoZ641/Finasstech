import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // function the stores the border properties for the input field
  static _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color),
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );
  /* Dark mode Theme */
  static final ThemeData darkThemeMode = ThemeData.dark().copyWith(
    /* colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppPallete.primaryColor,
      onPrimary: Colors.white,
      secondary: AppPallete.secondryColor,
      onSecondary: Colors.white,
      error: AppPallete.errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: AppPallete.primaryColor,
    ),*/
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.white,
      selectionHandleColor: AppPallete.primaryColor,
    ),
    scaffoldBackgroundColor: AppPallete.darkBackgroundColorgal,
    primaryColor: AppPallete.primaryColor,
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 20,
      backgroundColor: AppPallete.darkBackgroundColorgal,
      surfaceTintColor: AppPallete.darkNavbarColor,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 25,
        letterSpacing: 2,
      ),
      actionsIconTheme: IconThemeData(color: AppPallete.primaryColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppPallete.darkInputFieldColor,
      suffixIconColor: AppPallete.primaryColor,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 18),
      filled: true,
      border: _border(Color(0xFF3f5043)),
      hintStyle: const TextStyle(color: Color(0xFFa1b5a5)),
      activeIndicatorBorder: const BorderSide(color: AppPallete.primaryColor),
      focusedBorder: _border(AppPallete.primaryColor),
      enabledBorder: _border(Color(0xFF3f5043)),
      errorBorder: _border(AppPallete.inputFieldErrorColor),
      focusedErrorBorder: _border(AppPallete.inputFieldErrorColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Color(0xFF3f5043),
        disabledForegroundColor: Color(0xFFa1b5a5),
        textStyle: const TextStyle(fontSize: 18),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPallete.primaryColor,
        textStyle: const TextStyle(fontSize: 18),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppPallete.darkInputFieldColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Color(0xFF3f5043),
        disabledForegroundColor: Color(0xFFa1b5a5),
        side: BorderSide(color: Color(0xFF3f5043)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPallete.darkNavbarColor,
      indicatorColor: AppPallete.primaryColor.withAlpha(150),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppPallete.primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: AppPallete.darkBackgroundColorgal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFF3f5043)),
      ),
      margin: EdgeInsets.all(8),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppPallete.darkBackgroundColorgal,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: AppPallete.primaryColor),
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelStyle: TextStyle(color: AppPallete.primaryColor),
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppPallete.darkBackgroundColorgal,
      confirmButtonStyle: TextButton.styleFrom(),
      cancelButtonStyle: TextButton.styleFrom(),
    ),
    listTileTheme: ListTileThemeData(
      leadingAndTrailingTextStyle: TextStyle(color: Colors.white),
      iconColor: Colors.white,
      subtitleTextStyle: TextStyle(color: Colors.white70),
    ),
  );

  /* Light mode Theme */
  static final ThemeData lightThemeMode = ThemeData.light().copyWith(
    /* colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppPallete.primaryColor,
      onPrimary: Colors.white,
      secondary: AppPallete.secondryColor,
      onSecondary: Colors.white,
      error: AppPallete.errorColor,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: AppPallete.primaryColor,
    ),*/
    scaffoldBackgroundColor: AppPallete.lightBackgroundColorchat,
    primaryColor: AppPallete.primaryColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.lightBackgroundColorchat,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppPallete.lightInputFieldColor,
      filled: true,
      border: _border(Color(0xFFdde4de)),
      hintStyle: const TextStyle(color: Color(0xFF67836e)),
      errorStyle: const TextStyle(color: AppPallete.inputFieldErrorColor),
      activeIndicatorBorder: const BorderSide(color: AppPallete.primaryColor),
      focusedBorder: _border(AppPallete.primaryColor),
      enabledBorder: _border(Color(0xFFdde4de)),
      errorBorder: _border(AppPallete.inputFieldErrorColor),
      focusedErrorBorder: _border(AppPallete.inputFieldErrorColor),
    ),
    /* Elevated button theme Style */
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Color(0xFFdde4de),
        disabledForegroundColor: Color(0xFF67836e),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        backgroundColor: AppPallete.lightInputFieldColor,
        foregroundColor: Color(0xFF67836e),
        disabledBackgroundColor: Color(0xFF3f5043),
        disabledForegroundColor: Color(0xFFa1b5a5),
        side: BorderSide(color: Color(0xFFdde4de)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppPallete.lightBackgroundColorchat,
      indicatorColor: AppPallete.primaryColor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppPallete.primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: AppPallete.lightBackgroundColorchat,
      margin: EdgeInsets.all(8),
    ),
  );
}
