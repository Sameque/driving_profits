import 'package:flutter/material.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';

class CloseEntryValidations {
  static String? validateUberEarnings(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe os ganhos do Uber';
    }
    final earnings = double.tryParse(value.replaceAll(',', '.'));
    if (earnings == null || earnings <= 0) {
      return 'Ganhos devem ser maiores que zero';
    }
    return null;
  }

  static String? validateKmEnd(String? value, EntryDto entryDto) {
    if (value == null || value.isEmpty) {
      return 'Informe a quilometragem final';
    }
    final kmEndValue = int.tryParse(value);
    if (kmEndValue == null || kmEndValue <= 0) {
      return 'Quilometragem final deve ser maior que zero';
    }
    if (entryDto.kmStart != null && kmEndValue <= entryDto.kmStart!) {
      return 'Quilometragem final deve ser maior que a inicial (${entryDto.kmStart} km)';
    }
    return null;
  }

  static String? validateEndTime(EntryDto entryDto) {
    if (entryDto.endTime == null) {
      return 'Selecione a hora final';
    }
    return null;
  }

  /// Valida se a hora final é maior que a hora inicial considerando as datas
  static String? validateEndTimeAfterStartTime(EntryDto entryDto) {
    if (entryDto.startTime != null &&
        entryDto.endTime != null &&
        entryDto.date != null &&
        entryDto.endDate != null) {
      if (_isEndDateTimeBeforeStartDateTime(
        startDate: entryDto.date!,
        startTime: entryDto.startTime!,
        endDate: entryDto.endDate!,
        endTime: entryDto.endTime!,
      )) {
        return 'Data/hora final deve ser maior que a data/hora inicial';
      }
    }
    return null;
  }

  static bool _isEndDateTimeBeforeStartDateTime({
    required DateTime startDate,
    required TimeOfDay startTime,
    required DateTime endDate,
    required TimeOfDay endTime,
  }) {
    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    return endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime);
  }

  static String? getEndTimeErrorMessage(
    EntryDto entryDto,
    BuildContext context,
  ) {
    final endTimeError = validateEndTime(entryDto);
    if (endTimeError != null) {
      return endTimeError;
    }

    final timeComparisonError = validateEndTimeAfterStartTime(entryDto);
    if (timeComparisonError != null) {
      return 'Data/hora final deve ser maior que a inicial (${_formatDateTime(entryDto.date!, entryDto.startTime!, context)})';
    }

    return null;
  }

  static String _formatDateTime(
    DateTime date,
    TimeOfDay time,
    BuildContext context,
  ) {
    return '${date.day}/${date.month}/${date.year} ${time.format(context)}';
  }

  static bool hasEndTimeError(EntryDto entryDto) {
    return validateEndTime(entryDto) != null ||
        validateEndTimeAfterStartTime(entryDto) != null;
  }

  static String? validateFuelEfficiency(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe a média de consumo';
    }
    final efficiency = double.tryParse(value.replaceAll(',', '.'));
    if (efficiency == null || efficiency <= 0) {
      return 'Média de consumo deve ser maior que zero';
    }
    return null;
  }

  static String? validateFuelPrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe o valor do combustível';
    }
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'Valor do combustível deve ser maior que zero';
    }
    return null;
  }

  static List<String> validateForSave(EntryDto entryDto) {
    final errors = <String>[];

    final endTimeError = validateEndTime(entryDto);
    if (endTimeError != null) {
      errors.add(endTimeError);
    }

    final timeComparisonError = validateEndTimeAfterStartTime(entryDto);
    if (timeComparisonError != null) {
      errors.add(timeComparisonError);
    }

    return errors;
  }
}
