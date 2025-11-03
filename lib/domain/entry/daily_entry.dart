import 'package:flutter/material.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:uuid/uuid.dart';

class DailyEntry {
  final String id;
  final DateTime date;
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
    required this.date,
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
    required this.date,
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
      'date': date.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'uberEarnings': uberEarnings,
      'tips': tips,
      'fuelCost': fuelCost,
      'foodCost': foodCost,
      'cleaningCost': cleaningCost,
      'otherCosts': otherCosts,
      'kmStart': kmStart,
      'kmEnd': kmEnd ?? 0,
      'startTime': startTime != null
          ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'endTime': endTime != null
          ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
          : null,
      'status': status.name,
      'fuelEfficiency': fuelEfficiency ?? 0.0,
      'fuelPrice': fuelPrice ?? 0.0,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    final startTimeStr = map['startTime'] as String?;
    final endTimeStr = map['endTime'] as String?;

    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return DailyEntry(
      id: map['id'] == null ? null : map['id'] as String,
      date: DateTime.parse(map['date']),
      endDate: map['endDate'] == null || map['endDate'].isEmpty
          ? null
          : DateTime.parse(map['endDate'] ?? ''),
      startTime: parseTime(startTimeStr),
      endTime: parseTime(endTimeStr),
      uberEarnings: map['uberEarnings'] ?? 0.0,
      tips: map['tips'] ?? 0.0,
      fuelCost: map['fuelCost'] ?? 0.0,
      foodCost: map['foodCost'] ?? 0.0,
      cleaningCost: map['cleaningCost'] ?? 0.0,
      otherCosts: map['otherCosts'] ?? 0.0,
      kmStart: map['kmStart'],
      kmEnd: map['kmEnd'],
      status: EntryStatus.values.byName(map['status'] ?? 'none'),
      fuelEfficiency: map['fuelEfficiency'] ?? 0.0,
      fuelPrice: map['fuelPrice'] ?? 0.0,
    );
  }
}
