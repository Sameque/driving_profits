import 'dart:developer';

import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/filters/entry_filter.dart';
import 'package:driving_profits/data/filters/filter.dart';
import 'package:driving_profits/data/services/supabase_service.dart';

class EntryService {
  final SupabaseService supabaseService;

  EntryService(this.supabaseService);

  AsyncResult<List<dynamic>> getAllEntries() async {
    try {
      final result = await supabaseService.query(
        selectFields: '*, entry_expenses(*)',
        orderBy: 'start_date',
      );
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<dynamic> insertEntry(dynamic data) async {
    try {
      final result = await supabaseService.insert(data);
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao inserir: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao inserir entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult updateEntry(String id, dynamic data) async {
    try {
      final result = await supabaseService.update(data, id);
      return Success(result);
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
      final result = await supabaseService.delete(id);
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao apagar: $e', error: e, stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao remover entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<List<dynamic>> getEntriesByFilter({
    EntryFilter? filters,
    String? orderBy,
    int? limit,
    int? offset,
    bool ascending = false,
  }) async {
    try {
      final List<Filter>? filterMap = filters?.toFilterList();
      final result = await supabaseService.query(
        filters: filterMap,
        selectFields: '*, entry_expenses(*)',
        orderBy: orderBy,
        limit: limit,
        offset: offset,
        ascending: ascending,
      );

      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<dynamic> insertCalculatedExpense(dynamic data) async {
    try {
      final result = await supabaseService.insert(data);
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao inserir calculated expense: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log(
        'Erro desconhecido ao inserir calculated expense',
        error: e,
        stackTrace: s,
      );
      return Failure(Exception('Erro desconhecido'));
    }
  }
}
