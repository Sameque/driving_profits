import 'package:flutter/cupertino.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:driving_profits/ui/feature/summary/entry_summary_model.dart';
import 'package:driving_profits/ui/feature/summary/widget/period.dart';
import 'package:result_command/result_command.dart';
import 'package:result_dart/result_dart.dart';

class SummaryViewmodel extends ChangeNotifier {
  final EntryRepository _repository;

  SummaryViewmodel(this._repository);

  late final onPeriodChangedCommand = Command1(_onPeriodChanged);

  List<EntrySummaryModel> _entrySummaryModel = [];

  Period _selectedPeriod = Period.none;

  Period get selectedPeriod => _selectedPeriod;

  AsyncResult _fetchEntries() async {
    final entries = await _repository.getEntries();

    _entrySummaryModel = entries
        .getOrThrow()
        .map((e) => EntrySummaryModel.fromDailyEntry(e))
        .where((e) => e.status == EntryStatus.closed)
        .cast<EntrySummaryModel>()
        .toList();

    return Success(unit);
  }

  AsyncResult _onPeriodChanged(Period? newPeriod) async {
    if (newPeriod == null || newPeriod == _selectedPeriod) {
      return Success(_entrySummaryModel);
    }

    _selectedPeriod = newPeriod;
    await _fetchEntries();

    _entrySummaryModel = _filterEntriesByPeriod(newPeriod);

    Future.delayed(const Duration(milliseconds: 800), () {});

    return Success(unit);
  }

  List<EntrySummaryModel> _filterEntriesByPeriod(Period period) {
    DateTime startDateSearch = DateTime.now();
    switch (period) {
      case Period.daily:
        startDateSearch = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        break;
      case Period.weekly:
        startDateSearch = _startOfWeek(DateTime.now());
        break;
      case Period.monthly:
        startDateSearch = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          1,
        );
        break;
      case Period.yearly:
        startDateSearch = DateTime(DateTime.now().year, 1, 1);
        break;
      case Period.none:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    return _entrySummaryModel
        .where(
          (entry) =>
              entry.date.isAtSameMomentAs(startDateSearch) &&
                  entry.status == EntryStatus.closed ||
              entry.date.isAfter(startDateSearch) &&
                  entry.status == EntryStatus.closed,
        )
        .toList();
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  double get totalGains {
    return _entrySummaryModel.fold(0.0, (sum, item) => sum + item.totalGains);
  }

  double get totalExpenses {
    return _entrySummaryModel.fold(
      0.0,
      (sum, item) => sum + item.totalExpenses,
    );
  }

  double get totalNetProfit {
    return totalGains - totalExpenses;
  }

  int get totalKmDriven {
    return _entrySummaryModel.fold(
      0,
      (sum, item) => sum + (item.kmEnd! - item.kmStart!),
    );
  }

  double get averageGainPerKm {
    if (totalKmDriven == 0) return 0;
    return totalGains / totalKmDriven;
  }
}
