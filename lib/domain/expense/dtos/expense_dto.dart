import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/domain/expense/entities/expense_entity.dart';
import 'package:driving_profits/domain/expense/expense_type.dart';
import 'package:flutter/material.dart';

class ExpenseDto extends ChangeNotifier {
  final int? _id;
  ExpenseType _expenseType;
  ChargeType _chargeType;
  double _amount;
  String _description;

  ExpenseDto({
    required ExpenseType expenseType,
    required ChargeType chargeType,
    required double amount,
    required String description,
    int? id,
  }) : _expenseType = expenseType,
       _chargeType = chargeType,
       _amount = amount,
       _description = description,
       _id = id;

  int? get id => _id;
  ExpenseType get expenseType => _expenseType;
  ChargeType get chargeType => _chargeType;
  double get amount => _amount;
  String get description => _description;
  String get strAmount => amount.toStringAsFixed(2).replaceAll('.', ',');

  void setExpenseType(ExpenseType? value) {
    _expenseType = value ?? ExpenseType.none;
  }

  void setChargeType(ChargeType? value) {
    _chargeType = value ?? ChargeType.none;
    notifyListeners();
  }

  void setAmount(String? value) {
    _amount =
        double.tryParse(
          value == null || value.isEmpty ? '0' : value.replaceAll(',', '.'),
        ) ??
        0.0;
  }

  void setDescription(String? value) {
    _description = value ?? '';
    notifyListeners();
  }

  factory ExpenseDto.fromEntity(ExpenseEntity entity) {
    return ExpenseDto(
      id: entity.id,
      expenseType: entity.expenseType,
      chargeType: entity.chargeType,
      amount: entity.amount,
      description: entity.description,
    );
  }

  factory ExpenseDto.fromMap(Map<String, dynamic> map) {
    return ExpenseDto(
      id: map['id'],
      expenseType: ExpenseType.values.firstWhere(
        (e) => e.index == int.parse(map['expense_type']),
        orElse: () => ExpenseType.none,
      ),
      chargeType: ChargeType.values.firstWhere(
        (e) => e.index == int.parse(map['charge_type']),
        orElse: () => ChargeType.none,
      ),
      amount: map['amount'],
      description: map['description'] ?? '',
    );
  }

  factory ExpenseDto.empty() {
    return ExpenseDto(
      expenseType: ExpenseType.none,
      chargeType: ChargeType.none,
      amount: 0.0,
      description: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_type': expenseType.index,
      'charge_type': chargeType.index,
      'amount': amount,
      'description': description,
    };
  }

  void clear() {
    setAmount('0');
    setExpenseType(ExpenseType.none);
    setChargeType(ChargeType.none);
    setDescription('');
  }
}
