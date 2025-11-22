import 'package:driving_profits/data/services/supabase_service.dart';

class EntryService {
  final SupabaseService _supabaseService;
  // static const String _tableName = 'daily_entries';

  EntryService(this._supabaseService);

  Future<List<dynamic>> getAllEntries() async {
    final data = await _supabaseService.query(
      orderBy: 'date DESC, startTime DESC',
    );
    return data;
  }

  Future<int> insertEntry(dynamic data) async {
    return await _supabaseService.insert(data);
  }

  Future<int> updateEntry(String id, dynamic data) async {
    return await _supabaseService.update(data, 'id = ?', [id]);
  }

  Future<int> deleteEntry(String id) async {
    return await _supabaseService.delete('id = ?', [id]);
  }

  Future<List<dynamic>> getEntriesByFilter(
    String where,
    List<dynamic> whereArgs,
    String? orderBy,
  ) async {
    return await _supabaseService.query(
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }
}
