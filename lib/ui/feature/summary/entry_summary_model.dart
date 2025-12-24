import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:flutter/material.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';

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
    final startTimeStr = map['start_time'] as String?;
    final endTimeStr = map['end_time'] as String?;

    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return EntrySummaryModel(
      id: map['id'] as String,
      kmStart: map['km_start'],
      kmEnd: map['km_end'],
      date: DateTime.parse(map['date_start']),
      startTime: parseTime(startTimeStr),
      endTime: parseTime(endTimeStr),
      uberEarnings: map['uber_earnings'] ?? 0.0,
      tips: map['tips'] ?? 0.0,
      fuelCost: map['fuel_cost'] ?? 0.0,
      foodCost: map['food_cost'] ?? 0.0,
      cleaningCost: map['cleaning_cost'] ?? 0.0,
      otherCosts: map['other_costs'] ?? 0.0,
      status: EntryStatus.values.byName(map['status_id'] ?? 'none'),
    );
  }

  EntrySummaryModel.fromDailyEntry(DailyEntry entry) : id = entry.id {
    date = entry.startDate;
    startTime = entry.startTime ?? TimeOfDay.now();
    endTime = entry.endTime;
    kmStart = entry.kmStart;
    kmEnd = entry.kmEnd;
    uberEarnings = entry.uberEarnings;
    tips = entry.tips;
    fuelCost = entry.fuelCost;
    foodCost = entry.foodCost;
    cleaningCost = entry.cleaningCost;
    otherCosts = entry.otherCosts;
    status = entry.status;
  }

  double get totalGains => uberEarnings + tips;
  double get totalExpenses => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netProfit => totalGains - totalExpenses;
}
