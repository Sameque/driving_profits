import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:driving_profits/models/daily_entry.dart';
import 'package:driving_profits/providers/entry_provider.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';

class ExpensesScreen extends StatefulWidget {
  final DailyEntry entry;

  const ExpensesScreen({super.key, required this.entry});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  late EntryDto entryDto;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);

      final provider = Provider.of<EntryProvider>(context, listen: false);
      final map = entryDto.toMap();
      final updated = DailyEntry.fromMap(map);

      provider.updateEntry(updated);

      CustomSnackBar.success(
        context: context,
        message: 'Gastos atualizados com sucesso!',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: 'Erro ao salvar gastos: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      appBar: AppBar(
        title: const Text('Lançar Gastos'),
        centerTitle:
            false, // Alinha o título à esquerda para melhor legibilidade
        elevation: 0, // Visual mais moderno e flat
        scrolledUnderElevation: 4, // Elevação sutil ao scrollar
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface, // Integra com o tema
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onSurface, // Garante contraste
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ), // Borda inferior sutil para separação
      ),
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
                          'Jornada do dia ${entryDto.date.day}/${entryDto.date.month}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('KM Inicial: ${entryDto.getKmStart}'),
                        if (entryDto.getKmEnd.isNotEmpty)
                          Text('KM Final: ${entryDto.getKmEnd}'),
                        if (entryDto.startTime != null)
                          Text(
                            'Hora Inicial: ${entryDto.startTime!.format(context)}',
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campos de gastos
                _amountField(
                  label: 'Alimentação (R\$)',
                  initial: entryDto.getFoodCost,
                  onChanged: entryDto.setFoodCost,
                  icon: Icons.restaurant,
                ),
                _amountField(
                  label: 'Lavagem/Limpeza (R\$)',
                  initial: entryDto.getCleaningCost,
                  onChanged: entryDto.setCleaningCost,
                  icon: Icons.local_laundry_service,
                ),
                _amountField(
                  label: 'Outros Gastos (R\$)',
                  initial: entryDto.getOtherCosts,
                  onChanged: entryDto.setOtherCosts,
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
                      listenable: entryDto,
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
                              'Total de Gastos: R\$ ${entryDto.totalCosts.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ganhos: R\$ ${entryDto.totalEarnings.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lucro Líquido: R\$ ${entryDto.netEarnings.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: entryDto.netEarnings >= 0
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
                  onPressed: _isLoading ? null : _save,
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
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
