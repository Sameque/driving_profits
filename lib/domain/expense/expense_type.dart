import 'package:flutter/material.dart';

enum ExpenseType {
  none(0, 'Nenhum', Icons.not_interested),
  food(1, 'Alimentação', Icons.restaurant),
  fuel(2, 'Combustível', Icons.local_gas_station),
  parking(3, 'Estacionamento', Icons.local_parking),
  ipva(4, 'IPVA', Icons.receipt_long),
  tax(5, 'Imposto', Icons.account_balance),
  internet(6, 'Internet', Icons.wifi),
  maintenance(7, 'Manutenção', Icons.build),
  other(8, 'Outros', Icons.more_horiz),
  carInstallments(9, 'Parcelas do Carro', Icons.payments),
  toll(10, 'Pedágio', Icons.account_balance_wallet),
  insurance(11, 'Seguro', Icons.verified_user);

  final int value;
  final String descricao;
  final IconData icon;

  const ExpenseType(this.value, this.descricao, this.icon);

  static ExpenseType? fromValue(int value) {
    return ExpenseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => none,
    );
  }
}
