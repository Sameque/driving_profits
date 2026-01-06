import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';

class EntryListViewmodel extends ChangeNotifier {
  final EntryRepository _repository;

  EntryListViewmodel(this._repository);

  late final fetchCommand = Command0(_fetchEntries);
  late final deleteCommand = Command1(_deleteEntry);

  List<EntryDto> _entries = [];
  List<EntryDto> get entries => _entries;

  Future updateEntryLocal(EntryDto updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index > -1) {
      _entries[index] = updatedEntry;
      _entries.sort((a, b) => b.date.compareTo(a.date));
      fetchCommand.notifyListeners();
    }
  }

  Future addEntryLocal(EntryDto newEntry) async {
    _entries.add(newEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    fetchCommand.notifyListeners();
  }

  AsyncResult _fetchEntries() async {
    final data = await _repository.getEntries();

    _entries = data
        .getOrThrow()
        .map((e) => EntryDto.fromDailyEntry(e))
        .toList();

    return Success(unit);
  }

  AsyncResult<Result<dynamic>> _deleteEntry(String id) async {
    final result = await _repository.deleteEntry(id);
    _entries.removeWhere((entry) => entry.id == id);

    return Success(result);
  }
}
