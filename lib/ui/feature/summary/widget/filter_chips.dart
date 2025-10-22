import 'package:flutter/material.dart';
import 'package:driving_profits/ui/feature/summary/widget/period.dart';

class FilterChips extends StatelessWidget {
  final Period selectedPeriod;
  final ValueChanged<Period?> onPeriodChanged;

  const FilterChips({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = Period.values
        .map((p) => p)
        .where((p) => p != Period.none)
        .toList();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: periods.map((period) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period.label),
              selected: selectedPeriod == period,
              onSelected: (isSelected) {
                if (isSelected) {
                  onPeriodChanged(period);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
