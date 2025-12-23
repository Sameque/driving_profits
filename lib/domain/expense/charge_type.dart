import 'package:flutter/material.dart';

enum ChargeType {
  none(0, 'Nenhum', Icons.not_interested),
  variableValue(1, 'Valor Variável', Icons.attach_money),
  valuePerKm(2, 'Valor por Km Rodado', Icons.speed),
  fixedMonthly(3, 'Fixa Mensal', Icons.calendar_today),
  fixedDaily(4, 'Fixo Diário', Icons.date_range);

  final int value;
  final String descricao;
  final IconData icon;

  const ChargeType(this.value, this.descricao, this.icon);

  static ChargeType? fromValue(int value) {
    return ChargeType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => none,
    );
  }
}
