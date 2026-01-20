import 'package:driving_profits/data/filters/operator.dart';

class Filter {
  final String column;
  final Operator operator;
  final dynamic value;

  Filter({required this.column, required this.operator, required this.value});
}
