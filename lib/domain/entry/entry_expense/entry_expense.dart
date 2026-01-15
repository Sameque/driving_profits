import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:uuid/uuid.dart';

class EntryExpense {
  final String id;
  final String entryId;
  final ExpenseType expenseType;
  final ChargeType chargeType;
  final double amount;
  final String description;
  late DateTime? createdAt;
  late DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool calculated;

  EntryExpense({
    String? id,
    required this.entryId,
    required this.expenseType,
    required this.chargeType,
    required this.amount,
    required this.description,
    required this.calculated,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'entry_id': entryId,
      'expense_type': expenseType.index,
      'charge_type': chargeType.index,
      'amount': amount,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'calculated': calculated,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  factory EntryExpense.fromMap(Map<String, dynamic> map) {
    return EntryExpense(
      id: map['id'] as String? ?? '',
      entryId: map['entry_id'] as String,
      expenseType: ExpenseType.values[map['expense_type'] ?? 0],
      chargeType: ChargeType.values[map['charge_type'] ?? 0],
      amount: map['amount'] as double,
      description: map['description'] as String? ?? '',
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'] as String),
      updatedAt: map['updated_at'] == null
          ? null
          : DateTime.tryParse(map['updated_at'] as String),
      deletedAt: map['deleted_at'] == null
          ? null
          : DateTime.tryParse(map['deleted_at'] as String),
      calculated: map['calculated'] as bool,
    );
  }
}
