import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/ui/feature/expenses/widget/charge_type_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:driving_profits/ui/feature/expenses/widget/expense_type_dropdown.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';
import 'expense_viewmodel.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final viewmodel = injector.get<ExpenseViewModel>();

  final expense = ExpenseDto.empty();

  final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    viewmodel.addCommand.addListener(_listenerAdd);
    viewmodel.removeCommand.addListener(_listenerRemove);
    viewmodel.loadCommand.addListener(_listenerLoad);

    viewmodel.loadCommand.execute();
  }

  void _listenerRemove() {
    if (viewmodel.removeCommand.value.isRunning) return;

    if (viewmodel.removeCommand.value.isSuccess) {
      if (mounted) {
        CustomSnackBar.success(
          context: context,
          message: 'Gasto removido com sucesso',
        );
      }
    }

    if (viewmodel.removeCommand.value.isFailure) {
      final failure = viewmodel.removeCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          //TODO: colocar o texto em um arquivo de localização
          message:
              "Erro ao adicionar registro:\n - ${failure.error.toString()}",
        );
      }
    }
  }

  void _listenerLoad() {
    if (viewmodel.loadCommand.value.isFailure) {
      final failure = viewmodel.loadCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          //TODO: colocar o texto em um arquivo de localização
          message:
              "Erro ao consultar registros:\n - ${failure.error.toString()}",
        );
      }
    }
  }

  void _listenerAdd() {
    if (viewmodel.addCommand.value.isFailure) {
      final failure = viewmodel.addCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          //TODO: colocar o texto em um arquivo de localização
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
        //TODO: criar um validator
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
      appBar: AppBar(title: const Text('Gastos Mensais')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListenableBuilder(
                listenable: viewmodel.loadCommand,
                builder: (context, _) {
                  if (viewmodel.loadCommand.value.isRunning) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (viewmodel.loadCommand.value.isFailure) {
                    return Center(
                      child: Text(
                        'Erro ao carregar gastos: ${viewmodel.loadCommand.value}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return ListenableBuilder(
                    listenable: expense,
                    builder: (context, _) {
                      return Column(
                        children: [
                          const SizedBox(height: 16),

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
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(20),
                              ],
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
                          const Divider(height: 32),
                          Expanded(
                            child: ListView.separated(
                              itemCount: viewmodel.expenses.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final expense = viewmodel.expenses[index];

                                return Dismissible(
                                  key: ValueKey(expense),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    return await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                            'Confirmar exclusão',
                                          ),
                                          content: const Text(
                                            'Tem certeza que deseja apagar este gasto?',
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('Apagar'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onDismissed: (direction) async {
                                    await viewmodel.removeCommand.execute(
                                      expense.id ?? 0,
                                    );
                                  },
                                  child: ListTile(
                                    leading: Icon(expense.expenseType.icon),
                                    title: Text(expense.expenseType.descricao),
                                    subtitle: Text(expense.description),
                                    trailing: Text(
                                      _formatter.format(expense.amount),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
