import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/ui/feature/entry/entry_dto.dart';
import 'package:flutter/material.dart';

class StartEntryViewmodel with ChangeNotifier {
  final EntryRepository _repository;
  StartEntryViewmodel(this._repository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future startWorkSession(EntryDto entry) async {
    try {
      _setError(null);
      _setLoading(true);

      _repository.addEntry(DailyEntry.fromMap(entry.toMap()));
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
