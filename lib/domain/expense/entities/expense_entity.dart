import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';

class ExpenseEntity {
  final int? id;
  final ExpenseType expenseType;
  final ChargeType chargeType;
  final double amount;
  final String description;

  ExpenseEntity({
    this.id,
    required this.expenseType,
    required this.chargeType,
    required this.amount,
    required this.description,
  });

  factory ExpenseEntity.fromMap(Map<String, dynamic> map) {
    return ExpenseEntity(
      id: map['id'],
      expenseType: ExpenseType.values[map['expense_type'] ?? 0],
      chargeType: ChargeType.values[map['charge_type'] ?? 0],
      amount: map['amount'] ?? 0.0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'expense_type': expenseType.value,
      'charge_type': chargeType.value,
      'amount': amount,
      'description': description,
    };
    if (id != null) {
      map['id'] = id!;
    }
    return map;
  }
}
