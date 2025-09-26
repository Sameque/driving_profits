import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/entry_provider.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final entryProvider = Provider.of<EntryProvider>(context);

    Widget _buildMetricCard(String title, String value) {
      return Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Text(title, style: TextStyle(fontSize: 16)),
          trailing: Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Resumo Mensal')),
      body: entryProvider.entries.isEmpty
          ? Center(child: Text("Não há dados para exibir o resumo."))
          : ListView(
              children: [
                _buildMetricCard(
                  'Receita Bruta Total',
                  currencyFormat.format(entryProvider.totalGains),
                ),
                _buildMetricCard(
                  'Despesas Totais',
                  currencyFormat.format(entryProvider.totalExpenses),
                ),
                _buildMetricCard(
                  'LUCRO LÍQUIDO TOTAL',
                  currencyFormat.format(entryProvider.totalNetProfit),
                ),
                Divider(height: 30, indent: 20, endIndent: 20, thickness: 1),
                _buildMetricCard(
                  'Total de KM Rodados',
                  '${entryProvider.totalKmDriven.toStringAsFixed(1)} km',
                ),
                _buildMetricCard(
                  'Ganho por KM',
                  '${currencyFormat.format(entryProvider.averageGainPerKm)} / km',
                ),
              ],
            ),
    );
  }
}
