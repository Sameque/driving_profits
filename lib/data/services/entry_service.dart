import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/filters/entry_filter.dart';
import 'package:driving_profits/data/filters/filter.dart';
import 'package:driving_profits/data/services/supabase_service.dart';

class EntryService {
  final SupabaseService supabaseService;

  EntryService(this.supabaseService);

  AsyncResult<List<dynamic>> getAllEntries() async {
    final result = await supabaseService.query(
      selectFields: '*, entry_expenses(*)',
      orderBy: 'start_date',
    );
    return Success(result);
  }

  AsyncResult<dynamic> insertEntry(dynamic data) async {
    final result = await supabaseService.insert(data);
    return Success(result);
  }

  AsyncResult updateEntry(String id, dynamic data) async {
    final result = await supabaseService.update(data, id);
    return Success(result);
  }

  AsyncResult<dynamic> deleteEntry(String id) async {
    final result = await supabaseService.delete(id);
    return Success(result);
  }

  AsyncResult<List<dynamic>> getEntriesByFilter({
    EntryFilter? filters,
    String? orderBy,
    int? limit,
    int? offset,
    bool ascending = false,
  }) async {
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
  }
}
