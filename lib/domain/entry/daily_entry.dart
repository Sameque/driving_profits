import 'package:flutter/material.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:uuid/uuid.dart';

class DailyEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;
  final double uberEarnings;
  final double tips;
  final double fuelCost;
  final double foodCost;
  final double cleaningCost;
  final double otherCosts;
  final int? kmStart;
  final int? kmEnd;
  final EntryStatus status;
  final double? fuelEfficiency;
  final double? fuelPrice;

  DailyEntry({
    String? id,
    required this.fuelEfficiency,
    required this.fuelPrice,
    required this.kmStart,
    required this.kmEnd,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.uberEarnings,
    required this.tips,
    required this.fuelCost,
    required this.foodCost,
    required this.cleaningCost,
    required this.otherCosts,
    required this.status,
  }) : id = id ?? const Uuid().v4();

  DailyEntry.start({
    required this.startDate,
    required TimeOfDay this.startTime,
    required int this.kmStart,
  }) : id = const Uuid().v4(),
       endDate = null,
       endTime = null,
       uberEarnings = 0.0,
       tips = 0.0,
       fuelCost = 0.0,
       foodCost = 0.0,
       cleaningCost = 0.0,
       otherCosts = 0.0,
       kmEnd = null,
       status = EntryStatus.open,
       fuelEfficiency = 0.0,
       fuelPrice = 0.0;

  double get totalGains => uberEarnings + tips;
  double get totalExpenses => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netProfit => totalGains - totalExpenses;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'uber_earnings': uberEarnings,
      'tips': tips,
      'fuel_cost': fuelCost,
      'food_cost': foodCost,
      'cleaning_cost': cleaningCost,
      'other_costs': otherCosts,
      'km_start': kmStart,
      'km_end': kmEnd ?? 0,
      'start_time': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'end_time': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'status_id': EntryStatus.values.byName(status.name).index,
      'fuel_efficiency': fuelEfficiency ?? 0.0,
      'fuel_price': fuelPrice ?? 0.0,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return DailyEntry(
      id: map['id'] == null ? null : map['id'] as String,
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] == null || map['end_date'].isEmpty
          ? null
          : DateTime.parse(map['end_date'] ?? ''),
      startTime: map['start_time'] == null
          ? null
          : parseTime(map['start_time']),
      endTime: map['end_time'] == null ? null : parseTime(map['end_time']),
      uberEarnings: map['uber_earnings'] ?? 0.0,
      tips: map['tips'] ?? 0.0,
      fuelCost: map['fuel_cost'] ?? 0.0,
      foodCost: map['food_cost'] ?? 0.0,
      cleaningCost: map['cleaning_cost'] ?? 0.0,
      otherCosts: map['other_costs'] ?? 0.0,
      kmStart: map['km_start'],
      kmEnd: map['km_end'],
      status: EntryStatus.values[map['status_id'] ?? 0],
      fuelEfficiency: map['fuel_efficiency'] ?? 0.0,
      fuelPrice: map['fuel_price'] ?? 0.0,
    );
  }
}
