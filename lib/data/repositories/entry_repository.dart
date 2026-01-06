import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/data/services/calculated_expense_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:result_dart/result_dart.dart';

class EntryRepository {
  final EntryService _service;
  final CalculatedExpenseService _calculatedExpenseService;

  EntryRepository(this._service, this._calculatedExpenseService);

  AsyncResult<dynamic> addEntry(DailyEntry dailyEntry) async =>
      await _service.insertEntry(dailyEntry.toMap());

  AsyncResult updateEntry(String id, DailyEntry dailyEntry) async =>
      await _service.updateEntry(id, dailyEntry.toMap());

  AsyncResult<dynamic> deleteEntry(String id) async =>
      await _service.deleteEntry(id);

  AsyncResult closeEntry(
    DailyEntry entry,
    List<Map<String, dynamic>> calculatedExpenses,
  ) async {
    // Update the entry
    // final updateResult =

    // Insert calculated expenses
    for (final expense in calculatedExpenses) {
      final data = {
        'entry_id': entry.id,
        'expense_type': expense['expense_type'],
        'charge_type': expense['charge_type'],
        'amount': expense['cost'],
        'description': expense['description'],
      };

      // final insertResult =
      await _calculatedExpenseService.insertCalculatedExpense(data);

      // if (insertResult.isSuccess()) {
      // if (insertResult.isError()) return insertResult;
      // if (updateResult.isError()) return updateResult;
      // }
    }

    await updateEntry(entry.id, entry);

    return Success(unit);
  }

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
