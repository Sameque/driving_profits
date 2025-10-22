import 'package:uber_tracker/data/services/expense_service.dart';
import 'package:uber_tracker/domain/expense/entities/expense_month_entity.dart';

class ExpenseRepository {
  final ExpenseService _service;

  ExpenseRepository(this._service);

  Future<void> addExpense(ExpenseMonthEntity entity) async {
    await _service.insertExpense(entity.toMap());
  }

  Future<List<ExpenseMonthEntity>> getAllExpenses() async {
    final data = await _service.fetchExpenses();
    return data.map((map) => ExpenseMonthEntity.fromMap(map)).toList();
  }

  Future<void> removeExpense(int id) async {
    await _service.deleteExpense(id);
  }
}
