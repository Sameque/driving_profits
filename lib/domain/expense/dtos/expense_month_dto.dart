import 'package:driving_profits/domain/expense/expense_month_type.dart';

class ExpenseMonthDto {
  final int? _id;
  ExpenseMonthType _type;
  double _amount;

  ExpenseMonthDto({
    required ExpenseMonthType type,
    required double amount,
    int? id,
  }) : _type = type,
       _amount = amount,
       _id = id;

  ExpenseMonthType get type => _type;
  void setType(ExpenseMonthType? value) =>
      _type = value ?? ExpenseMonthType.none;

  double get amount => _amount;
  void setAmount(String value) =>
      _amount = double.parse(value.isEmpty ? '0' : value);

  int? get id => _id;

  factory ExpenseMonthDto.fromMap(Map<String, dynamic> map) {
    return ExpenseMonthDto(
      id: map['id'],
      type: ExpenseMonthType.values.firstWhere(
        (e) => e.index == int.parse(map['type']),
        orElse: () => ExpenseMonthType.none,
      ),
      amount: map['amount'],
    );
  }
  factory ExpenseMonthDto.empty() {
    return ExpenseMonthDto(type: ExpenseMonthType.none, amount: 0.0);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'type': type.index.toString(), 'amount': amount};
  }
}
