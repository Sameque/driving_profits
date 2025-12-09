import 'dart:developer';

import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:result_dart/result_dart.dart';

class EntryService {
  final SupabaseService _supabaseService;

  EntryService(this._supabaseService);

  AsyncResult<List<dynamic>> getAllEntries() async {
    try {
      final result = await _supabaseService.query(orderBy: 'start_date');
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
      final result = await _supabaseService.insert(data);
      return Success(result);
    } on Exception catch (e, s) {
      log('Error inserting entry: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao inserir entry', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult updateEntry(String id, dynamic data) async {
    try {
      final result = await _supabaseService.update(data, id);
      return Success(result);
    } on Exception catch (e) {
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao atualizar entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<dynamic> deleteEntry(String id) async {
    try {
      final result = await _supabaseService.delete(id);
      return Success(result);
    } on Exception catch (e, s) {
      log('Error deleting entry: $e', error: e, stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao remover entrada', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  Future<List<dynamic>> getEntriesByFilter({
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
    bool ascending = false,
  }) async {
    return await _supabaseService.query(
      filters: filters,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      ascending: ascending,
    );
  }
}
