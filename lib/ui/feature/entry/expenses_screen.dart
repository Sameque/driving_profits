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

  // Controladores para os campos de texto
  late TextEditingController _fuelController;
  late TextEditingController _foodController;
  late TextEditingController _cleaningController;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());

    // Inicializa os controladores com os valores atuais
    _fuelController = TextEditingController(text: entryDto.getFuelCost);
    _foodController = TextEditingController(text: entryDto.getFoodCost);
    _cleaningController = TextEditingController(text: entryDto.getCleaningCost);
    _otherController = TextEditingController(text: entryDto.getOtherCosts);

    // Adiciona listener para atualizar a UI quando os valores mudam
    entryDto.addListener(_onEntryChanged);
  }

  @override
  void dispose() {
    _fuelController.dispose();
    _foodController.dispose();
    _cleaningController.dispose();
    _otherController.dispose();
    entryDto.removeListener(_onEntryChanged);
    super.dispose();
  }

  void _onEntryChanged() {
    setState(() {
      // Atualiza os controladores com os novos valores
      _fuelController.text = entryDto.getFuelCost;
      _foodController.text = entryDto.getFoodCost;
      _cleaningController.text = entryDto.getCleaningCost;
      _otherController.text = entryDto.getOtherCosts;
    });
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final provider = Provider.of<EntryProvider>(context, listen: false);
      final map = entryDto.toMap();
      final updated = DailyEntry.fromMap(map);

      provider.updateOpenEntry(updated);

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
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        onChanged: onChanged,
        controller: controller,
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
              label: 'Combustível (R\$)',
              controller: _fuelController,
              onChanged: entryDto.setFuelCost,
              icon: Icons.local_gas_station,
            ),
            _amountField(
              label: 'Alimentação (R\$)',
              controller: _foodController,
              onChanged: entryDto.setFoodCost,
              icon: Icons.restaurant,
            ),
            _amountField(
              label: 'Lavagem/Limpeza (R\$)',
              controller: _cleaningController,
              onChanged: entryDto.setCleaningCost,
              icon: Icons.local_laundry_service,
            ),
            _amountField(
              label: 'Outros Gastos (R\$)',
              controller: _otherController,
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
