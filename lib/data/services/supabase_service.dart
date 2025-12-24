import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final String tableName;
  late final SupabaseClient _client;

  SupabaseService(this.tableName) {
    _client = Supabase.instance.client;
  }

  Future<List<Map<String, dynamic>>> query({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
  }) async {
    var query = _client.from(tableName).select();

    if (filters != null) {
      filters.forEach((key, value) {
        if (value == null) {
          // busca onde coluna IS NULL
          query = query.filter(key, 'is', value);
          // is_(key, 'null');
        } else if (value is List) {
          // IN (val1, val2, ...)
          query = query.filter(key, 'eq', value);
        } else {
          // igualdade simples
          query = query.eq(key, value);
        }
      });
    }

    late PostgrestTransformBuilder<PostgrestList> transformBuilder;

    if (orderBy != null && orderBy.isNotEmpty) {
      transformBuilder = query.order(
        orderBy,
        ascending: ascending,
        nullsFirst: false,
      );
    } else {
      transformBuilder = query;
    }

    if (limit != null) {
      if (offset != null) {
        transformBuilder = transformBuilder.range(offset, offset + limit - 1);
      } else {
        transformBuilder = transformBuilder.limit(limit);
      }
    }

    final res = await transformBuilder;
    // final data = res;
    final response = List<Map<String, dynamic>>.from(
      (res as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    return response;
  }

  Future<dynamic> insert(Map<String, dynamic> data) async =>
      await _client.from(tableName).insert([data]).select();

  Future<dynamic> update(Map<String, dynamic> data, String id) async =>
      await _client.from(tableName).update(data).eq('id', id).select();

  Future<dynamic> delete(String id) async =>
      await _client.from(tableName).delete().eq('id', id).select();
}
