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

class EditEntryScreen extends StatefulWidget {
  final DailyEntry entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  _EditEntryScreenState createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late EntryDto entryDto;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());
    final viewModel = Provider.of<EditEntryViewModel>(context, listen: false);
    entryDto.addListener(() => viewModel.markAsUnsaved());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entryDto.getDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != entryDto.date) {
      entryDto.setDate(picked);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entryDto.getStartTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      entryDto.setStartTime(picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: entryDto.getEndTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      entryDto.setEndTime(picked);
    }
  }

  void _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final viewModel = Provider.of<EditEntryViewModel>(context, listen: false);

      await viewModel.updateEntry(entryDto);

      CustomSnackBar.success(
        context: context,
        message: 'Jornada atualizada com sucesso!',
      );

      await Future.delayed(const Duration(milliseconds: 400));

      if (mounted) Navigator.of(context).pop();
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
                  content: const Text(
                    'Você tem alterações não salvas. Deseja descartá-las?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
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
                      DateFormat('dd/MM/yyyy').format(entryDto.date),
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
                    'Ganhos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Repasse Uber (R\$)',
                    initial: entryDto.getUberEarnings,
                    onChanged: entryDto.setUberEarnings,
                    icon: Icons.attach_money,
                    autofocus: true,
                  ),
                  _buildTextField(
                    label: 'Gorjetas (R\$)',
                    initial: entryDto.getTips,
                    onChanged: entryDto.setTips,
                    icon: Icons.card_giftcard,
                  ),
                  const SizedBox(height: 24),

                  // Gastos do Dia
                  Text(
                    'Gastos do Dia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 24),

                  // Métricas de Trabalho
                  Text(
                    'Métricas de Trabalho',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Quilometragem Inicial (km)',
                    initial: entryDto.getKmStart,
                    onChanged: entryDto.setKmStart,
                    icon: Icons.directions_car,
                    isCurrency: false,
                  ),
                  _buildTextField(
                    label: 'Quilometragem Final (km)',
                    initial: entryDto.getKmEnd,
                    onChanged: entryDto.setKmEnd,
                    icon: Icons.directions_car,
                    isCurrency: false,
                  ),
                  ListTile(
                    title: const Text('Hora Inicial'),
                    subtitle: Text(
                      entryDto.startTime?.format(context) ?? 'Não definida',
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
                    title: const Text('Hora Final'),
                    subtitle: Text(
                      entryDto.endTime?.format(context) ?? 'Não definida',
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
                    title: const Text('KM Rodados (calculado)'),
                    trailing: Text(entryDto.totalKm.toString()),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.1),
                  ),
                  ListTile(
                    title: const Text('Horas Trabalhadas (calculado)'),
                    trailing: Text(
                      entryDto.totalHoursWorked?.format(context) ?? '',
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
                      onPressed: viewModel.isLoading ? null : _saveForm,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Salvar Alterações'),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<EditEntryViewModel>(
              builder: (context, viewModel, _) => viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox(),
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
