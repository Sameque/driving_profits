import 'package:flutter/foundation.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/data/repositories/expense_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';

/// ViewModel responsável por operações relacionadas ao fechamento de uma jornada.
///
/// Este ViewModel encapsula a dependência no repositório de entradas e
/// expõe um método `closeWorkSession` que replica a lógica usada em
/// `EntryProvider.closeWorkSession` (atualiza a entrada e expõe estados de
/// carregamento/erro para a UI).
class CloseEntryViewModel with ChangeNotifier {
  final EntryRepository _entryRepository;
  final ExpenseRepository _expenseRepository;

  CloseEntryViewModel(this._entryRepository, this._expenseRepository);

  late final closeCommand = Command1(_closeWorkSession);
  late final getExpensesCommand = Command0(_getExpenses);

  /// Calcula as despesas baseadas no tipo de cobrança por km.
  ///
  /// Retorna uma lista de mapas com 'description', 'cost', 'expense_type' e 'charge_type' para despesas
  /// do tipo valuePerKm multiplicadas pelo total de km.
  AsyncResult<List<ExpenseDto>> _getExpenses() async {
    final result = await _expenseRepository.getAllExpenses();

    final List<ExpenseDto> expenseDtos = result.fold(
      (expenses) => expenses
          .map((expense) => ExpenseDto.fromMap(expense.toMap()))
          .toList(),
      (e) => [],
    );
    return Success(expenseDtos);
  }

  /// Fecha a jornada atualizando a entrada no repositório e inserindo os gastos calculados.
  ///
  /// Recebe uma [DailyEntry] já com os campos atualizados (status = closed,
  /// endDate/endTime etc.). Retorna [true] em caso de sucesso ou lança uma
  /// exceção em caso de falha. O estado de carregamento e a mensagem de erro
  /// ficam disponíveis via `isLoading` e `error`.
  AsyncResult _closeWorkSession(EntryDto entryDto) async {
    final entryEntity = DailyEntry.fromMap(entryDto.toMap());
    return _entryRepository.closeEntry(entryEntity);
  }
}
