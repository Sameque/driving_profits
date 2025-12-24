import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class StartEntryViewmodel with ChangeNotifier {
  final EntryRepository _repository;
  StartEntryViewmodel(this._repository);

  late final startWorkSessionCommand = Command1(_startWorkSession);

  AsyncResult _startWorkSession(EntryDto entry) async {
    final newEntry = DailyEntry.fromMap(entry.toMap());

    _repository.addEntry(newEntry);

    return Success(unit);
  }
}
