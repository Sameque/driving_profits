import 'package:flutter/material.dart';
import 'package:driving_profits/data/repositories/expense_repository.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';
import 'package:driving_profits/domain/expense/entities/expense_entity.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseViewModel(this._repository);

  List<ExpenseDto> _expenses = [];
  List<ExpenseDto> get expenses => _expenses;

  late final loadCommand = Command0(_fetch);
  late final addCommand = Command1(_addExpense);
  late final removeCommand = Command1(_removeExpense);

  AsyncResult _fetch() async {
    final entities = await _repository.getAllExpenses();

    _expenses = entities
        .getOrThrow()
        .map((e) => ExpenseDto.fromEntity(e))
        .toList();

    return Success(unit);
  }

  AsyncResult _addExpense(ExpenseDto dto) async {
    final entity = ExpenseEntity.fromMap(dto.toMap());
    final expenseResult = await _repository.addExpense(entity);
    _expenses.add(ExpenseDto.fromEntity(expenseResult.getOrThrow()));
    dto.clear();
    loadCommand.notifyListeners();
    return Success(unit);
  }

  AsyncResult _removeExpense(int id) async {
    await _repository.removeExpense(id);
    _expenses.removeWhere((element) => element.id == id);
    loadCommand.notifyListeners();
    return Success(unit);
  }
}
