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
    'kmStart': TextEditingController(),
    'kmEnd': TextEditingController(),
  };

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  double _netProfit = 0.0;
  double _kmDriven = 0.0;
  double _hoursWorked = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay.now();
    _endTime = null;
    if (widget.entry != null) {
      final e = widget.entry!;
      _selectedDate = e.date;
      _controllers['uberEarnings']!.text = e.uberEarnings
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['tips']!.text = e.tips
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['fuelCost']!.text = e.fuelCost
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['foodCost']!.text = e.foodCost
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['cleaningCost']!.text = e.cleaningCost
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['otherCosts']!.text = e.otherCosts
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _controllers['kmStart']!.text = (e.kmStart ?? 0)
          .toStringAsFixed(1)
          .replaceAll('.', ',');
      _controllers['kmEnd']!.text = (e.kmEnd ?? 0)!
          .toStringAsFixed(1)
          .replaceAll('.', ',');
      _startTime = e.startTime;

      // if (e.startTime.isNotEmpty) {
      //   final parts = e.startTime.split(':');
      //   _startTime = TimeOfDay(
      //     hour: int.parse(parts[0]),
      //     minute: int.parse(parts[1]),
      //   );
      // } else {
      //   _startTime = TimeOfDay.now();
      // }
      _endTime = e.endTime;

      // if (e.endTime.isNotEmpty) {
      //   final parts = e.endTime.split(':');
      //   _endTime = TimeOfDay(
      //     hour: int.parse(parts[0]),
      //     minute: int.parse(parts[1]),
      //   );
      // } else {
      //   _endTime = null;
      // }
    }
    // Adiciona listeners
    _controllers.forEach((key, controller) {
      if ([
        'uberEarnings',
        'tips',
        'fuelCost',
        'foodCost',
        'cleaningCost',
        'otherCosts',
      ].contains(key)) {
        controller.addListener(_updateNetProfit);
      } else if (['kmStart', 'kmEnd'].contains(key)) {
        controller.addListener(_updateMetrics);
      }
    });
    // Calcula inicial
    _updateNetProfit();
    _updateMetrics();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      if ([
        'uberEarnings',
        'tips',
        'fuelCost',
        'foodCost',
        'cleaningCost',
        'otherCosts',
      ].contains(key)) {
        controller.removeListener(_updateNetProfit);
      } else if (['kmStart', 'kmEnd'].contains(key)) {
        controller.removeListener(_updateMetrics);
      }
      controller.dispose();
    });
    super.dispose();
  }

  void _updateNetProfit() {
    final double earnings =
        (double.tryParse(
              _controllers['uberEarnings']!.text.replaceAll(',', '.'),
            ) ??
            0.0) +
        (double.tryParse(_controllers['tips']!.text.replaceAll(',', '.')) ??
            0.0);

    final double expenses =
        (double.tryParse(_controllers['fuelCost']!.text.replaceAll(',', '.')) ??
            0.0) +
        (double.tryParse(_controllers['foodCost']!.text.replaceAll(',', '.')) ??
            0.0) +
        (double.tryParse(
              _controllers['cleaningCost']!.text.replaceAll(',', '.'),
            ) ??
            0.0) +
        (double.tryParse(
              _controllers['otherCosts']!.text.replaceAll(',', '.'),
            ) ??
            0.0);

    setState(() {
      _netProfit = earnings - expenses;
    });
  }

  void _updateMetrics() {
    final double startKm =
        double.tryParse(_controllers['kmStart']!.text.replaceAll(',', '.')) ??
        0.0;
    final double endKm =
        double.tryParse(_controllers['kmEnd']!.text.replaceAll(',', '.')) ??
        0.0;

    setState(() {
      _kmDriven = _controllers['kmEnd']!.text.isEmpty ? 0.0 : endKm - startKm;
      if (_endTime == null) {
        _hoursWorked = 0.0;
      } else {
        int startMin = _startTime!.hour * 60 + _startTime!.minute;
        int endMin = _endTime!.hour * 60 + _endTime!.minute;
        if (endMin < startMin) endMin += 24 * 60;
        _hoursWorked = (endMin - startMin) / 60.0;
      }
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

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _updateMetrics();
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
        _endTime = picked;
        _updateMetrics();
      });
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    bool isClosing = _endTime != null && _controllers['kmEnd']!.text.isNotEmpty;

    if (isClosing) {
      if (double.tryParse(
                _controllers['uberEarnings']!.text.replaceAll(',', '.'),
              ) ==
              null ||
          double.parse(
                _controllers['uberEarnings']!.text.replaceAll(',', '.'),
              ) ==
              0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('O repasse Uber é obrigatório ao fechar a jornada!'),
          ),
        );
        return;
      }
      final double startKm = double.parse(
        _controllers['kmStart']!.text.replaceAll(',', '.'),
      );
      final double endKm = double.parse(
        _controllers['kmEnd']!.text.replaceAll(',', '.'),
      );
      if (endKm <= startKm) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'A quilometragem final deve ser maior que a inicial!',
            ),
          ),
        );
        return;
      }
    } else {
      if (_controllers['kmStart']!.text.isEmpty || _startTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preencha a quilometragem inicial e hora inicial!'),
          ),
        );
        return;
      }
    }

    try {
      setState(() => _isLoading = true);
      final provider = Provider.of<EntryProvider>(context, listen: false);

      // if (widget.entry == null &&
      //     provider.entryExistsForDate(_selectedDate)) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Já existe um lançamento para esta data!')),
      //   );
      //   return;
      // }

      double parseField(String key) {
        final text = _controllers[key]!.text.replaceAll(',', '.');
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
        kmDriven: isClosing ? _kmDriven : 0.0,
        hoursWorked: isClosing ? _hoursWorked : 0.0,
        kmStart: parseField('kmStart'),
        kmEnd: isClosing ? parseField('kmEnd') : 0.0,
        startTime: _startTime, //!.format(context),
        endTime: _endTime, //?.format(context) ?? '',
      );

      if (widget.entry == null) {
        if (isClosing) {
          await provider.closeWorkSession(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jornada finalizada com sucesso!')),
          );
        } else {
          provider.startWorkSession(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jornada iniciada com sucesso!')),
          );
        }
      } else {
        if (isClosing) {
          await provider.closeWorkSession(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jornada finalizada com sucesso!')),
          );
        } else {
          // widget.entry = data;
          provider.updateOpenEntry(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Jornada atualizada com sucesso!')),
          );
        }
      }

      await Future.delayed(const Duration(milliseconds: 400));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /*
  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      bool isClosing =
          _endTime != null && _controllers['kmEnd']!.text.isNotEmpty;

      if (isClosing) {
        if (double.tryParse(
                  _controllers['uberEarnings']!.text.replaceAll(',', '.'),
                ) ==
                null ||
            double.parse(
                  _controllers['uberEarnings']!.text.replaceAll(',', '.'),
                ) ==
                0.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'O repasse Uber é obrigatório ao fechar a jornada!',
              ),
            ),
          );
          return;
        }
        final double startKm = double.parse(
          _controllers['kmStart']!.text.replaceAll(',', '.'),
        );
        final double endKm = double.parse(
          _controllers['kmEnd']!.text.replaceAll(',', '.'),
        );
        if (endKm <= startKm) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'A quilometragem final deve ser maior que a inicial!',
              ),
            ),
          );
          return;
        }
      } else {
        if (_controllers['kmStart']!.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preencha a quilometragem inicial!')),
          );
          return;
        }
      }

      try {
        setState(() => _isLoading = true);

        final provider = Provider.of<EntryProvider>(context, listen: false);

        if (widget.entry == null &&
            provider.entryExistsForDate(_selectedDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Já existe um lançamento para esta data!')),
          );
          return;
        }

        double parseField(String key) {
          final text = _controllers[key]!.text.replaceAll(',', '.');
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
          kmDriven: isClosing ? _kmDriven : 0.0,
          hoursWorked: isClosing ? _hoursWorked : 0.0,
          kmStart: parseField('kmStart'),
          kmEnd: isClosing ? parseField('kmEnd') : 0.0,
          startTime: _startTime ?? TimeOfDay.now(), //!.format(context),
          endTime: _endTime ?? TimeOfDay.now(), // .format(context) ?? '',
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

        await Future.delayed(const Duration(milliseconds: 400));
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
*/
  Widget _buildTextField(String label, String key, IconData icon) {
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

  bool get _formIsDirty {
    return _controllers.values.any(
          (controller) => controller.text.isNotEmpty,
        ) ||
        _endTime != null;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return WillPopScope(
      onWillPop: () async {
        if (_formIsDirty) {
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
        return true;
      },
      child: Scaffold(
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    initiallyExpanded: true,
                    children: [
                      _buildTextField(
                        'Repasse Uber (R\$)',
                        'uberEarnings',
                        Icons.attach_money,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    children: [
                      _buildTextField(
                        'Quilometragem Inicial (km)',
                        'kmStart',
                        Icons.directions_car,
                      ),
                      _buildTextField(
                        'Quilometragem Final (km)',
                        'kmEnd',
                        Icons.directions_car,
                      ),
                      ListTile(
                        title: Text(
                          'Hora Inicial: ${_startTime!.format(context)}',
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: _selectStartTime,
                      ),
                      ListTile(
                        title: Text(
                          _endTime == null
                              ? 'Hora Final: Não definida'
                              : 'Hora Final: ${_endTime!.format(context)}',
                        ),
                        trailing: Icon(Icons.access_time),
                        onTap: _selectEndTime,
                      ),
                      ListTile(
                        title: Text('KM Rodados (calculado)'),
                        trailing: Text(_kmDriven.toStringAsFixed(1)),
                      ),
                      ListTile(
                        title: Text('Horas Trabalhadas (calculado)'),
                        trailing: Text(_hoursWorked.toStringAsFixed(1)),
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
      ),
    );
  }
}
