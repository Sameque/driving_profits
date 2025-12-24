import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/ui/feature/expenses/widget/charge_type_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:driving_profits/ui/feature/expenses/widget/expense_type_dropdown.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';
import 'expense_viewmodel.dart';

class ExpenseAddScreen extends StatefulWidget {
  const ExpenseAddScreen({super.key});

  @override
  State<ExpenseAddScreen> createState() => _ExpenseAddScreenState();
}

class _ExpenseAddScreenState extends State<ExpenseAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final viewmodel = injector.get<ExpenseViewModel>();

  final expense = ExpenseDto.empty();

  @override
  void initState() {
    super.initState();
    viewmodel.addCommand.addListener(_listenerAdd);
  }

  void _listenerAdd() {
    if (viewmodel.addCommand.value.isRunning) return;

    if (viewmodel.addCommand.value.isSuccess) {
      if (mounted) {
        CustomSnackBar.success(
          context: context,
          message: 'Gasto adicionado com sucesso',
        );
        Navigator.pop(context);
      }
    }

    if (viewmodel.addCommand.value.isFailure) {
      final failure = viewmodel.addCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message:
              "Erro ao adicionar registro:\n - ${failure.error.toString()}",
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.number,
    bool isCurrency = true,
  }) {
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
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) return null;
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed == null || parsed < 0) {
                return 'Insira um valor válido.';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListenableBuilder(
            listenable: expense,
            builder: (context, _) {
              return Column(
                children: [
                  ExpenseTypeDropdown(
                    value: expense.expenseType,
                    onChanged: expense.setExpenseType,
                  ),

                  const SizedBox(height: 16),

                  ChargeTypeDropdown(
                    value: expense.chargeType,
                    onChanged: expense.setChargeType,
                  ),

                  const SizedBox(height: 16),
                  if (expense.expenseType != ExpenseType.other)
                    _buildTextField(
                      label: 'Descrição',
                      initial: expense.description,
                      inputFormatters: [LengthLimitingTextInputFormatter(20)],
                      icon: Icons.description,
                      onChanged: expense.setDescription,
                      keyboardType: TextInputType.text,
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
                  const SizedBox(height: 24),

                  if (expense.chargeType == ChargeType.fixedMonthly ||
                      expense.chargeType == ChargeType.fixedDaily ||
                      expense.chargeType == ChargeType.valuePerKm)
                    _buildTextField(
                      label: 'Valor',
                      initial: expense.strAmount,
                      icon: Icons.attach_money,
                      onChanged: expense.setAmount,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o valor do gasto.';
                        }
                        final amount = double.tryParse(
                          value.replaceAll(RegExp(r'[^0-9]'), ''),
                        );
                        if (amount == null || amount <= 0) {
                          return 'Informe um valor válido.';
                        }
                        return null;
                      },
                    ),

                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Gasto'),
                    onPressed: viewmodel.addCommand.value.isRunning
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              viewmodel.addCommand.execute(expense);
                            }
                          },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
