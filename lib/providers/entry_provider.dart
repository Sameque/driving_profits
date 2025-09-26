import 'package:flutter/material.dart';
import '../models/daily_entry.dart';
import '../repositories/entry_repository.dart';

class EntryProvider with ChangeNotifier {
  final EntryRepository _repository = EntryRepository();
  List<DailyEntry> _entries = [];
  List<DailyEntry> _openEntries = []; // Lista para registros em aberto
  bool _isLoading = false;

  List<DailyEntry> get entries => _entries;
  List<DailyEntry> get openEntries => _openEntries;
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

  // Métricas para a tela de Resumo (apenas para entradas salvas)
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

  Future<void> loadEntries() async {
    _entries = await _repository.getAllEntries();
    notifyListeners();
  }

  // Inicia uma nova jornada (adiciona à lista de entradas em aberto)
  void startWorkSession(DailyEntry entry) {
    // _entries.add(entry);
    _openEntries.add(entry);
    notifyListeners();
  }

  // Finaliza a jornada (salva no banco e remove da lista de abertas)
  Future<void> closeWorkSession(DailyEntry entry) async {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);

    if (index != -1) {
      _openEntries.removeAt(index);
      // Salva no banco
      await _repository.insertEntry(entry);
      await loadEntries();
    } else {
      // Caso seja uma entrada nova, não presente em _entries
      await _repository.insertEntry(entry);
      await loadEntries();
    }
  }

  // Atualiza uma entrada em aberto (sem salvar no banco)
  void updateOpenEntry(DailyEntry entry) {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _openEntries[index] = entry;
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
    // ||
    // _openEntries.any(
    //   (e) =>
    //       e.date.year == date.year &&
    //       e.date.month == date.month &&
    //       e.date.day == date.day,
    // );
  }

  void removeOpenEntry(DailyEntry entry) {
    final index = _openEntries.indexWhere((e) => e.id == entry.id);

    if (index != -1) {
      _openEntries.removeAt(index);
      notifyListeners();
    }
  }
}
