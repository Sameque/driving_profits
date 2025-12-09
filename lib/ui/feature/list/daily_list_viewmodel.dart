import 'package:flutter/material.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class DailyListViewmodel extends ChangeNotifier {
  final EntryRepository _repository;

  DailyListViewmodel(this._repository) {
    fetchCommand.execute();
  }

  late final fetchCommand = Command0(_fetchEntries);

  List<EntryDto> _entries = [];

  List<EntryDto> get entries => _entries;

  Future updateEntryLocal(EntryDto updatedEntry) async {
    final index = _entries.indexWhere((entry) => entry.id == updatedEntry.id);
    if (index > -1) {
      _entries[index] = updatedEntry;
      _entries.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future addEntryLocal(EntryDto newEntry) async {
    _entries.add(newEntry);
    _entries.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  AsyncResult _fetchEntries() async {
    final data = await _repository.getEntries();

    _entries = data.map((e) => EntryDto.fromDailyEntry(e)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();

    return Success(unit);
  }

  late final deleteCommand = Command1(_deleteEntry);

  AsyncResult<Result<dynamic>> _deleteEntry(String id) async {
    final result = await _repository.deleteEntry(id);

    if (result.isError()) return Failure(Exception('Erro ao deletar entrada'));

    _entries.removeWhere((entry) => entry.id == id);

    return Success(result);
  }
}
