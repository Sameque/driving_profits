import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:flutter/material.dart';

class ChargeTypeDropdown extends StatelessWidget {
  final ChargeType? value;
  final void Function(ChargeType?)? onChanged;
  final String? labelText;
  final String? hintText;
  final bool isExpanded;

  const ChargeTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = ChargeType.values
        .map(
          (e) =>
              DropdownMenuItem<ChargeType>(value: e, child: Text(e.descricao)),
        )
        .where((item) => item.value != ChargeType.none)
        .toList();

    items.sort((a, b) => a.value!.descricao.compareTo(b.value!.descricao));

    items.insert(
      0,
      DropdownMenuItem<ChargeType>(
        value: ChargeType.none,
        child: Text(ChargeType.none.descricao),
      ),
    );
    return DropdownButtonFormField<ChargeType>(
      initialValue: value,
      isExpanded: isExpanded,
      decoration: InputDecoration(
        labelText: labelText ?? 'Tipo Cobrança',
        hintText: hintText,
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),
      items: items,
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.value == ChargeType.none.value
          ? 'Selecione o tipo de gasto.'
          : null,
    );
  }
}
