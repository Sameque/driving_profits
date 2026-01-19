import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/entry/validations/edit_entry_validations.dart';
import 'package:driving_profits/ui/widget/app_bar_screen_form.dart';
import 'package:driving_profits/ui/widget/text_field_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:driving_profits/l10n/app_localizations.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_viewmodel.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
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
  late EntryDto entry = EntryDto();

  @override
  void initState() {
    super.initState();

    entry = widget.entryDto.copy();

    viewmodel.updateCommand.addListener(_listanable);

    entry.addListener(() => viewmodel.markAsUnsaved());
  }

  @override
  void dispose() {
    viewmodel.updateCommand.removeListener(_listanable);
    entry.removeListener(() => viewmodel.markAsUnsaved());

    super.dispose();
  }

  void _listanable() {
    if (viewmodel.updateCommand.value.isFailure) {
      final failure = viewmodel.updateCommand.value as FailureCommand<Object>;

      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message: "Erro ao salvar:\n - ${failure.error.toString()}",
        );
      }
    }

    if (viewmodel.updateCommand.value.isSuccess) {
      if (mounted) {
        CustomSnackBar.success(
          context: context,
          message: 'Jornada atualizada com sucesso!',
        );
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entry.getStartDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != entry.startDate) {
      entry.setStartDate(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entry.getEndDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != entry.startDate) {
      entry.setEndDate(picked);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entry.getStartTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      entry.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entry.getEndTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      entry.setEndTime(picked);
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await viewmodel.updateCommand.execute(entry);

    if (viewmodel.updateCommand.value.isFailure) return;

    widget.onSave?.call(entry);

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => () async {
        if (viewmodel.hasUnsavedChanges) {
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
        //TODO: colocar o texto em um arquivo de localização
        appBar: AppBarScreenForm(screenTitle: 'Editar Lançamento'),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Start Data
                  ListenableBuilder(
                    listenable: entry,
                    builder: (context, _) {
                      return Column(
                        children: [
                          ListTile(
                            title: const Text('Data Inicial'),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(entry.startDate),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectStartDate(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.1),
                          ),

                          const SizedBox(height: 24),
                          // End Data
                          ListTile(
                            title: const Text('Data Final'),
                            subtitle: Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(entry.endDate ?? DateTime.now()),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectEndDate(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.1),
                          ),
                        ],
                      );
                    },
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
                  //TODO: lista de gastos dinamca
                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Repasse (R\$)',
                    initial: entry.getUberEarnings,
                    onChanged: entry.setUberEarnings,
                    icon: Icons.attach_money,
                    autofocus: true,
                  ),

                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Gorjetas (R\$)',
                    initial: entry.getTips,
                    onChanged: entry.setTips,
                    icon: Icons.card_giftcard,
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

                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Média de Consumo (km/L)',
                    initial: entry.getFuelEfficiency,
                    onChanged: entry.setFuelEfficiency,
                    icon: Icons.speed,
                    validator: EditEntryValidations.validateFuelEfficiency,
                  ),
                  // Valor do Combustível
                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Valor do Combustível (R\$/l)',
                    initial: entry.getFuelPrice,
                    onChanged: entry.setFuelPrice,
                    icon: Icons.attach_money,
                    validator: EditEntryValidations.validateFuelPrice,
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
                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Km Inicial',
                    initial: entry.getKmStart,
                    onChanged: entry.setKmStart,
                    icon: Icons.directions_car,
                    isCurrency: false,
                  ),

                  TextFieldCustom(
                    //TODO: colocar o texto em um arquivo de localização
                    label: 'Km Final',
                    initial: entry.getKmEnd,
                    onChanged: entry.setKmEnd,
                    icon: Icons.directions_car,
                    isCurrency: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),

                  TextFieldCustom(
                    initial: entry.getNumberOfTrips,
                    onChanged: entry.setNumberOfTrips,
                    label: 'Quantidade de viagens',
                    icon: Icons.route,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) =>
                        EditEntryValidations.validateNumberOfTrips(entry),
                  ),
                  ListenableBuilder(
                    listenable: viewmodel,
                    builder: (context, _) {
                      return Column(
                        children: [
                          ListTile(
                            //TODO: colocar o texto em um arquivo de localização
                            title: const Text('Hora Inicial'),
                            subtitle: Text(entry.startTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectStartTime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
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
                              entry.endTime?.format(context) ??
                                  //TODO: colocar o texto em um arquivo de localização
                                  'Não definida',
                            ),
                            trailing: const Icon(Icons.access_time),
                            onTap: _selectEndTime,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
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
                            trailing: Text(entry.totalKm.toString()),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.1),
                          ),
                          ListTile(
                            //TODO: colocar o texto em um arquivo de localização
                            title: const Text('Horas Trabalhadas (calculado)'),
                            trailing: Text(
                              entry.totalHoursWorked?.format(context) ?? '',
                            ),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.1),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botão para salvar
                  FilledButton(
                    onPressed: viewmodel.updateCommand.value.isRunning
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
                  // ),
                ],
              ),
            ),

            viewmodel.updateCommand.value.isRunning
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: ListenableBuilder(
            listenable: entry,
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
                      currencyFormat.format(entry.netEarnings),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: entry.netEarnings >= 0
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
