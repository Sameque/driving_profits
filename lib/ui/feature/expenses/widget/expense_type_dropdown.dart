import 'package:flutter/material.dart';
import 'package:uber_tracker/domain/expense/expense_month_type.dart';

class ExpenseTypeDropdown extends StatelessWidget {
  final ExpenseMonthType? value;
  final void Function(ExpenseMonthType?)? onChanged;
  final String? labelText;
  final String? hintText;
  final bool isExpanded;

  const ExpenseTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ExpenseMonthType>(
      initialValue: value,
      isExpanded: isExpanded,
      decoration: InputDecoration(
        labelText: labelText ?? 'Tipo de gasto',
        hintText: hintText,
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),
      items: ExpenseMonthType.values
          .map(
            (e) => DropdownMenuItem<ExpenseMonthType>(
              value: e,
              child: Text(e.descricao),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.value == ExpenseMonthType.none.value
          ? 'Selecione o tipo de gasto.'
          : null,
    );
  }
}
