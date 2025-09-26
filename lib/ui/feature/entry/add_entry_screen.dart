/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/daily_entry.dart';
import '../providers/entry_provider.dart';

class AddEntryScreen extends StatefulWidget {
  final Entry? entry;

  AddEntryScreen({this.entry});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late TextEditingController _hoursController;
  late TextEditingController _kmController;
  late TextEditingController _ridesController;
  late TextEditingController _grossController;
  late TextEditingController _feesController;
  late TextEditingController _fuelController;
  late TextEditingController _maintenanceController;
  late TextEditingController _otherController;

  @override
  void initState() {
    super.initState();
    _date = widget.entry?.date ?? DateTime.now();
    _hoursController = TextEditingController(
      text: widget.entry?.hoursWorked.toString() ?? '',
    );
    _kmController = TextEditingController(
      text: widget.entry?.kmDriven.toString() ?? '',
    );
    _ridesController = TextEditingController(
      text: widget.entry?.rides.toString() ?? '',
    );
    _grossController = TextEditingController(
      text: widget.entry?.grossEarnings.toString() ?? '',
    );
    _feesController = TextEditingController(
      text: widget.entry?.uberFees.toString() ?? '',
    );
    _fuelController = TextEditingController(
      text: widget.entry?.fuelCost.toString() ?? '',
    );
    _maintenanceController = TextEditingController(
      text: widget.entry?.maintenanceCost.toString() ?? '',
    );
    _otherController = TextEditingController(
      text: widget.entry?.otherExpenses.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _kmController.dispose();
    _ridesController.dispose();
    _grossController.dispose();
    _feesController.dispose();
    _fuelController.dispose();
    _maintenanceController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? 'Adicionar Entrada' : 'Editar Entrada',
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text('Data: ${DateFormat('dd/MM/yyyy').format(_date)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              TextFormField(
                controller: _hoursController,
                decoration: InputDecoration(labelText: 'Horas Trabalhadas'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _kmController,
                decoration: InputDecoration(labelText: 'Km Rodados'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _ridesController,
                decoration: InputDecoration(labelText: 'Corridas Realizadas'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _grossController,
                decoration: InputDecoration(labelText: 'Ganhos Brutos (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _feesController,
                decoration: InputDecoration(labelText: 'Taxas Uber (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _fuelController,
                decoration: InputDecoration(labelText: 'Combustível (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _maintenanceController,
                decoration: InputDecoration(labelText: 'Manutenção (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _otherController,
                decoration: InputDecoration(labelText: 'Outras Despesas (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final entry = Entry(
                      id: widget.entry?.id,
                      date: _date,
                      hoursWorked: double.parse(_hoursController.text),
                      kmDriven: double.parse(_kmController.text),
                      rides: int.parse(_ridesController.text),
                      grossEarnings: double.parse(_grossController.text),
                      uberFees: double.parse(_feesController.text),
                      fuelCost: double.parse(_fuelController.text),
                      maintenanceCost: double.parse(
                        _maintenanceController.text,
                      ),
                      otherExpenses: double.parse(_otherController.text),
                    );
                    if (widget.entry == null) {
                      Provider.of<EntryProvider>(
                        context,
                        listen: false,
                      ).addEntry(entry);
                    } else {
                      Provider.of<EntryProvider>(
                        context,
                        listen: false,
                      ).updateEntry(entry);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
