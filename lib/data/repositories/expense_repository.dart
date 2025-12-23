import 'package:driving_profits/data/services/expense_service.dart';
import 'package:driving_profits/domain/expense/entities/expense_entity.dart';
import 'package:result_dart/result_dart.dart';

class ExpenseRepository {
  final ExpenseService _service;

  ExpenseRepository(this._service);

  AsyncResult<ExpenseEntity> addExpense(ExpenseEntity entity) async {
    final result = await _service.insertExpense(entity.toMap());
    final data = result.map((e) => ExpenseEntity.fromMap((e as List).first));
    return data;
  }

  AsyncResult<List<ExpenseEntity>> getAllExpenses() async {
    final data = await _service.fetchExpenses();

    return data.map(
      (list) =>
          list.map<ExpenseEntity>((e) => ExpenseEntity.fromMap(e)).toList(),
    );
  }

  AsyncResult removeExpense(int id) async {
    await _service.deleteExpense(id);
    return Success(unit);
  }
}
