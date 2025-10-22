import 'dart:developer';

import 'package:uber_tracker/data/services/database_service.dart';

class ExpenseService {
  final DatabaseService _dbService;
  static const String _tableName = 'expenses';

  ExpenseService(this._dbService);

  Future<int> insertExpense(dynamic data) async {
    return await _dbService.insert(_tableName, data);
  }

  Future<List<Map<String, dynamic>>> fetchExpenses() async {
    return await _dbService.query(_tableName, orderBy: 'id DESC');
  }

  Future<int> deleteExpense(int id) async {
    return await _dbService.delete(_tableName, 'id = ?', [id]);
  }
}
