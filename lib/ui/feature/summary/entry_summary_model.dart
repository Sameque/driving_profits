import 'package:driving_profits/domain/entry/daily_entry.dart';
import 'package:driving_profits/domain/entry/entry_expense/entry_expense_dto.dart';

class EntrySummaryModel {
  late DateTime startDate;
  late double _uberEarnings;
  late double _tips;
  late int? kmStart;
  late int? kmEnd;
  late Set<EntryExpenseDto> _entryExpenses = <EntryExpenseDto>{};

  EntrySummaryModel.fromDailyEntry(DailyEntry entry) {
    final entryExpenses = entry.entryExpenses == null
        ? <EntryExpenseDto>{}
        : entry.entryExpenses!
              .map((e) => EntryExpenseDto.fromMap(e.toMap()))
              .toSet();

    startDate = entry.startDate;
    kmStart = entry.kmStart;
    kmEnd = entry.kmEnd;
    _uberEarnings = entry.uberEarnings;
    _tips = entry.tips;
    _entryExpenses = entryExpenses;
  }

  double get totalGains => _uberEarnings + _tips;
  double get totalEntryExpenses =>
      _entryExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  double get netProfit => totalGains - totalEntryExpenses;
}
