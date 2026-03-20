import 'package:flutter/foundation.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/data/repositories/expense_repository.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';

class EditEntryViewModel with ChangeNotifier {
  final EntryRepository _repository;
  final ExpenseRepository _expenseRepository;

  EditEntryViewModel(this._repository, this._expenseRepository);

  late final updateCommand = Command1(_updateEntry);
  late final getExpensesCommand = Command0(_getExpenses);

  bool _hasUnsavedChanges = false;

  bool get hasUnsavedChanges => _hasUnsavedChanges;

  void markAsUnsaved() {
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void markAsSaved() {
    _hasUnsavedChanges = false;
    notifyListeners();
  }

  /// Atualiza uma entrada existente no repositório.
  ///
  /// Recebe uma [DailyEntry] com os campos atualizados e salva no repositório.
  /// Em caso de erro, a mensagem fica disponível via propriedade [error].
  AsyncResult _updateEntry(EntryDto entryDto) async {
    final updated = DailyEntry.fromMap(entryDto.toMap());

    await _repository.updateEntry(entryDto.id, updated);

    markAsSaved();
    return Success(unit);
  }

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
}
