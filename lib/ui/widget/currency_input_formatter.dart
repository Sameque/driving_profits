import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digits and parse as cents
    final String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final double value = double.parse(cleanText) / 100;

    // Format with pt_BR locale (comma for decimal, period for thousands)
    final formatter = NumberFormat("#,##0.00", "pt_BR");
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
