import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:flutter/material.dart';

class ExpensesViewmodel with ChangeNotifier {
  final EntryRepository _repository;

  ExpensesViewmodel(this._repository);

  bool _isLoading = false;
  String? _error;
  bool _hasUnsavedChanges = false;

  bool get isLoading => _isLoading;

  String? get error => _error;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markAsUnsaved() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void markAsSaved() {
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Atualiza uma entrada existente no repositório.
  ///
  /// Recebe uma [DailyEntry] com os campos atualizados e salva no repositório.
  /// Em caso de erro, a mensagem fica disponível via propriedade [error].
  Future<void> updateEntry(DailyEntry entry) async {
    try {
      _setError(null);
      _setLoading(true);

      await _repository.updateEntry(
        entry.id,
        DailyEntry.fromMap(entry.toMap()),
      );
      markAsSaved();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
