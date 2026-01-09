import 'package:driving_profits/domain/entry/entry_expense/entry_expense_dto.dart';
import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/expense/charge_type.dart';
import 'package:driving_profits/domain/expense/dtos/expense_dto.dart';
import 'package:flutter/material.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:uuid/uuid.dart';

class EntryDto extends ChangeNotifier {
  final String id;
  late DateTime date;
  late DateTime? endDate;
  late TimeOfDay startTime;
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
  late int numberOfTrips;
  late List<EntryExpenseDto> entryExpenses;

  late List<ExpenseDto> _expenses;

  EntryDto.start({
    required this.date,
    required this.startTime,
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
       status = EntryStatus.open,
       numberOfTrips = 0,
       entryExpenses = [],
       _expenses = [];

  EntryDto({String? id}) : id = id ?? const Uuid().v4();

  EntryDto.fromDailyEntry(DailyEntry entry) : id = entry.id {
    date = entry.startDate;
    endDate = entry.endDate;
    startTime =
        entry.startTime ??
        TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
    endTime = entry.endTime;
    kmStart = entry.kmStart;
    kmEnd = entry.kmEnd;
    uberEarnings = entry.uberEarnings;
    tips = entry.tips;
    fuelCost = entry.fuelCost;
    foodCost = entry.foodCost;
    cleaningCost = entry.cleaningCost;
    otherCosts = entry.otherCosts;
    fuelEfficiency = entry.fuelEfficiency ?? 0.0;
    fuelPrice = entry.fuelPrice ?? 0.0;
    status = entry.status;
    numberOfTrips = entry.numberOfTrips ?? 0;
    entryExpenses = entry.entryExpenses == null
        ? []
        : entry.entryExpenses!
              .map((e) => EntryExpenseDto.fromMap(e.toMap()))
              .toList();
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
      'number_of_trips': numberOfTrips,
      'entry_expenses': entryExpenses.map((e) => e.toMap()).toList(),
    };
  }

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
    if (value == null) return;
    startTime = value;
    notifyListeners();
  }

  void setStartTimeStr(String? value) {
    if (value == null || value.isEmpty) {
      return;
    }

    final parts = value.split(':');

    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        return;
      }

      startTime = TimeOfDay(hour: hour, minute: minute);

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
    _calculatedEntryExpenses();
    notifyListeners();
  }

  void setNumberOfTrips(String? value) {
    if (value == null || value.isEmpty) {
      numberOfTrips = 0;
    } else {
      numberOfTrips = int.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    notifyListeners();
  }

  void setKmEnd(String? value) {
    if (value == null || value.isEmpty) {
      kmEnd = null;
    } else {
      kmEnd = int.tryParse(value.replaceAll(',', '.'));
    }
    _calculateFuelCost();
    _calculatedEntryExpenses();
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

  void setStatusEnum(EntryStatus value) {
    status = value;
    notifyListeners();
  }

  void setentryExpenses(List<EntryExpenseDto> values) {
    entryExpenses = values;
    notifyListeners();
  }

  void addEntryExpense(EntryExpenseDto value) {
    entryExpenses.add(value);
    notifyListeners();
  }

  void setExpense(List<ExpenseDto> values) {
    _expenses = values;
    notifyListeners();
  }

  //getters in string format
  String get getDateStr => date.toIso8601String().split('T').first;
  String get getEndDateStr =>
      endDate == null ? '' : endDate!.toIso8601String().split('T').first;
  String get getStartTimeStr =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

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
  String get getNumberOfTrips => numberOfTrips.toString();

  //computed properties
  DateTime get getDate => date;
  DateTime? get getEndDate => endDate;
  TimeOfDay? get getEndTime => endTime;
  TimeOfDay? get getStartTime => startTime;
  double get totalEarnings => uberEarnings + tips;
  double get totalCosts => fuelCost + foodCost + cleaningCost + otherCosts;
  double get netEarnings =>
      totalEarnings -
      totalCosts -
      entryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

  int get totalKm =>
      ((kmStart == null || kmStart! <= 0) || (kmEnd == null || kmEnd! <= 0))
      ? 0
      : (kmEnd! - kmStart!);
  double get earningsPerKm => totalKm > 0 ? netEarnings / totalKm : 0.0;

  DateTime get getStartDateTime => DateTime(
    date.year,
    date.month,
    date.day,
    startTime.hour,
    startTime.minute,
  );

  DateTime? get getEndDateTime {
    if (endDate == null || endTime == null) return null;
    return DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      endTime!.hour,
      endTime!.minute,
    );
  }

  TimeOfDay? _calculateTotalWorkingHoursTimeOfDay() {
    if (getEndDateTime == null) {
      return null;
    }

    final difference = getEndDateTime!.difference(getStartDateTime).inMinutes;
    if (difference <= 0) return null;
    final hours = difference ~/ 60;
    final minutes = difference % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  // total horas em formato de tempo (HH:MM)
  TimeOfDay? get totalHoursWorked => _calculateTotalWorkingHoursTimeOfDay();

  String get totalHoursWorkedStr {
    final totalHours = totalHoursWorked;
    if (totalHours == null) return '';
    return '${totalHours.hour.toString().padLeft(2, '0')}:${totalHours.minute.toString().padLeft(2, '0')}';
  }

  void _calculatedEntryExpenses() async {
    entryExpenses = _expenses
        .where((expense) => expense.chargeType == ChargeType.valuePerKm)
        .map(
          (expense) => EntryExpenseDto(
            entryId: id,
            expenseType: expense.expenseType,
            chargeType: expense.chargeType,
            amount: (expense.amount * totalKm),
            description:
                "${expense.expenseType.descricao}-${expense.description}",
            isCalculated: true,
          ),
        )
        .toList();
  }

  @override
  String toString() {
    return 'EntryDto{id: $id, date: $date, endDate: $endDate, startTime: $startTime, endTime: $endTime, kmStart: $kmStart, kmEnd: $kmEnd, uberEarnings: $uberEarnings, tips: $tips, fuelCost: $fuelCost, foodCost: $foodCost, cleaningCost: $cleaningCost, otherCosts: $otherCosts, status: $status, numberOfTrips: $numberOfTrips ,fuelEfficiency: $fuelEfficiency, fuelPrice: $fuelPrice, entryExpenses: $entryExpenses, expenses: $_expenses, totalEarnings: $totalEarnings, totalCosts: $totalCosts, netEarnings: $netEarnings, totalKm: $totalKm, earningsPerKm: $earningsPerKm, totalHoursWorked: $totalHoursWorked, totalHoursWorkedStr: $totalHoursWorkedStr}';
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

  EntryDto copy() {
    final copyDto = EntryDto(id: id);
    copyDto.date = date;
    copyDto.endDate = endDate;
    copyDto.startTime = startTime;
    copyDto.endTime = endTime;
    copyDto.kmStart = kmStart;
    copyDto.kmEnd = kmEnd;
    copyDto.uberEarnings = uberEarnings;
    copyDto.tips = tips;
    copyDto.fuelCost = fuelCost;
    copyDto.foodCost = foodCost;
    copyDto.cleaningCost = cleaningCost;
    copyDto.otherCosts = otherCosts;
    copyDto.status = status;
    copyDto.fuelEfficiency = fuelEfficiency;
    copyDto.fuelPrice = fuelPrice;
    copyDto.numberOfTrips = numberOfTrips;
    copyDto.entryExpenses = entryExpenses;
    copyDto._expenses = _expenses;
    return copyDto;
  }
}
