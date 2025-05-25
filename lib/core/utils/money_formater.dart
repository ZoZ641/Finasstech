import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// A custom text input formatter for handling monetary values in GBP format.
///
/// This formatter:
/// - Removes any existing currency symbols and commas
/// - Formats the input as a GBP currency value
/// - Handles empty input gracefully
/// - Maintains proper cursor position
class MoneyInputFormatter extends TextInputFormatter {
  /// The number formatter used to format currency values
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_GB', // Use British English locale
    symbol: '£', // Use GBP symbol
    decimalDigits: 0, // No decimal places by default
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove currency symbol and commas, then trim whitespace
    final cleaned = newValue.text.replaceAll(RegExp(r'[£,]'), '').trim();

    // Handle empty input case
    if (cleaned.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Try to parse the cleaned input as a number
    final number = double.tryParse(cleaned);
    if (number == null) {
      // Return original value if parsing fails
      return newValue;
    }

    // Format the number as currency
    final newText = _formatter.format(number);

    // Return formatted text with cursor at the end
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
