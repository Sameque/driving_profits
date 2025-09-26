/*
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/daily_entry.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Selecione o Mês',
    );
    if (picked != null) setState(() => _selectedMonth = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Resumo Mensal')),
      body: FutureBuilder<List<Entry>>(
        future: Provider.of<EntryProvider>(
          context,
        ).getMonthlyEntries(_selectedMonth.year, _selectedMonth.month),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(child: Text('Nenhuma entrada para este mês.'));
          }

          double totalGross = entries.fold(
            0,
            (sum, e) => sum + e.grossEarnings,
          );
          double totalExpenses = entries.fold(
            0,
            (sum, e) =>
                sum +
                e.fuelCost +
                e.maintenanceCost +
                e.otherExpenses +
                e.uberFees,
          );
          double totalProfit = entries.fold(0, (sum, e) => sum + e.dailyProfit);
          double totalKm = entries.fold(0, (sum, e) => sum + e.kmDriven);
          double costPerKm = totalKm > 0 ? totalExpenses / totalKm : 0;

          return Column(
            children: [
              ListTile(
                title: Text(
                  'Mês: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectMonth,
              ),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: entries.fold(
                          0,
                          (sum, e) => sum ?? 0 + e.fuelCost,
                        ),
                        color: Colors.red,
                        title: 'Combustível',
                      ),
                      PieChartSectionData(
                        value: entries.fold(
                          0,
                          (sum, e) => sum ?? 0 + e.maintenanceCost,
                        ),
                        color: Colors.blue,
                        title: 'Manutenção',
                      ),
                      PieChartSectionData(
                        value: entries.fold(
                          0,
                          (sum, e) => sum ?? 0 + e.otherExpenses,
                        ),
                        color: Colors.green,
                        title: 'Outras',
                      ),
                      PieChartSectionData(
                        value: entries.fold(
                          0,
                          (sum, e) => sum ?? 0 + e.uberFees,
                        ),
                        color: Colors.orange,
                        title: 'Taxas Uber',
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Métrica'),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Valor'),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Ganhos Brutos'),
                        Text('R\$ ${totalGross.toStringAsFixed(2)}'),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Despesas Totais'),
                        Text('R\$ ${totalExpenses.toStringAsFixed(2)}'),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Lucro Líquido'),
                        Text('R\$ ${totalProfit.toStringAsFixed(2)}'),
                      ],
                    ),
                    TableRow(
                      children: [
                        Text('Custo por Km'),
                        Text('R\$ ${costPerKm.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
*/
