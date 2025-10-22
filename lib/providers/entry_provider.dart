import 'package:flutter/material.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/models/daily_entry.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _repository;
  List<DailyEntry> _entries = [];
  bool _isLoading = false;

  List<DailyEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  EntryProvider(this._repository) {
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    _entries = await _repository.getEntries();
    _isLoading = false;
    notifyListeners();
  }

  void startWorkSession(DailyEntry entry) {
    _repository.addEntry(entry.toMap());
    fetchEntries();
  }

  Future<void> closeWorkSession(DailyEntry entry) async {
    await _repository.updateEntry(entry.id, entry.toMap());
    await fetchEntries();
  }

  Future<void> updateEntry(DailyEntry entry) async {
    await _repository.updateEntry(entry.id, entry.toMap());
    await fetchEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    await fetchEntries();
  }

  Future<List<DailyEntry>> getMonthlyEntries(int year, int month) async {
    return await _repository.getEntriesByMonth(year, month);
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
}
