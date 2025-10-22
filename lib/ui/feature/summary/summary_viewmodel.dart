import 'package:flutter/cupertino.dart';
import 'package:driving_profits/data/repositories/entry_repository.dart';
import 'package:driving_profits/models/entry_status.dart';
import 'package:driving_profits/ui/feature/summary/entry_summary_model.dart';
import 'package:driving_profits/ui/feature/summary/widget/period.dart';

class SummaryViewmodel extends ChangeNotifier {
  final EntryRepository _repository;

  SummaryViewmodel(this._repository) {
    onPeriodChanged(Period.daily);
  }

  List<EntrySummaryModel> _entrySummaryModel = [];
  bool _isLoading = false;
  String? _error;

  Period _selectedPeriod = Period.none;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<EntrySummaryModel> get entrySummaryModel => _entrySummaryModel;
  Period get selectedPeriod => _selectedPeriod;

  Future<void> _fetchEntries() async {
    try {
      final entries = await _repository.getEntries();

      _entrySummaryModel = entries
          .map((e) => EntrySummaryModel.fromMap(e.toMap()))
          .where((e) => e.status == EntryStatus.closed)
          .cast<EntrySummaryModel>()
          .toList();
    } catch (e) {
      _error = "Erro: $e";
    }
  }

  void onPeriodChanged(Period? newPeriod) async {
    if (newPeriod == null || newPeriod == _selectedPeriod) return;

    _selectedPeriod = newPeriod;
    _isLoading = true;
    notifyListeners();

    await _fetchEntries();

    List<EntrySummaryModel> filtered;
    DateTime startDateSearch = DateTime.now();
    // DateTime startDateSearch = DateTime.now();
    switch (newPeriod) {
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

    filtered = _entrySummaryModel
        .where(
          (entry) =>
              entry.date.isAtSameMomentAs(startDateSearch) &&
                  entry.status == EntryStatus.closed ||
              entry.date.isAfter(startDateSearch) &&
                  entry.status == EntryStatus.closed,
        )
        .toList();
    _entrySummaryModel = filtered;

    Future.delayed(const Duration(milliseconds: 800), () {
      _isLoading = false;
      notifyListeners();
    });
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
