import 'package:flutter/foundation.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

/// ViewModel responsável por operações relacionadas ao fechamento de uma jornada.
///
/// Este ViewModel encapsula a dependência no repositório de entradas e
/// expõe um método `closeWorkSession` que replica a lógica usada em
/// `EntryProvider.closeWorkSession` (atualiza a entrada e expõe estados de
/// carregamento/erro para a UI).
class CloseEntryViewModel with ChangeNotifier {
  final EntryRepository _repository;

  CloseEntryViewModel(this._repository);

  late final closeCommand = Command1(_closeWorkSession);

  /// Fecha a jornada atualizando a entrada no repositório.
  ///
  /// Recebe uma [DailyEntry] já com os campos atualizados (status = closed,
  /// endDate/endTime etc.). Retorna [true] em caso de sucesso ou lança uma
  /// exceção em caso de falha. O estado de carregamento e a mensagem de erro
  /// ficam disponíveis via `isLoading` e `error`.
  AsyncResult _closeWorkSession(DailyEntry entry) async {
    return _repository.updateEntry(entry.id, entry);
  }
}
