import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/models/daily_entry.dart';
import 'package:uber_tracker/providers/entry_provider.dart';
import 'package:uber_tracker/ui/feature/entry/entry_dto.dart';
import 'package:uber_tracker/ui/widget/currency_input_formatter.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';

class ExpensesScreen extends StatefulWidget {
  final DailyEntry entry;

  const ExpensesScreen({super.key, required this.entry});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  late EntryDto entryDto;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
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
    }
  }

  Widget _amountField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        onChanged: onChanged,
        controller: TextEditingController(text: initial),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lançar Gastos'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Card com informações da jornada
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jornada do dia ${entryDto.date.day}/${entryDto.date.month}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListenableBuilder(
                  listenable: entryDto,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo dos Gastos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
