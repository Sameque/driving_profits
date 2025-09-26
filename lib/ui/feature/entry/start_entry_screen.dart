import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../models/daily_entry.dart';
import '../../../providers/entry_provider.dart';

class StartEntryScreen extends StatefulWidget {
  const StartEntryScreen({super.key});

  @override
  _StartEntryScreenState createState() => _StartEntryScreenState();
}

class _StartEntryScreenState extends State<StartEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmStartController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  bool _isLoading = false;

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
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      if (_kmStartController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preencha a quilometragem inicial!')),
        );
        return;
      }

      try {
        setState(() => _isLoading = true);

        final provider = Provider.of<EntryProvider>(context, listen: false);

        // if (provider.entryExistsForDate(_selectedDate)) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Já existe um lançamento para esta data!')),
        //   );
        //   return;
        // }

        final int kmStart = int.parse(_kmStartController.text);

        final data = DailyEntry.start(
          date: _selectedDate,
          startTime: _startTime,
          kmStart: kmStart,
        );

        provider.startWorkSession(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Jornada iniciada com sucesso!')),
        );

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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
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
          if (value == null || value.isEmpty) {
            return 'Campo obrigatório.';
          }
          if (double.tryParse(value.replaceAll(',', '.')) == null) {
            return 'Por favor, insira um número válido.';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Jornada'),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: _saveForm)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            ListTile(
              title: Text('Hora Inicial: ${_startTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: _selectStartTime,
            ),
            SizedBox(height: 20),
            _buildTextField(
              'Quilometragem Inicial (km)',
              _kmStartController,
              Icons.directions_car,
            ),
          ],
        ),
      ),
    );
  }
}
