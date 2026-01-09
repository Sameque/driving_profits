import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:driving_profits/ui/feature/entry/expenses/entry_expense_list_viewmodel.dart';
import 'package:flutter/material.dart';

class EntryExpenseList extends StatefulWidget {
  final EntryDto entryDto;
  final Function(EntryDto)? onSave;

  const EntryExpenseList({super.key, required this.entryDto, this.onSave});

  @override
  State<EntryExpenseList> createState() => _EntryExpenseListState();
}

class _EntryExpenseListState extends State<EntryExpenseList> {
  final viewmodel = injector.get<EntryExpenseListViewmodel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos Mensais')),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: widget.entryDto.entryExpenses.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final expense = widget.entryDto.entryExpenses[index];

            return Dismissible(
              key: ValueKey(expense),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar exclusão'),
                      content: const Text(
                        'Tem certeza que deseja apagar este gasto?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Apagar'),
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                widget.entryDto.entryExpenses.removeAt(index);
                // await viewmodel.removeCommand.execute(expense.id ?? 0);
              },
              child: ListTile(
                // leading: Icon(widget.entryDto.entryExpenses[index].icon),
                // title: Text(expense.expenseType.descricao),
                subtitle: Text(expense.description),
                // trailing: Text(_formatter.format(expense.amount)),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const ExpenseAddScreen()),
          // );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
