import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import 'add_entry_screen2.dart';

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
          if (entryProvider.entries.isEmpty) {
            return Center(
              child: Text('Nenhum lançamento encontrado. Adicione um!'),
            );
          }
          return ListView.builder(
            itemCount: entryProvider.entries.length,
            itemBuilder: (ctx, i) {
              final entry = entryProvider.entries[i];
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lançamento apagado!')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: FittedBox(
                        child: Text(DateFormat('dd/MM').format(entry.date)),
                      ),
                    ),
                    title: Text(
                      'Lucro: ${currencyFormat.format(entry.netProfit)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: entry.netProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      'Ganhos: ${currencyFormat.format(entry.totalGains)} | Gastos: ${currencyFormat.format(entry.totalExpenses)}',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddEntryScreen(
                            entry: entry,
                          ), // Passa o 'entry' para a tela de edição
                        ),
                      );
                    },
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
          ).push(MaterialPageRoute(builder: (ctx) => AddEntryScreen()));
        },
      ),
    );
  }
}
