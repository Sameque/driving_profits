import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uber_tracker/domain/expense/dtos/expense_month_dto.dart';
import 'package:uber_tracker/domain/expense/expense_month_type.dart';
import 'package:uber_tracker/ui/feature/expenses/widget/expense_type_dropdown.dart';
import 'package:uber_tracker/ui/widget/currency_input_formatter.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';
import 'expense_viewmodel.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late ExpenseMonthDto expense;
  final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    expense = ExpenseMonthDto(type: ExpenseMonthType.none, amount: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpenseViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos Mensais')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: expense.amount == 0.0
                        ? ''
                        : expense.amount.toStringAsFixed(2),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (value) =>
                        expense.setAmount(value.replaceAll(",", ".")),
                    decoration: InputDecoration(
                      labelText: 'Valor do gasto',
                      prefixIcon: const Icon(Icons.monetization_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.1),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório.';
                      }
                      final parsed = double.tryParse(
                        value.replaceAll(',', '.').replaceAll('R\$ ', ''),
                      );
                      if (parsed == null || parsed <= 0) {
                        return 'Insira um valor válido maior que zero.';
                      }
                      return null;
                    },
                    autofocus: true,
                  ),

                  const SizedBox(height: 16),

                  ExpenseTypeDropdown(
                    value: expense.type,
                    onChanged: expense.setType,
                    labelText: 'Tipo de gasto',
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Gasto'),
                    onPressed: viewModel.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              viewModel.addExpense(expense);
                              expense = ExpenseMonthDto.empty();
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
                      itemCount: viewModel.expenses.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = viewModel.expenses[index];

                        final type = ExpenseMonthType.values.firstWhere(
                          (t) => t.value == e.type.value,
                        );

                        return Dismissible(
                          key: ValueKey(e),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirmar exclusão'),
                                  content: const Text(
                                    'Tem certeza que deseja apagar este gasto?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
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
                            await viewModel.removeExpense(e.id ?? 0);

                            CustomSnackBar.success(
                              context: context,
                              message: '${type.descricao} removido',
                            );
                          },
                          child: ListTile(
                            leading: Icon(type.icon),
                            title: Text(type.descricao),
                            trailing: Text(_formatter.format(e.amount)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (viewModel.isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
