import 'package:flutter/material.dart';

enum ExpenseType {
  none(0, 'Nenhum', Icons.not_interested),
  food(1, 'Alimentação', Icons.restaurant),
  parking(2, 'Estacionamento', Icons.local_parking),
  ipva(3, 'IPVA', Icons.receipt_long),
  tax(4, 'Imposto', Icons.account_balance),
  internet(5, 'Internet', Icons.wifi),
  maintenance(6, 'Manutenção', Icons.build),
  carInstallments(7, 'Parcelas do Carro', Icons.payments),
  toll(8, 'Pedágio', Icons.account_balance_wallet),
  insurance(9, 'Seguro', Icons.verified_user),
  other(10, 'Outros', Icons.more_horiz),
  carWash(11, 'Lavagem', Icons.local_car_wash),
  fuel(12, 'Combustível', Icons.local_gas_station);

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
