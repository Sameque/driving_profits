import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCustom extends StatelessWidget {
  const TextFieldCustom({
    super.key,
    this.validator,
    this.inputFormatters,
    this.isCurrency = true,
    this.autofocus = false,
    this.icon = Icons.attach_money,
    this.keyboardType = TextInputType.number,
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool isCurrency;
  final bool autofocus;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        onChanged: onChanged,
        controller: TextEditingController(text: initial),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        ),
        keyboardType: keyboardType,
        inputFormatters:
            inputFormatters ??
            (isCurrency
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ]
                : [FilteringTextInputFormatter.digitsOnly]),
        //TODO: criar um validator
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) return null;
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed == null || parsed < 0) {
                return 'Insira um valor válido maior ou igual a zero.';
              }
              return null;
            },
      ),
    );
  }
}
