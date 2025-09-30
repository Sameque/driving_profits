import 'package:flutter/material.dart';
import 'package:uber_tracker/ui/feature/entry/entry_dto.dart';

class CloseEntryValidations {
  /// Valida se os ganhos do Uber foram preenchidos e são maiores que zero
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

  /// Valida se a quilometragem final foi preenchida, é maior que zero e maior que a inicial
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

  /// Valida se a hora final foi selecionada
  static String? validateEndTime(EntryDto entryDto) {
    if (entryDto.endTime == null) {
      return 'Selecione a hora final';
    }
    return null;
  }

  /// Valida se a hora final é maior que a hora inicial
  static String? validateEndTimeAfterStartTime(EntryDto entryDto) {
    if (entryDto.startTime != null &&
        _isEndTimeBeforeStartTime(entryDto.startTime!, entryDto.endTime!)) {
      return 'Hora final deve ser maior que a hora inicial';
    }
    return null;
  }

  /// Verifica se a hora final é anterior à hora inicial
  static bool _isEndTimeBeforeStartTime(
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes <= startMinutes;
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
      return 'Hora final deve ser maior que a inicial (${entryDto.startTime!.format(context)})';
    }

    return null;
  }

  static bool hasEndTimeError(EntryDto entryDto) {
    return validateEndTime(entryDto) != null ||
        validateEndTimeAfterStartTime(entryDto) != null;
  }

  /// Validação completa para salvar a jornada
  static List<String> validateForSave(EntryDto entryDto) {
    final errors = <String>[];

    // Validar hora final
    final endTimeError = validateEndTime(entryDto);
    if (endTimeError != null) {
      errors.add(endTimeError);
    }

    // Validar se hora final é maior que inicial
    final timeComparisonError = validateEndTimeAfterStartTime(entryDto);
    if (timeComparisonError != null) {
      errors.add(timeComparisonError);
    }

    return errors;
  }
}
