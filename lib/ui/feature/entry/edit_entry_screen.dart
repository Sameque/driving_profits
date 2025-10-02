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

class EditEntryScreen extends StatefulWidget {
  final DailyEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  EntryDto entryDto = EntryDto();

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());
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

  Widget _buildTextField({
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
          ).colorScheme.surfaceVariant.withOpacity(0.1),
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
                      _buildTextField(
                        label: 'Repasse Uber (R\$)',
                        initial: entryDto.getUberEarnings,
                        onChanged: entryDto.setUberEarnings,
                        icon: Icons.attach_money,
                      ),
                      _buildTextField(
                        label: 'Gorjetas (R\$)',
                        initial: entryDto.getTips,
                        onChanged: entryDto.setTips,
                        icon: Icons.card_giftcard,
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
                      _buildTextField(
                        label: 'Alimentação (R\$)',
                        initial: entryDto.getFoodCost,
                        onChanged: entryDto.setFoodCost,
                        icon: Icons.restaurant,
                      ),
                      _buildTextField(
                        label: 'Limpeza (R\$)',
                        initial: entryDto.getCleaningCost,
                        onChanged: entryDto.setCleaningCost,
                        icon: Icons.wash,
                      ),
                      _buildTextField(
                        label: 'Outros Gastos (R\$)',
                        initial: entryDto.getOtherCosts,
                        onChanged: entryDto.setOtherCosts,
                        icon: Icons.more_horiz,
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
                          controller: TextEditingController(
                            text: entryDto.getKmStart,
                          ),

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
                          controller: TextEditingController(
                            text: entryDto.getKmEnd,
                          ),

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
