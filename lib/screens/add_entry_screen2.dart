// lib/screens/add_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  void _saveForm() {
    // if (_formKey.currentState!.validate()) {
    //   final newEntry = DailyEntry(
    //     date: _selectedDate,
    //     uberEarnings:
    //         double.tryParse(_controllers['uberEarnings']!.text) ?? 0.0,
    //     tips: double.tryParse(_controllers['tips']!.text) ?? 0.0,
    //     fuelCost: double.tryParse(_controllers['fuelCost']!.text) ?? 0.0,
    //     foodCost: double.tryParse(_controllers['foodCost']!.text) ?? 0.0,
    //     cleaningCost:
    //         double.tryParse(_controllers['cleaningCost']!.text) ?? 0.0,
    //     otherCosts: double.tryParse(_controllers['otherCosts']!.text) ?? 0.0,
    //     kmDriven: double.tryParse(_controllers['kmDriven']!.text) ?? 0.0,
    //     hoursWorked: double.tryParse(_controllers['hoursWorked']!.text) ?? 0.0,
    //   );
    //   Provider.of<EntryProvider>(context, listen: false).addEntry(newEntry);
    // }
    if (widget.entry != null) {
      final updatedEntry = DailyEntry(
        id: widget.entry!.id, // MANTÉM O ID ORIGINAL
        date: _selectedDate,
        uberEarnings:
            double.tryParse(_controllers['uberEarnings']!.text) ?? 0.0,
        tips: double.tryParse(_controllers['tips']!.text) ?? 0.0,
        fuelCost: double.tryParse(_controllers['fuelCost']!.text) ?? 0.0,
        foodCost: double.tryParse(_controllers['foodCost']!.text) ?? 0.0,
        cleaningCost:
            double.tryParse(_controllers['cleaningCost']!.text) ?? 0.0,
        otherCosts: double.tryParse(_controllers['otherCosts']!.text) ?? 0.0,
        kmDriven: double.tryParse(_controllers['kmDriven']!.text) ?? 0.0,
        hoursWorked: double.tryParse(_controllers['hoursWorked']!.text) ?? 0.0,
      );
      Provider.of<EntryProvider>(
        context,
        listen: false,
      ).updateEntry(updatedEntry);
    } else {
      final newEntry = DailyEntry(
        date: _selectedDate,
        uberEarnings:
            double.tryParse(_controllers['uberEarnings']!.text) ?? 0.0,
        tips: double.tryParse(_controllers['tips']!.text) ?? 0.0,
        fuelCost: double.tryParse(_controllers['fuelCost']!.text) ?? 0.0,
        foodCost: double.tryParse(_controllers['foodCost']!.text) ?? 0.0,
        cleaningCost:
            double.tryParse(_controllers['cleaningCost']!.text) ?? 0.0,
        otherCosts: double.tryParse(_controllers['otherCosts']!.text) ?? 0.0,
        kmDriven: double.tryParse(_controllers['kmDriven']!.text) ?? 0.0,
        hoursWorked: double.tryParse(_controllers['hoursWorked']!.text) ?? 0.0,
      );
      Provider.of<EntryProvider>(context, listen: false).addEntry(newEntry);
    }

    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
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
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildTextField(String label, String key) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira um valor.';
        }
        if (double.tryParse(value) == null) {
          return 'Por favor, insira um número válido.';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text('Adicionar Lançamento'),
        title: Text(
          widget.entry == null ? 'Adicionar Lançamento' : 'Editar Lançamento',
        ),

        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    child: Text('Selecionar Data'),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              _buildTextField('Repasse Uber (R\$)', 'uberEarnings'),
              _buildTextField('Gorjetas (R\$)', 'tips'),
              _buildTextField('Combustível (R\$)', 'fuelCost'),
              _buildTextField('Alimentação (R\$)', 'foodCost'),
              _buildTextField('Limpeza (R\$)', 'cleaningCost'),
              _buildTextField('Outros Gastos (R\$)', 'otherCosts'),
              _buildTextField('KM Rodados', 'kmDriven'),
              _buildTextField('Horas Trabalhadas', 'hoursWorked'),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Salvar Lançamento'),
                onPressed: _saveForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
