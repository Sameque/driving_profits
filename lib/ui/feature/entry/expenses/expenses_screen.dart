import 'dart:developer';

import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/ui/feature/entry/expenses/expenses_viewmodel.dart';
import 'package:driving_profits/ui/widget/app_bar_screen_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';

class ExpensesScreen extends StatefulWidget {
  final EntryDto entryDto;
  final Function(EntryDto)? onSave;

  const ExpensesScreen({super.key, required this.entryDto, this.onSave});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final viewmodel = injector.get<ExpensesViewmodel>();

  @override
  void initState() {
    super.initState();
    viewmodel.updateCommand.addListener(_listanable);
  }

  void _listanable() {
    if (viewmodel.updateCommand.value.isRunning) return;

    if (viewmodel.updateCommand.value.isFailure) {
      final failure = viewmodel.updateCommand.value as FailureCommand<Object>;

      CustomSnackBar.error(
        context: context,
        message: "Erro ao salvar:\n - ${failure.error.toString()}",
      );
      return;
    }

    if (viewmodel.updateCommand.value.isSuccess) {
      CustomSnackBar.success(
        context: context,
        message: 'Gastos atualizados com sucesso!',
      );
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    await viewmodel.updateCommand.execute(widget.entryDto);

    if (viewmodel.updateCommand.value.isFailure) return;

    try {
      widget.onSave?.call(widget.entryDto);
    } catch (e) {
      log('Erro ao chamar onSave', error: e);
    }

    //TODO: millisecondsClosedScreen em arquivo de configuração, statico
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) Navigator.of(context).pop();
  }

  Widget _amountField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],

        validator: (value) {
          if (value == null || value.isEmpty) {
            return null;
          }
          final parsed = double.tryParse(
            value.replaceAll(',', '.').replaceAll('R\$ ', ''),
          );
          if (parsed == null || parsed < 0) {
            return 'Insira um valor válido maior ou igual a zero.';
          }
          return null;
        },
        autofocus: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarScreenForm(screenTitle: 'Lançar Gastos'),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Card com informações da jornada
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jornada do dia ${widget.entryDto.date.day}/${widget.entryDto.date.month}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('KM Inicial: ${widget.entryDto.getKmStart}'),
                        if (widget.entryDto.getKmEnd.isNotEmpty)
                          Text('KM Final: ${widget.entryDto.getKmEnd}'),
                        if (widget.entryDto.startTime != null)
                          Text(
                            'Hora Inicial: ${widget.entryDto.startTime!.format(context)}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campos de gastos
                _amountField(
                  label: 'Alimentação (R\$)',
                  initial: widget.entryDto.getFoodCost,
                  onChanged: widget.entryDto.setFoodCost,
                  icon: Icons.restaurant,
                ),
                _amountField(
                  label: 'Lavagem/Limpeza (R\$)',
                  initial: widget.entryDto.getCleaningCost,
                  onChanged: widget.entryDto.setCleaningCost,
                  icon: Icons.local_laundry_service,
                ),
                _amountField(
                  label: 'Outros Gastos (R\$)',
                  initial: widget.entryDto.getOtherCosts,
                  onChanged: widget.entryDto.setOtherCosts,
                  icon: Icons.more_horiz,
                ),

                // Resumo dos gastos
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListenableBuilder(
                      listenable: widget.entryDto,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumo dos Gastos',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total de Gastos: R\$ ${widget.entryDto.totalCosts.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ganhos: R\$ ${widget.entryDto.totalEarnings.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lucro Líquido: R\$ ${widget.entryDto.netEarnings.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.entryDto.netEarnings >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Botão principal para salvar
                FilledButton(
                  onPressed: viewmodel.updateCommand.value.isRunning
                      ? null
                      : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Salvar Gastos'),
                ),
              ],
            ),
          ),
          if (viewmodel.updateCommand.value.isRunning)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
