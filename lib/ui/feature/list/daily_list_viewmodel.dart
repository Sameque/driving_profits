import 'package:flutter/material.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';

class DailyListViewmodel extends ChangeNotifier {
  final EntryRepository _repository;

  DailyListViewmodel(this._repository) {
    fetchEntries();
  }

  List<EntryDto> _entries = [];
  bool _isLoading = false;

  List<EntryDto> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchEntries() async {
    _isLoading = true;
    notifyListeners();

    final data = await _repository.getEntries();

    _entries = data.map((e) => EntryDto.fromMap(e.toMap())).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    await fetchEntries();
  }

  String calculaHoraTotal(TimeOfDay inicio, TimeOfDay fim) {
    try {
      final inicioMin = inicio.hour * 60 + inicio.minute;
      final fimMin = fim.hour * 60 + fim.minute;
      final totalMin = fimMin - inicioMin;
      final horas = (totalMin ~/ 60).abs();
      final minutos = (totalMin % 60).abs();
      return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
    } catch (_) {
      return "-";
    }
  }
}
