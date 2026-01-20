import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:driving_profits/data/filters/filter.dart';

class SupabaseService {
  final String tableName;
  late final SupabaseClient _client;

  SupabaseService(this.tableName) {
    _client = Supabase.instance.client;
  }

  Future<List<Map<String, dynamic>>> query({
    List<Filter>? filters,
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    String? selectFields,
  }) async {
    var query = _client.from(tableName).select(selectFields ?? '*');

    if (filters != null) {
      for (var filter in filters) {
        query = query.filter(
          filter.column,
          filter.operator.value,
          filter.value,
        );
      }
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

  Future<dynamic> deleteWhere(Map<String, dynamic> filters) async {
    var query = _client.from(tableName).delete();
    filters.forEach((key, value) {
      query = query.eq(key, value);
    });
    return await query.select();
  }
}
