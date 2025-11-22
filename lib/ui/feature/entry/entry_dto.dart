import 'package:flutter/material.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:uuid/uuid.dart';

class EntryDto extends ChangeNotifier {
  final String id;
  late DateTime date;
  late DateTime? endDate;
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

  EntryDto.start({
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
       fuelEfficiency = 0.0,
       fuelPrice = 0.0,
       status = EntryStatus.open;

  EntryDto({String? id}) : id = id ?? const Uuid().v4();

  EntryDto.fromMap(Map<String, dynamic> map)
    : id = (map['id'] as String?) ?? const Uuid().v4() {
    date = DateTime.tryParse(map['date']) ?? DateTime.now();
    endDate = DateTime.tryParse(map['endDate'] ?? '');
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
      'start_date': getDateStr,
      'end_date': getEndDateStr,
      'start_time': getStartTimeStr,
      'end_time': getEndTimeStr,
      'km_start': kmStart,
      'km_end': kmEnd,
      'uber_earnings': uberEarnings,
      'tips': tips,
      'fuel_cost': fuelCost,
      'food_cost': foodCost,
      'cleaning_cost': cleaningCost,
      'other_costs': otherCosts,
      'fuel_efficiency': fuelEfficiency,
      'fuel_price': fuelPrice,
      'status_id':
          EntryStatus.values.asNameMap()[getStatus]?.index ??
          EntryStatus.none.index,
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

  void setDate(DateTime value) {
    date = value;
    notifyListeners();
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
      } else {
        startTime = null;
      }
      notifyListeners();
    }
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
      } else {
        endTime = null;
      }
      notifyListeners();
    }
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
  String get getDateStr => date.toIso8601String().split('T').first;
  String get getEndDateStr =>
      endDate == null ? '' : endDate!.toIso8601String().split('T').first;
  String get getStartTimeStr => startTime != null
      ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
      : '';
  String get getEndTimeStr => endTime != null
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
  DateTime get getDate => date;
  DateTime? get getEndDate => endDate;
  TimeOfDay? get getEndTime => endTime;
  TimeOfDay? get getStartTime => startTime;
  double get totalEarnings => uberEarnings + tips;
  double get totalCosts => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netEarnings => totalEarnings - totalCosts;
  int get totalKm =>
      ((kmStart == null || kmStart! <= 0) || (kmEnd == null || kmEnd! <= 0))
      ? 0
      : (kmEnd! - kmStart!);
  double get earningsPerKm => totalKm > 0 ? netEarnings / totalKm : 0.0;

  TimeOfDay? _calculateTotalWorkingHoursTimeOfDay() {
    if (endDate == null || startTime == null || endTime == null) {
      return null;
    }

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startTime!.hour,
      startTime!.minute,
    );
    final end = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
    final difference = end.difference(start).inMinutes;
    if (difference <= 0) return null;
    final hours = difference ~/ 60;
    final minutes = difference % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  //total hours worked
  double get totalHoursWorkedDob {
    if (startTime == null || endTime == null) return 0.0;
    final startMinutes = (startTime!.hour * 60) + startTime!.minute;
    final endMinutes = (endTime!.hour * 60) + endTime!.minute;
    final diffMinutes = endMinutes - startMinutes;
    return diffMinutes > 0 ? diffMinutes / 60.0 : 0.0;
  }

  // total horas em formato de tempo (HH:MM)
  TimeOfDay? get totalHoursWorked => _calculateTotalWorkingHoursTimeOfDay();

  String get totalHoursWorkedStr {
    final totalHours = totalHoursWorked;
    if (totalHours == null) return '';
    return '${totalHours.hour.toString().padLeft(2, '0')}:${totalHours.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'EntryDto{date: $date, endDate: $endDate, startTime: $startTime, endTime: $endTime, kmStart: $kmStart, kmEnd: $kmEnd, uberEarnings: $uberEarnings, tips: $tips, fuelCost: $fuelCost, foodCost: $foodCost, cleaningCost: $cleaningCost, otherCosts: $otherCosts, status: $status}';
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

  void setEndDate(DateTime picked) {
    endDate = picked;
    notifyListeners();
  }
}
