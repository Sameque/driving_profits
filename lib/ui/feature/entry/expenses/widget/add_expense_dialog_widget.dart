import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:driving_profits/domain/entry/entry_expense/entry_expense_dto.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:driving_profits/ui/feature/expenses/widget/expense_type_dropdown.dart';
import 'package:driving_profits/ui/widget/text_field_custom.dart';

class AddExpenseDialogWidget extends StatefulWidget {
  final String entryId;
  final Function(EntryExpenseDto) onAdd;

  const AddExpenseDialogWidget({
    super.key,
    required this.entryId,
    required this.onAdd,
  });

  @override
  State<AddExpenseDialogWidget> createState() => _AddExpenseDialogWidgetState();
}

class _AddExpenseDialogWidgetState extends State<AddExpenseDialogWidget> {
  ExpenseType? selectedExpenseType;
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  late EntryExpenseDto entryExpense;

  @override
  void initState() {
    super.initState();
    entryExpense = EntryExpenseDto.notCalculated(widget.entryId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Gasto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpenseTypeDropdown(
            value: entryExpense.expenseType,
            onChanged: entryExpense.setExpenseType,
          ),

          const SizedBox(height: 16),

          TextFieldCustom(
            label: 'Valor',
            initial: entryExpense.amount.toString(),
            onChanged: entryExpense.setAmount,
          ),

          TextFieldCustom(
            label: 'Descrição',
            initial: entryExpense.description,
            onChanged: entryExpense.setDescription,
            keyboardType: TextInputType.text,
            icon: Icons.description,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Informe uma descrição.';
              }
              if (value.length > 20) {
                return 'Descrição deve ter no máximo 20 caracteres.';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (entryExpense.expenseType != ExpenseType.none &&
                entryExpense.amount > 0 &&
                entryExpense.description.isNotEmpty) {
              widget.onAdd(entryExpense);
              Future.delayed(const Duration(milliseconds: 800), () {
                Navigator.of(context).pop();
              });
            }
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
