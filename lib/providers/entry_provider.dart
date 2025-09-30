import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../repositories/entry_repository.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _repository = EntryRepository();
  final List<DailyEntry> _openEntries = [];
  List<DailyEntry> _entries = [];
  bool _isLoading = false;

  List<DailyEntry> get entries => _entries;
  List<DailyEntry> get openEntries => _openEntries;
  bool get isLoading => _isLoading;

  EntryProvider() {
    fetchEntries();
  }

  Future<void> fetchEntries() async {
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

  int get totalKmDriven {
    return _entries.fold(0, (sum, item) => sum + (item.kmEnd! - item.kmStart!));
  }

  double get averageGainPerKm {
    if (totalKmDriven == 0) return 0;
    return totalGains / totalKmDriven;
  }

  void startWorkSession(DailyEntry entry) {
    _openEntries.add(entry);
    notifyListeners();
  }

  Future<void> closeWorkSession(DailyEntry entry) async {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);

    if (index != -1) {
      _openEntries.removeAt(index);
    }

    await _repository.insertEntry(entry);
    await fetchEntries();
  }

  void updateOpenEntry(DailyEntry entry) {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _openEntries[index] = entry;
      notifyListeners();
    }
  }

  Future<void> updateEntry(DailyEntry entry) async {
    await _repository.updateEntry(entry);
    await fetchEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    await fetchEntries();
  }

  Future<List<DailyEntry>> getMonthlyEntries(int year, int month) async {
    return await _repository.getEntriesByMonth(year, month);
  }

  void removeOpenEntry(DailyEntry entry) {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);

    if (index != -1) {
      _openEntries.removeAt(index);
      notifyListeners();
    }
  }
}
