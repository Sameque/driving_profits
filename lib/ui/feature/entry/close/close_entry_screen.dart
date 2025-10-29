import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:driving_profits/ui/feature/entry/close/close_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/domain/entry/validations/close_entry_validations.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';

class CloseEntryScreen extends StatefulWidget {
  final DailyEntry entry;
  final VoidCallback? onSave;

  const CloseEntryScreen({super.key, required this.entry, this.onSave});

  @override
  State<CloseEntryScreen> createState() => _CloseEntryScreenState();
}

class _CloseEntryScreenState extends State<CloseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late EntryDto entryDto;

  @override
  void initState() {
    super.initState();
    entryDto = EntryDto.fromMap(widget.entry.toMap());
    entryDto.setEndTime(TimeOfDay.now());
    entryDto.setEndDate(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: entryDto.getEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != entryDto.getEndDate) {
      entryDto.setEndDate(picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: entryDto.endTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      entryDto.setEndTime(picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validationErrors = CloseEntryValidations.validateForSave(entryDto);
    if (validationErrors.isNotEmpty) {
      CustomSnackBar.error(context: context, message: validationErrors.first);
      return;
    }

    try {
      final viewModel = Provider.of<CloseEntryViewModel>(
        context,
        listen: false,
      );
      final map = entryDto.toMap();
      map['status'] = EntryStatus.closed.toString().split('.').last;
      final closed = DailyEntry.fromMap(map);

      await viewModel.closeWorkSession(closed);

      CustomSnackBar.success(
        context: context,
        message: 'Jornada finalizada com sucesso!',
      );
      widget.onSave?.call();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: 'Erro ao finalizar: ${e.toString()}',
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
            [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechar Jornada'),
        centerTitle:
            false, // Alinha o título à esquerda para melhor legibilidade
        elevation: 0, // Visual mais moderno e flat
        scrolledUnderElevation: 4, // Elevação sutil ao scrollar
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface, // Integra com o tema
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onSurface, // Garante contraste
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ), // Borda inferior sutil para separação
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Quilometragem Final
                _buildTextField(
                  initial: entryDto.getKmEnd,
                  onChanged: entryDto.setKmEnd,
                  label: 'Quilometragem Final (km)',
                  icon: Icons.directions_car,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      CloseEntryValidations.validateKmEnd(value, entryDto),
                ),
                // Data Final
                ListTile(
                  title: const Text('Data Final'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(entryDto.getEndDate!),
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

                // Hora Final
                ListTile(
                  title: const Text('Hora Final'),
                  subtitle: Text(
                    entryDto.endTime == null
                        ? 'Não definida'
                        : entryDto.endTime!.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectEndTime,
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
                if (CloseEntryValidations.hasEndTimeError(entryDto))
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text(
                      CloseEntryValidations.getEndTimeErrorMessage(
                        entryDto,
                        context,
                      )!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Ganhos Uber
                _buildTextField(
                  label: 'Ganhos Uber (R\$)',
                  initial: entryDto.getUberEarnings,
                  onChanged: entryDto.setUberEarnings,
                  icon: Icons.payments,
                  validator: CloseEntryValidations.validateUberEarnings,
                ),

                // Gorjetas
                _buildTextField(
                  label: 'Gorjetas (R\$)',
                  initial: entryDto.getTips,
                  onChanged: entryDto.setTips,
                  icon: Icons.card_giftcard,
                ),

                // Média de Consumo
                _buildTextField(
                  label: 'Média de Consumo (km/l)',
                  initial: entryDto.getFuelEfficiency,
                  onChanged: entryDto.setFuelEfficiency,
                  icon: Icons.speed,
                  validator: CloseEntryValidations.validateFuelEfficiency,
                ),

                // Valor do Combustível
                _buildTextField(
                  label: 'Valor do Combustível (R\$/l)',
                  initial: entryDto.getFuelPrice,
                  onChanged: entryDto.setFuelPrice,
                  icon: Icons.attach_money,
                  validator: CloseEntryValidations.validateFuelPrice,
                ),

                // Resumo da Jornada - Apresentação melhorada com tabela
                ListenableBuilder(
                  listenable: entryDto,
                  builder: (context, child) {
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fechamento da Jornada',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(3),
                                1: FlexColumnWidth(2),
                              },
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                  width: 1,
                                ),
                                bottom: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              children: [
                                _buildTableRow(
                                  'Total de Horas Trabalhadas',
                                  '${entryDto.totalHoursWorked?.format(context).toString() ?? '00:00'} horas',
                                ),
                                _buildTableRow(
                                  'KM Total',
                                  entryDto.totalKm.toString(),
                                ),
                                _buildTableRow(
                                  'Combustível (Calculado)',
                                  'R\$ ${entryDto.fuelCost.toStringAsFixed(2).replaceAll('.', ',')}',
                                ),
                                _buildTableRow(
                                  'Total de Gastos',
                                  'R\$ ${(entryDto.totalCosts - entryDto.fuelCost).toStringAsFixed(2).replaceAll('.', ',')}',
                                ),
                                _buildTableRow(
                                  'Ganhos',
                                  'R\$ ${entryDto.totalEarnings.toStringAsFixed(2).replaceAll('.', ',')}',
                                ),
                                TableRow(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text('Lucro Líquido'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: Text(
                                        'R\$ ${entryDto.netEarnings.toStringAsFixed(2).replaceAll('.', ',')}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: entryDto.netEarnings >= 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Botão principal para salvar
                Consumer<CloseEntryViewModel>(
                  builder: (context, viewModel, _) => FilledButton(
                    onPressed: viewModel.isLoading ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Fechar Jornada'),
                  ),
                ),
              ],
            ),
          ),
          Consumer<CloseEntryViewModel>(
            builder: (context, viewModel, _) => viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(value, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
