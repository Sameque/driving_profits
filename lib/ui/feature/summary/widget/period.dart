enum Period {
  none('Nenhum'),
  daily('Diário'),
  weekly('Semanal'),
  monthly('Mensal'),
  yearly('Anual');

  final String label;
  const Period(this.label);
}
