import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:uber_tracker/l10n/app_localizations.dart';
import '../models/daily_entry.dart';
import '../providers/entry_provider.dart';

class AddEntryScreen extends StatefulWidget {
  final DailyEntry? entry;

  const AddEntryScreen({super.key, this.entry});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    'uberEarnings': TextEditingController(),
    'tips': TextEditingController(),
    'fuelCost': TextEditingController(),
    'foodCost': TextEditingController(),
    'cleaningCost': TextEditingController(),
    'otherCosts': TextEditingController(),
    'kmDriven': TextEditingController(),
    'hoursWorked': TextEditingController(),
  };

  DateTime _selectedDate = DateTime.now();
  double _netProfit = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      // Preenche o formulário em modo de edição
      final e = widget.entry!;
      _selectedDate = e.date;
      _controllers['uberEarnings']!.text = e.uberEarnings.toString();
      _controllers['tips']!.text = e.tips.toString();
      _controllers['fuelCost']!.text = e.fuelCost.toString();
      _controllers['foodCost']!.text = e.foodCost.toString();
      _controllers['cleaningCost']!.text = e.cleaningCost.toString();
      _controllers['otherCosts']!.text = e.otherCosts.toString();
      _controllers['kmDriven']!.text = e.kmDriven.toString();
      _controllers['hoursWorked']!.text = e.hoursWorked.toString();
    }
    // Adiciona listeners para calcular lucro em tempo real
    _controllers.forEach((key, controller) {
      controller.addListener(_updateNetProfit);
    });
    // Calcula o lucro inicial
    _updateNetProfit();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.removeListener(_updateNetProfit);
      controller.dispose();
    });
    super.dispose();
  }

  void _updateNetProfit() {
    final double earnings =
        (double.tryParse(_controllers['uberEarnings']!.text) ?? 0.0) +
        (double.tryParse(_controllers['tips']!.text) ?? 0.0);

    final double expenses =
        (double.tryParse(_controllers['fuelCost']!.text) ?? 0.0) +
        (double.tryParse(_controllers['foodCost']!.text) ?? 0.0) +
        (double.tryParse(_controllers['cleaningCost']!.text) ?? 0.0) +
        (double.tryParse(_controllers['otherCosts']!.text) ?? 0.0);

    setState(() {
      _netProfit = earnings - expenses;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<EntryProvider>(context, listen: false);

      if (widget.entry == null && provider.entryExistsForDate(_selectedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Já existe um lançamento para esta data!')),
        );
        return;
      }

      double parseField(String key) {
        final text = _controllers[key]?.text.replaceAll(',', '.') ?? '';
        return double.tryParse(text) ?? 0.0;
      }

      final data = DailyEntry(
        id: widget.entry?.id,
        date: _selectedDate,
        uberEarnings: parseField('uberEarnings'),
        tips: parseField('tips'),
        fuelCost: parseField('fuelCost'),
        foodCost: parseField('foodCost'),
        cleaningCost: parseField('cleaningCost'),
        otherCosts: parseField('otherCosts'),
        kmDriven: parseField('kmDriven'),
        hoursWorked: parseField('hoursWorked'),
      );

      if (widget.entry == null) {
        await provider.addEntry(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lançamento salvo com sucesso!')),
        );
      } else {
        await provider.updateEntry(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lançamento atualizado com sucesso!')),
        );
      }

      // Aguarda o SnackBar aparecer antes de fechar a tela
      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pop();
    }
  }

  Widget _buildTextField(
    String label,
    String key,
    IconData icon, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Campo obrigatório.';
          }
          if (value != null &&
              value.isNotEmpty &&
              double.tryParse(value.replaceAll(',', '.')) == null) {
            return 'Por favor, insira um número válido.';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'Novo Lançamento' : 'Editar Lançamento',
        ),
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
                          'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  initiallyExpanded: true,
                  children: [
                    _buildTextField(
                      'Repasse Uber (R\$)',
                      'uberEarnings',
                      Icons.attach_money,
                      required: true, // obrigatório
                    ),
                    _buildTextField(
                      'Gorjetas (R\$)',
                      'tips',
                      Icons.card_giftcard,
                    ),
                  ],
                ),

                // CARD DE GASTOS
                ExpansionTile(
                  title: Text(
                    'Gastos do Dia',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  children: [
                    _buildTextField(
                      'Combustível (R\$)',
                      'fuelCost',
                      Icons.local_gas_station,
                    ),
                    _buildTextField(
                      'Alimentação (R\$)',
                      'foodCost',
                      Icons.restaurant,
                    ),
                    _buildTextField(
                      'Limpeza (R\$)',
                      'cleaningCost',
                      Icons.wash,
                    ),
                    _buildTextField(
                      'Outros Gastos (R\$)',
                      'otherCosts',
                      Icons.more_horiz,
                    ),
                  ],
                ),

                // CARD DE MÉTRICAS
                ExpansionTile(
                  title: Text(
                    'Métricas de Trabalho',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  children: [
                    _buildTextField(
                      'KM Rodados',
                      'kmDriven',
                      Icons.directions_car,
                      required: true, // obrigatório
                    ),
                    _buildTextField(
                      'Horas Trabalhadas',
                      'hoursWorked',
                      Icons.timer,
                      required: true, // obrigatório
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Rodapé com cálculo de lucro
          Container(
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
                  // 'Lucro do Dia:',
                  AppLocalizations.of(context)!.dailyProfit,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  currencyFormat.format(_netProfit),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _netProfit >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
