import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _tableName = 'daily_entries';
  late final SupabaseClient _client;

  SupabaseService() {
    _client = Supabase.instance.client;
  }

  Future<List<Map<String, dynamic>>> query({
    String? orderBy,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    var query = _client.from(_tableName).select();

    if (where != null && whereArgs != null) {
      // Construir filtros específicos conforme necessário
      query = query.eq('status', whereArgs[0]);
    }

    // if (orderBy != null) {
    //   query = query.order(orderBy.split(',')[0], ascending: false);
    // }

    final res = await query;
    final data = res;
    // TODO: Fazer tradução de chaves, lowercas/underscore to camelCase se necessário
    final response = List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    return response;
    // return data.data as List<Map<String, dynamic>>;
  }

  /*
  Future<List<Map<String, DailyEntry>>> query({
    String? orderBy,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    var query = _client.from(_tableName).select<DailyEntry>();

    if (where != null && whereArgs != null) {
      // Construir filtros específicos conforme necessário
      query = query.filter('status', 'eq', whereArgs[0]);
    }

    // if (orderBy != null && orderBy.contains(',') && query is PostgrestFilterBuilder ) {
    //   query = query?.order(orderBy.split(',')[0], ascending: false);
    // }

    return await query.execute() as List<Map<String, DailyEntry>>;
  }

*/
  Future<int> insert(Map<String, dynamic> data) async {
    final result = await _client.from(_tableName).insert([data]).select();
    return result.length;
  }

  Future<int> update(
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final result = await _client
        .from(_tableName)
        .update(data)
        .eq('id', whereArgs[0])
        .select();
    return result.length;
  }

  Future<int> delete(String where, List<dynamic> whereArgs) async {
    final result = await _client
        .from(_tableName)
        .delete()
        .eq('id', whereArgs[0])
        .select();
    return result.length;
  }
}
