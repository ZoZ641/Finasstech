import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Prevent formatting empty or invalid strings
    if (newValue.text.isEmpty ||
        double.tryParse(newValue.text.replaceAll(',', '')) == null) {
      return newValue;
    }

    // Remove any commas, parse the number, then re-format
    final rawText = newValue.text.replaceAll(',', '');
    final number = double.parse(rawText);

    final newText = _formatter.format(number);

    // Maintain cursor position
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
