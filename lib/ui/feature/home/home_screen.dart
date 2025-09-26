/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/entry_provider.dart';
import '../models/daily_entry.dart';
import 'add_entry_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EntryProvider>(context, listen: false).loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<EntryProvider>(context).entries;

    return Scaffold(
      appBar: AppBar(
        title: Text('Uber Tracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SummaryScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return ListTile(
            title: Text(entry.formattedDate),
            subtitle: Text(
              'Lucro: R\$ ${entry.dailyProfit.toStringAsFixed(2)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEntryScreen(entry: entry),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    await Provider.of<EntryProvider>(
                      context,
                      listen: false,
                    ).deleteEntry(entry.id!);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddEntryScreen()),
        ),
      ),
    );
  }
}
*/
