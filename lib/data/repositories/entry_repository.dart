import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/data/services/entry_expense_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:result_dart/result_dart.dart';

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
    if (updateResult.isError()) return updateResult;

    if (dailyEntry.entryExpenses != null &&
        dailyEntry.entryExpenses!.isNotEmpty) {
      // Delete existing entry expenses
      final deleteResult = await _entryExpenseService
          .deleteEntryExpensesByEntryId(entryId);
      if (deleteResult.isError()) return deleteResult;

      // Insert new entry expenses
      for (final expense in dailyEntry.entryExpenses!) {
        final data = {
          'entry_id': entryId,
          'expense_type': expense.expenseType.index,
          'charge_type': expense.chargeType.index,
          'amount': expense.amount,
          'description': expense.description,
          'calculated': false, // Not calculated, manual update
        };

        final insertResult = await _entryExpenseService.insertEntryExpense(
          data,
        );
        if (insertResult.isError()) return insertResult;
      }
    }

    return Success(unit);
  }

  AsyncResult<dynamic> deleteEntry(String id) async =>
      await _service.deleteEntry(id);

  AsyncResult closeEntry(DailyEntry entry) async {
    if (entry.entryExpenses != null && entry.entryExpenses!.isNotEmpty) {
      //deleção das despesas calculadas antigas antes de inserir as novas
      // await _service.deleteentryExpensesByEntryId(entry.id);

      //inclusão das despesas calculadas
      for (final expense in entry.entryExpenses!) {
        final data = {
          'entry_id': entry.id,
          'expense_type': expense.expenseType.index,
          'charge_type': expense.chargeType.index,
          'amount': expense.amount,
          'description': expense.description,
          'calculated':
              true, // Sempre true para gastos calculados no fechamento
        };

        await _entryExpenseService.insertEntryExpense(data);
      }
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
