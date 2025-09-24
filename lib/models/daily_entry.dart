import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DailyEntry {
  final String id;
  final DateTime date;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;
  final double uberEarnings;
  final double tips;
  final double fuelCost;
  final double foodCost;
  final double cleaningCost;
  final double otherCosts;
  final double kmDriven;
  final double? kmStart;
  final double? kmEnd;
  final double hoursWorked;

  DailyEntry({
    String? id,
    required this.kmStart,
    required this.kmEnd,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.uberEarnings,
    required this.tips,
    required this.fuelCost,
    required this.foodCost,
    required this.cleaningCost,
    required this.otherCosts,
    required this.kmDriven,
    required this.hoursWorked,
  }) : this.id = id ?? const Uuid().v4();

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
    final startTimeParts = map['startTime']?.split(':') ?? "00:00";
    final endTimeParts = map['endTime']?.split(':') ?? "00:00";

    return DailyEntry(
      id: map['id'] as String,
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      uberEarnings: map['uberEarnings'],
      tips: map['tips'],
      fuelCost: map['fuelCost'],
      foodCost: map['foodCost'],
      cleaningCost: map['cleaningCost'],
      otherCosts: map['otherCosts'],
      kmDriven: map['kmDriven'],
      hoursWorked: map['hoursWorked'],
      kmStart: map['kmStart'],
      kmEnd: map['kmEnd'],
    );
  }
}
