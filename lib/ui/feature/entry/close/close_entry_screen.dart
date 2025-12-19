import 'package:driving_profits/configuration/dependecies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:driving_profits/ui/feature/entry/close/close_entry_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:driving_profits/domain/entry/validations/close_entry_validations.dart';
import 'package:driving_profits/ui/widget/currency_input_formatter.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';

class CloseEntryScreen extends StatefulWidget {
  final EntryDto entryDto;
  final Function(EntryDto)? onSave;

  const CloseEntryScreen({super.key, required this.entryDto, this.onSave});

  @override
  State<CloseEntryScreen> createState() => _CloseEntryScreenState();
}

class _CloseEntryScreenState extends State<CloseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final viewmodel = injector.get<CloseEntryViewModel>();

  @override
  void initState() {
    super.initState();
    widget.entryDto.setEndTime(TimeOfDay.now());
    widget.entryDto.setEndDate(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.entryDto.getEndDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != widget.entryDto.getEndDate) {
      widget.entryDto.setEndDate(picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: widget.entryDto.endTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (picked != null) {
      widget.entryDto.setEndTime(picked);
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validationErrors = CloseEntryValidations.validateForSave(
      widget.entryDto,
    );

    if (validationErrors.isNotEmpty) {
      final messages = validationErrors.join('\n');
      CustomSnackBar.error(context: context, message: messages);
      return;
    }

    widget.entryDto.setStatusEnum(EntryStatus.closed);
    final closed = DailyEntry.fromMap(widget.entryDto.toMap());

    await viewmodel.closeCommand.execute(closed);

    widget.onSave?.call(widget.entryDto);

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) Navigator.of(context).pop();
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
                _buildTextField(
                  initial: widget.entryDto.getKmEnd,
                  onChanged: widget.entryDto.setKmEnd,
                  label: 'Quilometragem Final (km)',
                  icon: Icons.directions_car,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => CloseEntryValidations.validateKmEnd(
                    value,
                    widget.entryDto,
                  ),
                ),

                ListenableBuilder(
                  listenable: widget.entryDto,
                  builder: (context, child) {
                    return Column(
                      children: [
                        ListTile(
                          title: const Text('Data Final'),
                          subtitle: Text(
                            DateFormat(
                              'dd/MM/yyyy',
                            ).format(widget.entryDto.getEndDate!),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () => _selectDate(context),
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

                        // Hora Final
                        ListTile(
                          title: const Text('Hora Final'),
                          subtitle: Text(
                            widget.entryDto.endTime == null
                                ? 'Não definida'
                                : widget.entryDto.endTime!.format(context),
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
                      ],
                    );
                  },
                ),

                if (CloseEntryValidations.hasEndTimeError(widget.entryDto))
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text(
                      CloseEntryValidations.getEndTimeErrorMessage(
                        widget.entryDto,
                        context,
                      )!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
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
                _buildTextField(
                  label: 'Ganhos Uber (R\$)',
                  initial: widget.entryDto.getUberEarnings,
                  onChanged: widget.entryDto.setUberEarnings,
                  icon: Icons.payments,
                  validator: CloseEntryValidations.validateUberEarnings,
                ),

                _buildTextField(
                  label: 'Gorjetas (R\$)',
                  initial: widget.entryDto.getTips,
                  onChanged: widget.entryDto.setTips,
                  icon: Icons.card_giftcard,
                ),

                // Média de Consumo
                _buildTextField(
                  label: 'Média de Consumo (km/l)',
                  initial: widget.entryDto.getFuelEfficiency,
                  onChanged: widget.entryDto.setFuelEfficiency,
                  icon: Icons.speed,
                  validator: CloseEntryValidations.validateFuelEfficiency,
                ),

                // Valor do Combustível
                _buildTextField(
                  label: 'Valor do Combustível (R\$/l)',
                  initial: widget.entryDto.getFuelPrice,
                  onChanged: widget.entryDto.setFuelPrice,
                  icon: Icons.attach_money,
                  validator: CloseEntryValidations.validateFuelPrice,
                ),

                // Resumo da Jornada - Apresentação melhorada com tabela
                ListenableBuilder(
                  listenable: widget.entryDto,
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
                                  '${widget.entryDto.totalHoursWorked?.format(context).toString() ?? '00:00'} horas',
                                ),
                                _buildTableRow(
                                  'KM Total',
                                  widget.entryDto.totalKm.toString(),
                                ),
                                _buildTableRow(
                                  'Combustível (Calculado)',
                                  'R\$ ${widget.entryDto.fuelCost.toStringAsFixed(2).replaceAll('.', ',')}',
                                ),
                                _buildTableRow(
                                  'Total de Gastos',
                                  'R\$ ${(widget.entryDto.totalCosts - widget.entryDto.fuelCost).toStringAsFixed(2).replaceAll('.', ',')}',
                                ),
                                _buildTableRow(
                                  'Ganhos',
                                  'R\$ ${widget.entryDto.totalEarnings.toStringAsFixed(2).replaceAll('.', ',')}',
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
                                        'R\$ ${widget.entryDto.netEarnings.toStringAsFixed(2).replaceAll('.', ',')}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              widget.entryDto.netEarnings >= 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Botão principal para salvar
                            FilledButton(
                              onPressed: viewmodel.closeCommand.value.isRunning
                                  ? null
                                  : _save,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Fechar Jornada'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          viewmodel.closeCommand.value.isRunning
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
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
