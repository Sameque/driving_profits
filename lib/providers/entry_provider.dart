import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../repositories/entry_repository.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _repository = EntryRepository();
  List<DailyEntry> _entries = [];
  bool _isLoading = false;

  List<DailyEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  EntryProvider() {
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _repository.getAllEntries();
    _isLoading = false;
    notifyListeners();
  }

  double get totalGains {
    return _entries.fold(0.0, (sum, item) => sum + item.totalGains);
  }

  double get totalExpenses {
    return _entries.fold(0.0, (sum, item) => sum + item.totalExpenses);
  }

  double get totalNetProfit {
    return totalGains - totalExpenses;
  }

  double get totalKmDriven {
    return _entries.fold(0.0, (sum, item) => sum + item.kmDriven);
  }

  double get averageGainPerKm {
    if (totalKmDriven == 0) return 0;
    return totalGains / totalKmDriven;
  }

  Future<void> loadEntries() async {
    _entries = await _repository.getAllEntries();
    notifyListeners();
  }

  void startWorkSession(DailyEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  Future<void> closeWorkSession(DailyEntry entry) async {
    final index = _entries.indexWhere(
      (e) =>
          e.date.year == entry.date.year &&
          e.date.month == entry.date.month &&
          e.date.day == entry.date.day,
    );

    if (index != -1) {
      _entries.removeAt(index);
      await _repository.insertEntry(entry);
      await loadEntries();
    } else {
      await _repository.insertEntry(entry);
      await loadEntries();
    }
  }

  void updateOpenEntry(DailyEntry entry) {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> updateEntry(DailyEntry entry) async {
    await _repository.updateEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    await loadEntries();
  }

  Future<List<DailyEntry>> getMonthlyEntries(int year, int month) async {
    return await _repository.getEntriesByMonth(year, month);
  }

  bool entryExistsForDate(DateTime date) {
    return _entries.any(
      (e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day,
    );
  }
}
