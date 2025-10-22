import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:uber_tracker/data/repositories/expense_repository.dart';
import 'package:uber_tracker/domain/expense/dtos/expense_month_dto.dart';
import 'package:uber_tracker/domain/expense/entities/expense_month_entity.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseViewModel(this._repository) {
    loadExpenses();
  }

  List<ExpenseMonthDto> _expenses = [];
  bool _isLoading = false;

  List<ExpenseMonthDto> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    final entities = await _repository.getAllExpenses();

    _expenses = entities
        .map((e) => ExpenseMonthDto.fromMap(e.toMap()))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(ExpenseMonthDto dto) async {
    final entity = ExpenseMonthEntity.fromMap(dto.toMap());
    await _repository.addExpense(entity);
    await loadExpenses();
  }

  Future<void> removeExpense(int id) async {
    try {
      await _repository.removeExpense(id);
    } catch (e) {
      log("Erro ao remover despesa: $e");
    } finally {
      await loadExpenses();
    }
  }
}
