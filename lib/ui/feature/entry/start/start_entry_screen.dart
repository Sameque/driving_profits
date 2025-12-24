import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_viewmodel.dart';
import 'package:driving_profits/ui/widget/app_bar_screen_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';

class StartEntryScreen extends StatefulWidget {
  final Function(EntryDto)? onSave;

  const StartEntryScreen({super.key, this.onSave});

  @override
  _StartEntryScreenState createState() => _StartEntryScreenState();
}

class _StartEntryScreenState extends State<StartEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kmStartController = TextEditingController();
  final viewmodel = injector.get<StartEntryViewmodel>();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    viewmodel.startWorkSessionCommand.addListener(_listanable);
  }

  void _listanable() {
    if (viewmodel.startWorkSessionCommand.value.isRunning) return;

    if (viewmodel.startWorkSessionCommand.value.isFailure) {
      final failure =
          viewmodel.startWorkSessionCommand.value as FailureCommand<Object>;

      if (mounted) {
        CustomSnackBar.error(
          context: context,
          //TODO: Localizar
          message: "Erro ao iniciar jornada:\n - ${failure.error.toString()}",
        );
      }
    }

    if (viewmodel.startWorkSessionCommand.value.isSuccess) {
      if (mounted) {
        CustomSnackBar.success(
          context: context,
          //TODO: Localizar
          message: 'Jornada Iniciada!',
        );
      }
    }
  }

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
      setState(() => _isLoading = true);

      final int kmStart = int.parse(_kmStartController.text);

      final entryStart = EntryDto.start(
        date: _selectedDate,
        startTime: _startTime,
        kmStart: kmStart,
      );

      await viewmodel.startWorkSessionCommand.execute(entryStart);

      widget.onSave?.call(entryStart);

      //TODO: millisecondsClosedScreen em arquivo de configuração, statico
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) Navigator.of(context).pop();
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
      appBar: AppBarScreenForm(screenTitle: 'Iniciar Jornada'),
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
