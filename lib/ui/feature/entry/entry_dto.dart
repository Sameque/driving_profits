import 'package:flutter/material.dart';
import 'package:uber_tracker/models/entry_status.dart';
import 'package:uuid/uuid.dart';

class EntryDto extends ChangeNotifier {
  final String id;
  late DateTime date;
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;
  late int? kmStart;
  late int? kmEnd;
  late double uberEarnings;
  late double tips;
  late double fuelCost;
  late double foodCost;
  late double cleaningCost;
  late double otherCosts;
  late EntryStatus status;
  late double fuelEfficiency;
  late double fuelPrice;

  EntryDto({String? id}) : id = id ?? const Uuid().v4();

  EntryDto.fromMap(Map<String, dynamic> map)
    : id = (map['id'] as String?) ?? const Uuid().v4() {
    date = DateTime.tryParse(map['date']) ?? DateTime.now();
    startTime = parseTime(map['startTime']);
    endTime = parseTime(map['endTime']);
    kmStart = map['kmStart']?.toInt();
    kmEnd = map['kmEnd']?.toInt();
    uberEarnings = map['uberEarnings'];
    tips = map['tips'];
    fuelCost = map['fuelCost'];
    foodCost = map['foodCost'];
    cleaningCost = map['cleaningCost'];
    otherCosts = map['otherCosts'];
    fuelEfficiency = map['fuelEfficiency'] ?? 0.0;
    fuelPrice = map['fuelPrice'] ?? 0.0;
    status = map['status'] != null
        ? EntryStatus.values.firstWhere(
            (e) => e.toString().split('.').last == map['status'],
            orElse: () => EntryStatus.none,
          )
        : EntryStatus.none;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': getDate,
      'startTime': getStartTime,
      'endTime': getEndTime,
      'kmStart': kmStart,
      'kmEnd': kmEnd,
      'uberEarnings': uberEarnings,
      'tips': tips,
      'fuelCost': fuelCost,
      'foodCost': foodCost,
      'cleaningCost': cleaningCost,
      'otherCosts': otherCosts,
      'fuelEfficiency': fuelEfficiency,
      'fuelPrice': fuelPrice,
      'status': getStatus,
    };
  }

  //Setters with parsing and validation

  void _calculateFuelCost() {
    if ((kmStart == null || kmStart == 0) ||
        (kmEnd == null || kmEnd == 0) ||
        fuelEfficiency <= 0 ||
        fuelPrice <= 0) {
      return;
    }

    final totalKm = kmEnd! - kmStart!;
    final litersUsed = totalKm / fuelEfficiency;
    fuelCost = litersUsed * fuelPrice;
  }

  void setDate(String value) {
    date = DateTime.tryParse(value) ?? DateTime.now();
  }

  void setStartTime(TimeOfDay? value) {
    startTime = value;
    notifyListeners();
  }

  void setStartTimeStr(String? value) {
    if (value == null || value.isEmpty) {
      startTime = null;
      return;
    }
    final parts = value.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        startTime = TimeOfDay(hour: hour, minute: minute);
        return;
      }
    }
    startTime = null;
  }

  void setEndTime(TimeOfDay? value) {
    endTime = value;
    notifyListeners();
  }

  void setEndTimeStr(String? value) {
    if (value == null || value.isEmpty) {
      endTime = null;
      return;
    }
    final parts = value.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        endTime = TimeOfDay(hour: hour, minute: minute);
        return;
      }
    }
    endTime = null;
  }

  void setUberEarnings(String value) {
    uberEarnings = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    notifyListeners();
  }

  void setTips(String value) {
    tips = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    notifyListeners();
  }

  void setFoodCost(String value) {
    foodCost = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    notifyListeners();
  }

  void setCleaningCost(String value) {
    cleaningCost = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    notifyListeners();
  }

  void setOtherCosts(String value) {
    otherCosts = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    notifyListeners();
  }

  void setKmStart(String? value) {
    if (value == null || value.isEmpty) {
      kmStart = null;
    } else {
      kmStart = int.tryParse(value.replaceAll(',', '.'));
    }
    _calculateFuelCost();
    notifyListeners();
  }

  void setKmEnd(String? value) {
    if (value == null || value.isEmpty) {
      kmEnd = null;
    } else {
      kmEnd = int.tryParse(value.replaceAll(',', '.'));
    }
    _calculateFuelCost();
    notifyListeners();
  }

  void setFuelPrice(String value) {
    fuelPrice = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    _calculateFuelCost();
    notifyListeners();
  }

  void setFuelEfficiency(String value) {
    fuelEfficiency = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    _calculateFuelCost();
    notifyListeners();
  }

  void setStatus(String value) {
    status = EntryStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => EntryStatus.none,
    );
  }

  //getters in string format
  String get getDate => date.toIso8601String().split('T').first;
  String get getStartTime => startTime != null
      ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
      : '';
  String get getEndTime => endTime != null
      ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
      : '';
  String get getKmStart => kmStart?.toString() ?? '';
  String get getKmEnd => kmEnd == null || kmEnd! <= 0 ? '' : kmEnd.toString();
  String get getUberEarnings =>
      uberEarnings.toStringAsFixed(2).replaceAll('.', ',');
  String get getTips => tips.toStringAsFixed(2).replaceAll('.', ',');
  String get getFuelCost => fuelCost.toStringAsFixed(2).replaceAll('.', ',');
  String get getFuelPrice => fuelPrice.toStringAsFixed(2).replaceAll('.', ',');
  String get getFuelEfficiency =>
      fuelEfficiency.toStringAsFixed(2).replaceAll('.', ',');
  String get getFoodCost => foodCost.toStringAsFixed(2).replaceAll('.', ',');
  String get getCleaningCost => cleaningCost.toString().replaceAll('.', ',');
  String get getOtherCosts =>
      otherCosts.toStringAsFixed(2).replaceAll('.', ',');
  String get getStatus => status.toString().split('.').last;

  //computed properties
  double get totalEarnings => uberEarnings + tips;
  double get totalCosts => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netEarnings => totalEarnings - totalCosts;
  int get totalKm =>
      ((kmStart == null || kmStart! <= 0) || (kmEnd == null || kmEnd! <= 0))
      ? 0
      : (kmEnd! - kmStart!);
  double get earningsPerKm => totalKm > 0 ? netEarnings / totalKm : 0.0;

  //total hours worked
  double get totalHoursWorkedDob {
    if (startTime == null || endTime == null) return 0.0;
    final startMinutes = (startTime!.hour * 60) + startTime!.minute;
    final endMinutes = (endTime!.hour * 60) + endTime!.minute;
    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes > 0 ? diffMinutes / 60.0 : 0.0;
  }

  // total horas em formato de tempo (HH:MM)
  TimeOfDay? get totalHoursWorked {
    if (endTime == null || startTime == null) {
      return null;
    }
    final totalHours = TimeOfDay(
      hour: endTime!.hour - startTime!.hour,
      minute: endTime!.minute - startTime!.minute,
    );
    return totalHours;
  }

  @override
  String toString() {
    return 'EntryDto{date: $date, startTime: $startTime, endTime: $endTime, kmStart: $kmStart, kmEnd: $kmEnd, uberEarnings: $uberEarnings, tips: $tips, fuelCost: $fuelCost, foodCost: $foodCost, cleaningCost: $cleaningCost, otherCosts: $otherCosts, status: $status}';
  }

  TimeOfDay? parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }
}
