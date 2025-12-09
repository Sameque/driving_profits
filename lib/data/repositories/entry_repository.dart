import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:result_dart/result_dart.dart';

class EntryRepository {
  final EntryService _service;

  EntryRepository(this._service);

  AsyncResult<dynamic> addEntry(DailyEntry dailyEntry) async =>
      await _service.insertEntry(dailyEntry.toMap());

  Future<void> updateEntry(String id, DailyEntry dailyEntry) async =>
      await _service.updateEntry(id, dailyEntry.toMap());

  AsyncResult<dynamic> deleteEntry(String id) async =>
      await _service.deleteEntry(id);

  //TODO: Implement getEntryById in EntryService
  Future<DailyEntry> getEntryById(String id) async {
    final data = await _service.getAllEntries().then((result) {
      if (result.isError()) {
        throw Exception('Erro ao buscar entry por ID');
      }
      return result.getOrThrow();
    });
    return data
        .map((e) => DailyEntry.fromMap(e))
        .firstWhere((entry) => entry.id == id);
  }

  Future<List<DailyEntry>> getEntries() {
    final data = _service.getAllEntries();
    return data.then((result) {
      if (result.isError()) {
        return [];
      }
      final entries = result.getOrThrow();
      return List.generate(
        entries.length,
        (i) => DailyEntry.fromMap(entries[i]),
      );
    });
  }

  Future<List<DailyEntry>> getEntriesByMonth(int year, int month) async {
    final data = await _service.getEntriesByFilter(
      filters: {
        'start_date': [
          '$year-${month.toString().padLeft(2, '0')}-01',
          '$year-${month.toString().padLeft(2, '0')}-31',
        ],
      },
      orderBy: 'start_date DESC, start_time DESC',
    );

    return List.generate(data.length, (i) => DailyEntry.fromMap(data[i]));
  }
}
