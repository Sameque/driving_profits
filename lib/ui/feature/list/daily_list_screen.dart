import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uber_tracker/models/entry_status.dart';
import 'package:uber_tracker/providers/entry_provider.dart';
import 'package:uber_tracker/ui/feature/entry/edit_entry_screen.dart';
import 'package:uber_tracker/ui/feature/entry/close_entry_screen.dart';
import 'package:uber_tracker/ui/feature/entry/expenses_screen.dart';
import 'package:uber_tracker/ui/feature/entry/start_entry_screen.dart';
import 'package:uber_tracker/ui/widget/custom_snackbar.dart';

class DailyListScreen extends StatelessWidget {
  const DailyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      appBar: AppBar(title: Text('Lançamentos Diários')),
      body: Consumer<EntryProvider>(
        builder: (ctx, entryProvider, child) {
          if (entryProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final allEntries = [...entryProvider.entries];
          allEntries.sort((a, b) => b.date.compareTo(a.date));

          if (allEntries.isEmpty) {
            return Center(
              child: Text('Nenhum lançamento encontrado. Adicione um!'),
            );
          }
          return ListView.builder(
            itemCount: allEntries.length,
            itemBuilder: (ctx, i) {
              final entry = allEntries[i];
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
                  entryProvider.deleteEntry(entry.id!);

                  CustomSnackBar.success(
                    context: context,
                    message: 'Lançamento apagado!',
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  color: entry.status == EntryStatus.open
                      ? Colors.amber[100]
                      : null,
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: FittedBox(
                        child: Text(DateFormat('dd/MM').format(entry.date)),
                      ),
                    ),
                    title: Text(
                      '${entry.status == EntryStatus.open ? 'Aberto - ' : ''}Lucro: ${currencyFormat.format(entry.netProfit)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.netProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Ganhos: ${currencyFormat.format(entry.totalGains)} | Gastos: ${currencyFormat.format(entry.totalExpenses)}',
                    ),
                    onTap: () {},
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          tooltip: 'Editar',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => EditEntryScreen(entry: entry),
                              ),
                            );
                          },
                        ),
                        if (entry.status == EntryStatus.open) ...[
                          IconButton(
                            icon: Icon(Icons.receipt),
                            tooltip: 'Gastos',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      ExpensesScreen(entry: entry),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.check_circle_outline),
                            tooltip: 'Fechar',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      CloseEntryScreen(entry: entry),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
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
}
