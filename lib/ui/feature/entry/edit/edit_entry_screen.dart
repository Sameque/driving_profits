import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/entry/validations/close_entry_validations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/l10n/app_localizations.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';

class EditEntryScreen extends StatefulWidget {
  final EntryDto entryDto;
  final Function(EntryDto)? onSave;

  const EditEntryScreen({super.key, required this.entryDto, this.onSave});

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final viewmodel = injector.get<EditEntryViewModel>();

  @override
  void initState() {
    super.initState();
    viewmodel.updateCommand.addListener(_listanable);

    widget.entryDto.addListener(() => viewmodel.markAsUnsaved());
  }

  void _listanable() {
    if (viewmodel.updateCommand.value.isFailure) {
      final failure = viewmodel.updateCommand.value as FailureCommand<Object>;

      CustomSnackBar.error(
        context: context,
        message: "Erro ao salvar:\n - ${failure.error.toString()}",
      );
    }
    if (viewmodel.updateCommand.value.isSuccess) {
      CustomSnackBar.success(
        context: context,
        message: 'Jornada atualizada com sucesso!',
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.entryDto.getDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != widget.entryDto.date) {
      widget.entryDto.setDate(picked);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.entryDto.getStartTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      widget.entryDto.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.entryDto.getEndTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      widget.entryDto.setEndTime(picked);
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    await viewmodel.updateCommand.execute(widget.entryDto);

    if (viewmodel.updateCommand.value.isFailure) return;

    widget.onSave?.call(widget.entryDto);

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildTextField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool isCurrency = true,
    bool autofocus = false,
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
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        ),
        keyboardType: TextInputType.number,
        inputFormatters:
            inputFormatters ??
            (isCurrency
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ]
                : [FilteringTextInputFormatter.digitsOnly]),
        //TODO: criar um validator
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) return null;
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed == null || parsed < 0) {
                return 'Insira um valor válido maior ou igual a zero.';
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => () async {
        final viewModel = Provider.of<EditEntryViewModel>(
          context,
          listen: false,
        );
        if (viewModel.hasUnsavedChanges) {
          didPop =
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Descartar alterações?'),
                  //TODO: colocar o texto em um arquivo de localização
                  content: const Text(
                    'Você tem alterações não salvas. Deseja descartá-las?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      //TODO: colocar o texto em um arquivo de localização
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      //TODO: colocar o texto em um arquivo de localização
                      child: const Text('Descartar'),
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
          //TODO: colocar o texto em um arquivo de localização
          title: const Text('Editar Lançamento'),
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
                  // Data
                  ListTile(
                    title: const Text('Data'),
                    subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(widget.entryDto.date),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),

                  const SizedBox(height: 24),

                  // Ganhos
                  Text(
                    //TODO: colocar o texto em um arquivo de localização
                    'Ganhos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Repasse (R\$)',
                    initial: widget.entryDto.getUberEarnings,
                    onChanged: widget.entryDto.setUberEarnings,
                    icon: Icons.attach_money,
                    autofocus: true,
                  ),

                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Gorjetas (R\$)',
                    initial: widget.entryDto.getTips,
                    onChanged: widget.entryDto.setTips,
                    icon: Icons.card_giftcard,
                  ),
                  const SizedBox(height: 24),

                  // Gastos do Dia
                  Text(
                    //TODO: colocar o texto em um arquivo de localização
                    'Gastos do Dia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Alimentação (R\$)',
                    initial: widget.entryDto.getFoodCost,
                    onChanged: widget.entryDto.setFoodCost,
                    icon: Icons.restaurant,
                  ),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Limpeza (R\$)',
                    initial: widget.entryDto.getCleaningCost,
                    onChanged: widget.entryDto.setCleaningCost,
                    icon: Icons.wash,
                  ),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Outros Gastos (R\$)',
                    initial: widget.entryDto.getOtherCosts,
                    onChanged: widget.entryDto.setOtherCosts,
                    icon: Icons.more_horiz,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    //TODO: colocar o texto em um arquivo de localização
                    'Calculo Combustível',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Média de Consumo (km/L)',
                    initial: widget.entryDto.getFuelEfficiency,
                    onChanged: widget.entryDto.setFuelEfficiency,
                    icon: Icons.speed,
                    validator: CloseEntryValidations.validateFuelEfficiency,
                  ),
                  // Valor do Combustível
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Valor do Combustível (R\$/l)',
                    initial: widget.entryDto.getFuelPrice,
                    onChanged: widget.entryDto.setFuelPrice,
                    icon: Icons.attach_money,
                    validator: CloseEntryValidations.validateFuelPrice,
                  ),

                  const SizedBox(height: 24),

                  // Métricas de Trabalho
                  Text(
                    //TODO: colocar o texto em um arquivo de localização
                    'Métricas de Trabalho',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Km Inicial',
                    initial: widget.entryDto.getKmStart,
                    onChanged: widget.entryDto.setKmStart,
                    icon: Icons.directions_car,
                    isCurrency: false,
                  ),
                  _buildTextField(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Km Final',
                    initial: widget.entryDto.getKmEnd,
                    onChanged: widget.entryDto.setKmEnd,
                    icon: Icons.directions_car,
                    isCurrency: false,
                  ),
                  const SizedBox(height: 8),

                  _buildTextField(
                    initial: widget.entryDto.getNumberOfTrips,
                    onChanged: widget.entryDto.setNumberOfTrips,
                    label: 'Quantidade de viagens',
                    icon: Icons.route,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        CloseEntryValidations.validateNumberOfTrips(
                          widget.entryDto,
                        ),
                  ),

                  ListTile(
                    //TODO: colocar o texto em um arquivo de localização
                    title: const Text('Hora Inicial'),
                    subtitle: Text(
                      widget.entryDto.startTime?.format(context) ??
                          //TODO: colocar o texto em um arquivo de localização
                          'Não definida',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectStartTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    //TODO: colocar o texto em um arquivo de localização
                    title: const Text('Hora Final'),
                    subtitle: Text(
                      widget.entryDto.endTime?.format(context) ??
                          //TODO: colocar o texto em um arquivo de localização
                          'Não definida',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectEndTime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    //TODO: colocar o texto em um arquivo de localização
                    title: const Text('Km Rodados (calculado)'),
                    trailing: Text(widget.entryDto.totalKm.toString()),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),
                  ListTile(
                    //TODO: colocar o texto em um arquivo de localização
                    title: const Text('Horas Trabalhadas (calculado)'),
                    trailing: Text(
                      widget.entryDto.totalHoursWorked?.format(context) ?? '',
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 32),

                  // Botão para salvar
                  Consumer<EditEntryViewModel>(
                    builder: (context, viewModel, _) => FilledButton(
                      onPressed: viewModel.updateCommand.value.isRunning
                          ? null
                          : _saveForm,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      //TODO: colocar o texto em um arquivo de localização
                      child: const Text('Salvar Alterações'),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<EditEntryViewModel>(
              builder: (context, viewModel, _) =>
                  viewModel.updateCommand.value.isRunning
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox(),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: widget.entryDto,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
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
                      currencyFormat.format(widget.entryDto.netEarnings),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.entryDto.netEarnings >= 0
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
