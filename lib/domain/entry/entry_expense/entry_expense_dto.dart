import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:uuid/uuid.dart';

class EntryExpenseDto {
  late String id;
  final String entryId;
  final ChargeType chargeType;
  final DateTime? deletedAt;
  final bool isCalculated;
  late String description;
  late double amount;
  late ExpenseType expenseType;

  EntryExpenseDto({
    required this.entryId,
    required this.expenseType,
    required this.chargeType,
    required this.amount,
    required this.description,
    required this.isCalculated,
    this.deletedAt,
    this.id = '',
  });

  //seters
  void setAmount(String value) {
    amount = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }

  void setDescription(String value) {
    description = value;
  }

  void setExpenseType(ExpenseType? value) {
    expenseType = value ?? ExpenseType.none;
  }

  Map<String, dynamic> toMap() {
    return {
      'entry_id': entryId,
      'expense_type': expenseType.index,
      'charge_type': chargeType.index,
      'amount': amount,
      'description': description,
      'deleted_at': deletedAt?.toIso8601String(),
      'calculated': isCalculated,
    };
  }

  factory EntryExpenseDto.notCalculated(String entryId) {
    return EntryExpenseDto(
      id: Uuid().v4(),
      entryId: entryId,
      expenseType: ExpenseType.none,
      chargeType: ChargeType.none,
      amount: 0.0,
      description: '',
      isCalculated: false,
    );
  }

  factory EntryExpenseDto.fromMap(Map<String, dynamic> map) {
    return EntryExpenseDto(
      entryId: map['entry_id'] as String,
      expenseType: ExpenseType.values[map['expense_type'] as int],
      chargeType: ChargeType.values[map['charge_type'] as int],
      amount: map['amount'] as double,
      description: map['description'] as String,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      isCalculated: map['calculated'],
    );
  }
}
