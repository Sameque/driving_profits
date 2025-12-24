import 'dart:developer';

import 'package:driving_profits/data/services/supabase_service.dart';
import 'package:result_dart/result_dart.dart';

class ExpenseService {
  final SupabaseService supabaseService;

  ExpenseService(this.supabaseService);

  AsyncResult<dynamic> insertExpense(dynamic data) async {
    try {
      final result = await supabaseService.insert(data);
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao inserir: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao inserir', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<List<dynamic>> fetchExpenses() async {
    try {
      final result = await supabaseService.query(orderBy: 'created_at');
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao consultar: $e', stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao consultar', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }

  AsyncResult<dynamic> deleteExpense(int id) async {
    try {
      final result = await supabaseService.delete(id.toString());
      return Success(result);
    } on Exception catch (e, s) {
      log('Erro ao apagar: $e', error: e, stackTrace: s);
      return Failure(e);
    } catch (e, s) {
      log('Erro desconhecido ao remover', error: e, stackTrace: s);
      return Failure(Exception('Erro desconhecido'));
    }
  }
}
