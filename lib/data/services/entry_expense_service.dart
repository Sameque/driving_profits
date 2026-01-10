import 'dart:developer';

import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:result_dart/result_dart.dart';

class EntryExpenseService {
  final SupabaseService supabaseService;

  EntryExpenseService(this.supabaseService);

  AsyncResult insertEntryExpense(dynamic data) async {
    try {
      await supabaseService.insert(data);
      return Success(unit);
    } on Exception catch (e, s) {
      log('Erro ao inserir entry expense: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log(
        'Erro desconhecido ao inserir entry expense',
        error: e,
        stackTrace: s,
      );
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult deleteEntryExpensesByEntryId(String entryId) async {
    try {
      await supabaseService.deleteWhere({'entry_id': entryId});
      return Success(unit);
    } on Exception catch (e, s) {
      log('Erro ao deletar entry expenses: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log(
        'Erro desconhecido ao deletar entry expenses',
        error: e,
        stackTrace: s,
      );
      return Failure(Exception('Erro desconhecido'));
    }
  }
}
