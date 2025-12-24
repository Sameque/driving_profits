import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class ExpensesViewmodel with ChangeNotifier {
  final EntryRepository _repository;

  ExpensesViewmodel(this._repository);

  late final updateCommand = Command1(_updateEntry);

  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markAsUnsaved() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void markAsSaved() {
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  AsyncResult _updateEntry(EntryDto entryDto) async {
    final updated = DailyEntry.fromMap(entryDto.toMap());

    await _repository.updateEntry(updated.id, updated);

    markAsSaved();

    return Success(unit);
  }
}
