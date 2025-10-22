class ExpenseMonthEntity {
  final int? id;
  final int type;
  final double amount;

  ExpenseMonthEntity({this.id, required this.type, required this.amount});

  factory ExpenseMonthEntity.fromMap(Map<String, dynamic> map) {
    return ExpenseMonthEntity(
      id: map['id'],
      type: int.parse(map['type']),
      amount: map['amount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type.toString(), 'amount': amount};
  }
}
