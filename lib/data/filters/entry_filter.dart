import 'package:driving_profits/data/filters/filter.dart';
import 'package:driving_profits/data/filters/operator.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';

class EntryFilter {
  final DateTime? startDateGte;
  final EntryStatus? statusEq;

  EntryFilter({this.startDateGte, this.statusEq});

  List<Filter> toFilterList() {
    final List<Filter> filters = [];

    if (startDateGte != null) {
      filters.add(
        Filter(
          column: 'start_date',
          operator: Operator.greaterThanOrEqual,
          value: startDateGte!.toIso8601String(),
        ),
      );
    }

    if (statusEq != null) {
      filters.add(
        Filter(
          column: 'status_id',
          operator: Operator.equal,
          value: statusEq!.index,
        ),
      );
    }
    return filters;
  }
}
