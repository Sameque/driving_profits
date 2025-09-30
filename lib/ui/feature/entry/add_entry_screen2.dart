import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uber_tracker/l10n/app_localizations.dart';
import 'package:uber_tracker/models/daily_entry.dart';
import 'package:uber_tracker/providers/entry_provider.dart';
import 'package:uber_tracker/ui/feature/entry/entry_dto.dart';
import 'package:uber_tracker/ui/widget/currency_input_formatter.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';

class AddEntryScreen extends StatefulWidget {
  final DailyEntry entry;

  const AddEntryScreen({super.key, required this.entry});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  EntryDto entryDto = EntryDto();

  // Controladores para os campos de texto
  late TextEditingController _uberEarningsController;
  late TextEditingController _tipsController;
  late TextEditingController _fuelCostController;
  late TextEditingController _foodCostController;
  late TextEditingController _cleaningCostController;
  late TextEditingController _otherCostsController;
  late TextEditingController _kmStartController;
  late TextEditingController _kmEndController;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());

    _uberEarningsController = TextEditingController(
      text: entryDto.getUberEarnings,
    );
    _tipsController = TextEditingController(text: entryDto.getTips);
    _fuelCostController = TextEditingController(text: entryDto.getFuelCost);
    _foodCostController = TextEditingController(text: entryDto.getFoodCost);
    _cleaningCostController = TextEditingController(
      text: entryDto.getCleaningCost,
    );
    _otherCostsController = TextEditingController(text: entryDto.getOtherCosts);
    _kmStartController = TextEditingController(text: entryDto.getKmStart);
    _kmEndController = TextEditingController(text: entryDto.getKmEnd);

    entryDto.addListener(_onEntryChanged);
  }

  @override
  void dispose() {
    _uberEarningsController.dispose();
    _tipsController.dispose();
    _fuelCostController.dispose();
    _foodCostController.dispose();
    _cleaningCostController.dispose();
    _otherCostsController.dispose();
    _kmStartController.dispose();
    _kmEndController.dispose();
    entryDto.removeListener(_onEntryChanged);
    super.dispose();
  }

  void _onEntryChanged() {
    setState(() {
      _uberEarningsController.text = entryDto.getUberEarnings;
      _tipsController.text = entryDto.getTips;
      _fuelCostController.text = entryDto.getFuelCost;
      _foodCostController.text = entryDto.getFoodCost;
      _cleaningCostController.text = entryDto.getCleaningCost;
      _otherCostsController.text = entryDto.getOtherCosts;
      _kmStartController.text = entryDto.getKmStart;
      _kmEndController.text = entryDto.getKmEnd;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entryDto.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != entryDto.date) {
      setState(() {
        entryDto.date = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        entryDto.setStartTime(picked);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        entryDto.setEndTime(picked);
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final provider = Provider.of<EntryProvider>(context, listen: false);

      final data = DailyEntry.fromMap(entryDto.toMap());

      provider.updateEntry(data);

      CustomSnackBar.success(
        context: context,
        message: 'Jornada atualizada com sucesso!',
      );

      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: 'Erro ao salvar: ${e.toString()}',
      );
    }
  }

  Widget _buildTextFieldForAmount(
    String label,
    String key,
    IconData icon,
    ValueChanged<String>? onChanged,
    TextEditingController controller,
  ) {
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
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return WillPopScope(
      onWillPop: () async {
        if (true) {
          return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Descartar alterações?'),
                  content: Text(
                    'Você tem alterações não salvas. Deseja descartá-las?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Descartar'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
        // return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar Lançamento'),
          actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // CARD DE DATA
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Data: ${DateFormat('dd/MM/yyyy').format(entryDto.date)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton.icon(
                            icon: Icon(Icons.calendar_today),
                            label: Text('Alterar'),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // CARD DE GANHOS
                  ExpansionTile(
                    title: Text(
                      'Ganhos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: [
                      _buildTextFieldForAmount(
                        'Repasse Uber (R\$)',
                        'uberEarnings',
                        Icons.attach_money,
                        entryDto.setUberEarnings,
                        _uberEarningsController,
                      ),
                      _buildTextFieldForAmount(
                        'Gorjetas (R\$)',
                        'tips',
                        Icons.card_giftcard,
                        entryDto.setTips,
                        _tipsController,
                      ),
                    ],
                  ),

                  // CARD DE GASTOS
                  ExpansionTile(
                    title: Text(
                      'Gastos do Dia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    children: [
                      _buildTextFieldForAmount(
                        'Combustível (R\$)',
                        'fuelCost',
                        Icons.local_gas_station,
                        entryDto.setFuelCost,
                        _fuelCostController,
                      ),
                      _buildTextFieldForAmount(
                        'Alimentação (R\$)',
                        'foodCost',
                        Icons.restaurant,
                        entryDto.setFoodCost,
                        _foodCostController,
                      ),
                      _buildTextFieldForAmount(
                        'Limpeza (R\$)',
                        'cleaningCost',
                        Icons.wash,
                        entryDto.setCleaningCost,
                        _cleaningCostController,
                      ),
                      _buildTextFieldForAmount(
                        'Outros Gastos (R\$)',
                        'otherCosts',
                        Icons.more_horiz,
                        entryDto.setOtherCosts,
                        _otherCostsController,
                      ),
                    ],
                  ),

                  // CARD DE MÉTRICAS
                  ExpansionTile(
                    title: Text(
                      'Métricas de Trabalho',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextFormField(
                          onChanged: entryDto.setKmStart,
                          controller: _kmStartController,

                          decoration: InputDecoration(
                            labelText: 'Quilometragem Inicial (km)',
                            prefixIcon: Icon(Icons.directions_car),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: TextFormField(
                          onChanged: entryDto.setKmEnd,
                          controller: _kmEndController,
                          decoration: InputDecoration(
                            labelText: 'Quilometragem Final (km)',
                            prefixIcon: Icon(Icons.directions_car),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Hora Inicial: ${entryDto.startTime?.format(context) ?? 'Não definida'}',
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: _selectStartTime,
                      ),
                      ListTile(
                        title: Text(
                          entryDto.endTime == null
                              ? 'Hora Final: Não definida'
                              : 'Hora Final: ${entryDto.endTime!.format(context)}',
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: _selectEndTime,
                      ),
                      ListTile(
                        title: Text('KM Rodados (calculado)'),
                        trailing: Text(entryDto.totalKm.toString()),
                      ),
                      ListTile(
                        title: Text('Horas Trabalhadas (calculado)'),
                        trailing: Text(
                          entryDto.totalHoursWorked
                                  ?.format(context)
                                  .toString() ??
                              '',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: entryDto,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.dailyProfit,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      currencyFormat.format(entryDto.netEarnings),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: entryDto.netEarnings >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
