import 'package:flutter/foundation.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';

/// ViewModel responsável por operações relacionadas ao fechamento de uma jornada.
///
/// Este ViewModel encapsula a dependência no repositório de entradas e
/// expõe um método `closeWorkSession` que replica a lógica usada em
/// `EntryProvider.closeWorkSession` (atualiza a entrada e expõe estados de
/// carregamento/erro para a UI).
class CloseEntryViewModel with ChangeNotifier {
  final EntryRepository _repository;

  CloseEntryViewModel(this._repository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Fecha a jornada atualizando a entrada no repositório.
  ///
  /// Recebe uma [DailyEntry] já com os campos atualizados (status = closed,
  /// endDate/endTime etc.). Retorna [true] em caso de sucesso ou lança uma
  /// exceção em caso de falha. O estado de carregamento e a mensagem de erro
  /// ficam disponíveis via `isLoading` e `error`.
  Future<void> closeWorkSession(DailyEntry entry) async {
    try {
      _setError(null);
      _setLoading(true);
      await _repository.updateEntry(entry.id, entry);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
