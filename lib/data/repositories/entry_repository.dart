import 'dart:developer';

import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/filters/entry_filter.dart';
import 'package:driving_profits/data/services/entry_expense_service.dart';
import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';

class EntryRepository {
  final EntryService _service;
  final EntryExpenseService _entryExpenseService;

  EntryRepository(this._service, this._entryExpenseService);

  AsyncResult<dynamic> addEntry(DailyEntry dailyEntry) async {
    try {
      return await _service.insertEntry(dailyEntry.toMap());
    } on Exception catch (e, s) {
      log('Erro ao inserir: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao inserir entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult updateEntry(String entryId, DailyEntry dailyEntry) async {
    try {
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
    } on Exception catch (e, s) {
      log('Erro ao consultar: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao atualizar entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<dynamic> deleteEntry(String id) async {
    try {
      return await _service.deleteEntry(id);
    } on Exception catch (e, s) {
      log('Erro ao apagar: $e', error: e, stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao remover entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  //TODO: Implement getEntryById in EntryService
  AsyncResult<DailyEntry> getEntryById(String id) async {
    try {
      final entries = await _service.getAllEntries().then((result) {
        if (result.isError()) {
          throw Exception('Erro ao buscar entry por ID');
        }
        return result.getOrThrow();
      });
      final result = entries
          .map((e) => DailyEntry.fromMap(e))
          .firstWhere((entry) => entry.id == id);

      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<List<DailyEntry>> getEntriesByFilter(EntryFilter filter) async {
    try {
      final data = await _service.getEntriesByFilter(filters: filter);

      return data.map((result) {
        final entries = result;
        return List.generate(
          entries.length,
          (i) => DailyEntry.fromMap(entries[i]),
        );
      });
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<List<DailyEntry>> getEntries() async {
    try {
      final data = await _service.getAllEntries();
      return data.map((result) {
        final entries = result;
        return List.generate(
          entries.length,
          (i) => DailyEntry.fromMap(entries[i]),
        );
      });
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }
}
