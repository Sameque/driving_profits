import 'package:driving_profits/configuration/dependecies.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';
import 'expense_viewmodel.dart';
import 'expense_add_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final viewmodel = injector.get<ExpenseViewModel>();

  final _formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    viewmodel.removeCommand.addListener(_listenerRemove);
    viewmodel.loadCommand.addListener(_listenerLoad);

    viewmodel.loadCommand.execute();
  }

  void _listenerRemove() {
    if (viewmodel.removeCommand.value.isRunning) return;

    if (viewmodel.removeCommand.value.isSuccess) {
      if (mounted) {
        CustomSnackBar.success(
          context: context,
          message: 'Gasto removido com sucesso',
        );
      }
    }

    if (viewmodel.removeCommand.value.isFailure) {
      final failure = viewmodel.removeCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message: "Erro ao remover registro:\n - ${failure.error.toString()}",
        );
      }
    }
  }

  void _listenerLoad() {
    if (viewmodel.loadCommand.value.isFailure) {
      final failure = viewmodel.loadCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          message:
              "Erro ao consultar registros:\n - ${failure.error.toString()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos Mensais')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: viewmodel.loadCommand,
          builder: (context, _) {
            if (viewmodel.loadCommand.value.isRunning) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewmodel.loadCommand.value.isFailure) {
              return Center(
                child: Text(
                  'Erro ao carregar gastos: ${viewmodel.loadCommand.value}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return ListView.separated(
              itemCount: viewmodel.expenses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = viewmodel.expenses[index];

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
                    await viewmodel.removeCommand.execute(expense.id ?? 0);
                  },
                  child: ListTile(
                    leading: Icon(expense.expenseType.icon),
                    title: Text(expense.expenseType.descricao),
                    subtitle: Text(expense.description),
                    trailing: Text(_formatter.format(expense.amount)),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpenseAddScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
