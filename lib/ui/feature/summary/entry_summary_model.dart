import 'package:flutter/material.dart';
import 'package:driving_profits/models/entry_status.dart';

class EntrySummaryModel {
  late String id;
  late DateTime date;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;
  late double uberEarnings;
  late double tips;
  late double fuelCost;
  late double foodCost;
  late double cleaningCost;
  late double otherCosts;
  late int? kmStart;
  late int? kmEnd;
  late EntryStatus status;

  EntrySummaryModel({
    required this.id,
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
    required this.status,
  });

  factory EntrySummaryModel.fromMap(Map<String, dynamic> map) {
    final startTimeStr = map['startTime'] as String?;
    final endTimeStr = map['endTime'] as String?;

    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return EntrySummaryModel(
      id: map['id'] as String,
      kmStart: map['kmStart'],
      kmEnd: map['kmEnd'],
      date: DateTime.parse(map['date']),
      startTime: parseTime(startTimeStr),
      endTime: parseTime(endTimeStr),
      uberEarnings: map['uberEarnings'] ?? 0.0,
      tips: map['tips'] ?? 0.0,
      fuelCost: map['fuelCost'] ?? 0.0,
      foodCost: map['foodCost'] ?? 0.0,
      cleaningCost: map['cleaningCost'] ?? 0.0,
      otherCosts: map['otherCosts'] ?? 0.0,
      status: EntryStatus.values.byName(map['status'] ?? 'none'),
    );
  }

  double get totalGains => uberEarnings + tips;
  double get totalExpenses => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netProfit => totalGains - totalExpenses;
}
