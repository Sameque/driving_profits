import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/filters/entry_filter.dart';
import 'package:driving_profits/data/services/entry_expense_service.dart';
import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';

class EntryRepository {
  final EntryService _service;
  final EntryExpenseService _entryExpenseService;

  EntryRepository(this._service, this._entryExpenseService);

  AsyncResult<dynamic> addEntry(DailyEntry dailyEntry) async =>
      await _service.insertEntry(dailyEntry.toMap());

  AsyncResult updateEntry(String entryId, DailyEntry dailyEntry) async {
    final updateResult = await _service.updateEntry(
      entryId,
      dailyEntry.toMap(),
    );
    if (updateResult.isError()) {
      return updateResult;
    }

    final deleteResult = await _entryExpenseService
        .deleteEntryExpensesByEntryId(entryId);

    if (deleteResult.isError()) {
      return deleteResult;
    }

    if (dailyEntry.entryExpenses != null &&
        dailyEntry.entryExpenses!.isNotEmpty) {
      for (final expense in dailyEntry.entryExpenses!) {
        final insertResult = await _entryExpenseService.insertEntryExpense(
          expense.toMap(),
        );
        if (insertResult.isError()) return insertResult;
      }
    }

    return Success(unit);
  }

  AsyncResult<dynamic> deleteEntry(String id) async =>
      await _service.deleteEntry(id);

  //TODO: Implement getEntryById in EntryService
  Future<DailyEntry> getEntryById(String id) async {
    final data = await _service.getAllEntries().then((result) {
      if (result.isError()) {
        throw Exception('Erro ao buscar entry por ID');
      }
      return result.getOrThrow();
    });
    return data
        .map((e) => DailyEntry.fromMap(e))
        .firstWhere((entry) => entry.id == id);
  }

  AsyncResult<List<DailyEntry>> getEntriesByFilter(EntryFilter filter) async {
    final data = await _service.getEntriesByFilter(filters: filter);

    return data.map((result) {
      final entries = result;
      return List.generate(
        entries.length,
        (i) => DailyEntry.fromMap(entries[i]),
      );
    });
  }

  AsyncResult<List<DailyEntry>> getEntries() async {
    final data = await _service.getAllEntries();
    return data.map((result) {
      final entries = result;
      return List.generate(
        entries.length,
        (i) => DailyEntry.fromMap(entries[i]),
      );
    });
  }
}
