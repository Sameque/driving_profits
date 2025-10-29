import 'package:driving_profits/data/services/entry_service.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';

class EntryRepository {
  final EntryService _service;

  EntryRepository(this._service);

  Future<void> addEntry(DailyEntry dailyEntry) async {
    await _service.insertEntry(dailyEntry.toMap());
  }

  Future<void> updateEntry(String id, DailyEntry dailyEntry) async {
    await _service.updateEntry(id, dailyEntry.toMap());
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
  }

  //TODO: Implement getEntryById in EntryService
  Future<DailyEntry> getEntryById(String id) {
    final data = _service.getAllEntries();
    return data.then(
      (list) => List.generate(
        list.length,
        (i) => DailyEntry.fromMap(list[i]),
      ).firstWhere((entry) => entry.id == id),
    );
  }

  Future<List<DailyEntry>> getEntries() {
    final data = _service.getAllEntries();
    return data.then(
      (list) => List.generate(list.length, (i) => DailyEntry.fromMap(list[i])),
    );
  }

  Future<List<DailyEntry>> getEntriesByMonth(int year, int month) async {
    final data = await _service.getEntriesByFilter(
      'strftime("%Y-%m", date) = ?',
      ['${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}'],
      null,
    );

    return List.generate(data.length, (i) => DailyEntry.fromMap(data[i]));
  }
}
