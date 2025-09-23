class DailyEntry {
  final int? id;
  final DateTime date;
  final double uberEarnings;
  final double tips;
  final double fuelCost;
  final double foodCost;
  final double cleaningCost;
  final double otherCosts;
  final double kmDriven;
  final double hoursWorked;

  DailyEntry({
    this.id,
    required this.date,
    required this.uberEarnings,
    required this.tips,
    required this.fuelCost,
    required this.foodCost,
    required this.cleaningCost,
    required this.otherCosts,
    required this.kmDriven,
    required this.hoursWorked,
  });

  double get totalGains => uberEarnings + tips;
  double get totalExpenses => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netProfit => totalGains - totalExpenses;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'uberEarnings': uberEarnings,
      'tips': tips,
      'fuelCost': fuelCost,
      'foodCost': foodCost,
      'cleaningCost': cleaningCost,
      'otherCosts': otherCosts,
      'kmDriven': kmDriven,
      'hoursWorked': hoursWorked,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      uberEarnings: map['uberEarnings'],
      tips: map['tips'],
      fuelCost: map['fuelCost'],
      foodCost: map['foodCost'],
      cleaningCost: map['cleaningCost'],
      otherCosts: map['otherCosts'],
      kmDriven: map['kmDriven'],
      hoursWorked: map['hoursWorked'],
    );
  }
}
