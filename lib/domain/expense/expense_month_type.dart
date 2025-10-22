import 'package:flutter/material.dart';

enum ExpenseMonthType {
  none(0, 'Nenhum', Icons.not_interested),
  ipva(1, 'IPVA', Icons.receipt_long),
  insurance(2, 'Seguro', Icons.verified_user),
  internet(3, 'Internet', Icons.wifi),
  carInstallments(4, 'Parcelas do Carro', Icons.payments),
  tax(5, 'Imposto', Icons.account_balance),
  other(6, 'Outros', Icons.more_horiz);

  final int value;
  final String descricao;
  final IconData icon;

  const ExpenseMonthType(this.value, this.descricao, this.icon);

  static ExpenseMonthType? fromValue(int value) {
    return ExpenseMonthType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => none,
    );
  }
}
