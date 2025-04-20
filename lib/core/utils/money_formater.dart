import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_GB',
    symbol: '£',
    decimalDigits: 0, // Change to 2 if needed
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(RegExp(r'[£,]'), '').trim();

    if (cleaned.isEmpty) {
      // No numbers left, return empty string (removes £)
      return TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = double.tryParse(cleaned);
    if (number == null) {
      return newValue;
    }

    final newText = _formatter.format(number);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
