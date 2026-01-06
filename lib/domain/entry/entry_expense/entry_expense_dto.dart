class EntryExpenseDto {
  final String entryId;
  final int expenseType;
  final int chargeType;
  final double amount;
  final String description;
  final DateTime? deletedAt;
  final bool isCalculated;

  const EntryExpenseDto({
    required this.entryId,
    required this.expenseType,
    required this.chargeType,
    required this.amount,
    required this.description,
    required this.isCalculated,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'entry_id': entryId,
      'expense_type': expenseType,
      'charge_type': chargeType,
      'amount': amount,
      'description': description,
      'deleted_at': deletedAt?.toIso8601String(),
      'calculated': isCalculated,
    };
  }

  factory EntryExpenseDto.empty(Map<String, dynamic> map) {
    return EntryExpenseDto(
      entryId: '',
      expenseType: 0,
      chargeType: 0,
      amount: 0.0,
      description: '',
      isCalculated: false,
    );
  }

  factory EntryExpenseDto.fromMap(Map<String, dynamic> map) {
    return EntryExpenseDto(
      entryId: map['entry_id'] as String,
      expenseType: map['expense_type'] as int,
      chargeType: map['charge_type'] as int,
      amount: map['amount'] as double,
      description: map['description'] as String,
      deletedAt: map['deleted_at'] != null
          ? DateTime.parse(map['deleted_at'] as String)
          : null,
      isCalculated: map['calculated'],
    );
  }
}
