import 'package:flutter/material.dart';
import 'package:uber_tracker/services/database_helper.dart';
import '../models/daily_entry.dart';
import '../repositories/entry_repository.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _repository = EntryRepository();
  List<DailyEntry> _entries = [];
  bool _isLoading = false;

  List<DailyEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // EntryProvider() {
  //   fetchEntries();
  // }

  // Future<void> fetchEntries() async {
  //   _isLoading = true;
  //   notifyListeners();
  //   _entries = await _dbHelper.getAllEntries();
  //   _isLoading = false;
  //   notifyListeners();
  // }

  // Future<void> addEntry(DailyEntry entry) async {
  //   await _dbHelper.insert(entry);
  //   await fetchEntries(); // Recarrega a lista após adicionar
  // }

  // Métricas para a tela de Resumo
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

  Future<void> addEntry(DailyEntry entry) async {
    await _repository.insertEntry(entry);
    await loadEntries();
  }

  Future<void> updateEntry(DailyEntry entry) async {
    await _repository.updateEntry(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(int id) async {
    await _repository.deleteEntry(id);
    await loadEntries();
  }

  Future<List<DailyEntry>> getMonthlyEntries(int year, int month) async {
    return await _repository.getEntriesByMonth(year, month);
  }
}
