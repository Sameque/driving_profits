import 'dart:developer';

import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class StartEntryViewmodel with ChangeNotifier {
  final EntryRepository _repository;
  StartEntryViewmodel(this._repository);

  late final startWorkSessionCommand = Command1(_startWorkSession);

  AsyncResult _startWorkSession(EntryDto entry) async {
    try {
      final newEntry = DailyEntry.fromMap(entry.toMap());

      _repository.addEntry(newEntry);

      return Success(unit);
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao atualizar entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }
}
