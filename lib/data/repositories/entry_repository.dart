import 'package:uber_tracker/data/services/entry_service.dart';
import 'package:uber_tracker/models/daily_entry.dart';

class EntryRepository {
  final EntryService _service;

  EntryRepository(this._service);

  Future<void> addEntry(Map<String, dynamic> entryData) async {
    await _service.insertEntry(entryData);
  }

  Future<void> updateEntry(String id, Map<String, dynamic> entryData) async {
    await _service.updateEntry(id, entryData);
  }

  Future<void> deleteEntry(String id) async {
    await _service.deleteEntry(id);
  }

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
}
