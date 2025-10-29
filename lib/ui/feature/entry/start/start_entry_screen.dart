import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';

class StartEntryScreen extends StatefulWidget {
  final VoidCallback? onSave;

  const StartEntryScreen({super.key, this.onSave});

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
      locale: const Locale('pt', 'BR'),
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
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);

        final viewmodel = Provider.of<StartEntryViewmodel>(
          context,
          listen: false,
        );

        final int kmStart = int.parse(_kmStartController.text);

        final data = EntryDto.start(
          date: _selectedDate,
          startTime: _startTime,
          kmStart: kmStart,
        );

        await viewmodel.startWorkSession(data);
        CustomSnackBar.success(
          context: context,
          message: 'Jornada iniciada com sucesso!',
        );

        widget.onSave?.call();

        await Future.delayed(const Duration(milliseconds: 400));
        Navigator.of(context).pop();
      } catch (e) {
        CustomSnackBar.error(
          context: context,
          message: 'Erro ao salvar: ${e.toString()}',
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
    return TextFormField(
      controller: controller,
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
        FilteringTextInputFormatter.allow(RegExp(r'^\d*[,|.]?\d{0,3}')),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Campo obrigatório.';
        }
        final parsedValue = double.tryParse(value.replaceAll(',', '.'));
        if (parsedValue == null || parsedValue < 0) {
          return 'Por favor, insira um número válido maior ou igual a zero.';
        }
        return null;
      },
      autofocus: true,
    );
  }

  @override
  void dispose() {
    _kmStartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Jornada'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  title: const Text('Data'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Hora Inicial'),
                  subtitle: Text(_startTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectStartTime,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  tileColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Quilometragem Inicial (km)',
                  _kmStartController,
                  Icons.directions_car,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _saveForm,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Iniciar Jornada'),
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
