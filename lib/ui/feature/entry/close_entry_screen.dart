import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/models/daily_entry.dart';
import 'package:uber_tracker/models/entry_status.dart';
import 'package:uber_tracker/providers/entry_provider.dart';
import 'package:uber_tracker/ui/feature/entry/entry_dto.dart';
import 'package:uber_tracker/ui/feature/entry/close_entry_validations.dart';
import 'package:uber_tracker/ui/widget/currency_input_formatter.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';

class CloseEntryScreen extends StatefulWidget {
  final DailyEntry entry;

  const CloseEntryScreen({super.key, required this.entry});

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
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: entryDto.endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        entryDto.setEndTime(picked);
      });
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
      final provider = Provider.of<EntryProvider>(context, listen: false);
      final map = entryDto.toMap();
      map['status'] = EntryStatus.closed.toString().split('.').last;
      final closed = DailyEntry.fromMap(map);
      await provider.closeWorkSession(closed);

      CustomSnackBar.success(
        context: context,
        message: 'Jornada finalizada com sucesso!',
      );
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      CustomSnackBar.error(
        context: context,
        message: 'Erro ao finalizar: ${e.toString()}',
      );
    }
  }

  Widget _amountField({
    required String label,
    required String initial,
    required ValueChanged<String> onChanged,
    IconData icon = Icons.attach_money,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        onChanged: onChanged,
        controller: TextEditingController(text: initial),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CurrencyInputFormatter(),
        ],
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechar Jornada'),
        actions: [IconButton(icon: const Icon(Icons.save), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: TextFormField(
                onChanged: entryDto.setKmEnd,
                controller: TextEditingController(text: entryDto.getKmEnd),
                decoration: InputDecoration(
                  labelText: 'Quilometragem Final (km)',
                  prefixIcon: const Icon(Icons.directions_car),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    CloseEntryValidations.validateKmEnd(value, entryDto),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      entryDto.endTime == null
                          ? 'Hora Final: Não definida'
                          : 'Hora Final: ${entryDto.endTime!.format(context)}',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectEndTime,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (CloseEntryValidations.hasEndTimeError(entryDto))
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                        CloseEntryValidations.getEndTimeErrorMessage(
                          entryDto,
                          context,
                        )!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            _amountField(
              label: 'Ganhos Uber',
              initial: entryDto.getUberEarnings,
              onChanged: entryDto.setUberEarnings,
              icon: Icons.payments,
              validator: CloseEntryValidations.validateUberEarnings,
            ),
            _amountField(
              label: 'Gorjetas',
              initial: entryDto.getTips,
              onChanged: entryDto.setTips,
              icon: Icons.card_giftcard,
            ),
            _amountField(
              label: 'Combustível',
              initial: entryDto.getFuelCost,
              onChanged: entryDto.setFuelCost,
              icon: Icons.local_gas_station,
            ),
            _amountField(
              label: 'Alimentação',
              initial: entryDto.getFoodCost,
              onChanged: entryDto.setFoodCost,
              icon: Icons.restaurant,
            ),
            _amountField(
              label: 'Lavagem/Limpeza',
              initial: entryDto.getCleaningCost,
              onChanged: entryDto.setCleaningCost,
              icon: Icons.local_laundry_service,
            ),
            _amountField(
              label: 'Outros Gastos',
              initial: entryDto.getOtherCosts,
              onChanged: entryDto.setOtherCosts,
              icon: Icons.more_horiz,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
