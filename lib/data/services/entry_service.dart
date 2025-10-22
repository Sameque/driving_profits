import 'package:driving_profits/data/services/database_service.dart';

class EntryService {
  final DatabaseService _dbService;
  static const String _tableName = 'daily_entries';

  EntryService(this._dbService);

  Future<List<dynamic>> getAllEntries() async {
    final data = await _dbService.query(
      _tableName,
      orderBy: 'date DESC, startTime DESC',
    );
    return data;
  }

  Future<int> insertEntry(dynamic data) async {
    return await _dbService.insert(_tableName, data);
  }

  Future<int> updateEntry(String id, dynamic data) async {
    return await _dbService.update(_tableName, data, 'id = ?', [id]);
  }

  Future<int> deleteEntry(String id) async {
    return await _dbService.delete(_tableName, 'id = ?', [id]);
  }

  Future<List<dynamic>> getEntriesByFilter(
    String where,
    List<dynamic> whereArgs,
    String? orderBy,
  ) async {
    final data = await _dbService.query(
      _tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
    return data;
  }
}
