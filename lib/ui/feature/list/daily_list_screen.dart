import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/models/daily_entry.dart';
import 'package:uber_tracker/models/entry_status.dart';
import 'package:uber_tracker/ui/feature/entry/edit_entry_screen.dart';
import 'package:uber_tracker/ui/feature/entry/close_entry_screen.dart';
import 'package:uber_tracker/ui/feature/entry/expenses_screen.dart';
import 'package:uber_tracker/ui/feature/entry/start_entry_screen.dart';
import 'package:uber_tracker/ui/feature/list/daily_list_viewmodel.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';

class DailyListScreen extends StatelessWidget {
  const DailyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    final viewModel = context.watch<DailyListViewmodel>();

    return Scaffold(
      appBar: AppBar(title: Text('Lançamentos Diários')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView.builder(
          itemCount: viewModel.entries.length,
          itemBuilder: (ctx, i) {
            final entry = viewModel.entries[i];
            return Dismissible(
              key: Key(entry.id.toString()),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Tem certeza?'),
                    content: Text('Deseja apagar este lançamento?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: Text('Não'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: Text('Sim'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                viewModel.deleteEntry(entry.id!);

                CustomSnackBar.success(
                  context: context,
                  message: 'Lançamento apagado!',
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 0.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text('Resumo da Jornada'),
                        contentPadding: EdgeInsets.all(8),
                        actionsPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        content: SingleChildScrollView(
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(5),
                                  1: FlexColumnWidth(4),
                                },
                                border: TableBorder(
                                  horizontalInside: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                children: [
                                  _buildTableRow(
                                    'KM Inicial',
                                    '${entry.kmStart ?? "-"}',
                                  ),
                                  _buildTableRow(
                                    'KM Final',
                                    '${entry.kmEnd ?? "-"}',
                                  ),
                                  _buildTableRow(
                                    'KM Total',
                                    entry.kmStart == null || entry.kmEnd == null
                                        ? '-'
                                        : (entry.kmEnd! - entry.kmStart!)
                                              .toString(),
                                  ),
                                  _buildTableRow(
                                    'Hora Inicial',
                                    entry.startTime != null
                                        ? entry.startTime!.format(context)
                                        : '-',
                                  ),
                                  _buildTableRow(
                                    'Hora Final',
                                    entry.endTime != null
                                        ? entry.endTime!.format(context)
                                        : '-',
                                  ),
                                  _buildTableRow(
                                    'Hora Total',
                                    entry.totalHoursWorkedStr,
                                  ),
                                  _buildTableRow(
                                    'Combustível',
                                    currencyFormat.format(entry.fuelCost),
                                  ),
                                  _buildTableRow(
                                    'Gastos (Outros)',
                                    currencyFormat.format(
                                      entry.totalCosts - entry.fuelCost,
                                    ),
                                  ),
                                  _buildTableRow(
                                    'Ganhos ',
                                    currencyFormat.format(entry.totalEarnings),
                                  ),
                                  TableRow(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 0.0,
                                        ),
                                        child: Text('Lucro Líquido'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          currencyFormat.format(
                                            entry.netEarnings,
                                          ),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: entry.netEarnings >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('Fechar'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  color: entry.status == EntryStatus.open
                      ? Colors.amber[50]
                      : Colors.grey[100],
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: entry.status == EntryStatus.open
                              ? Colors.amber[200]
                              : Colors.grey[400],
                          child: Text(
                            DateFormat('dd\nMMM', 'pt_BR').format(entry.date),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (entry.status == EntryStatus.open)
                                    Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'ABERTO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[900],
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      margin: EdgeInsets.only(right: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'FECHADO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[900],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    'Lucro: ${currencyFormat.format(entry.netEarnings)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: entry.netEarnings >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    currencyFormat.format(entry.totalEarnings),
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(
                                    Icons.arrow_downward,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    currencyFormat.format(entry.totalCosts),
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blueGrey),
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => EditEntryScreen(
                                      entry: DailyEntry.fromMap(entry.toMap()),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (entry.status == EntryStatus.open) ...[
                              IconButton(
                                icon: Icon(
                                  Icons.receipt,
                                  color: Colors.deepPurple,
                                ),
                                tooltip: 'Gastos',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => ExpensesScreen(
                                        entry: DailyEntry.fromMap(
                                          entry.toMap(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                tooltip: 'Fechar',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => CloseEntryScreen(
                                        entry: DailyEntry.fromMap(
                                          entry.toMap(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (ctx) => StartEntryScreen()));
        },
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(label),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(value, textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
