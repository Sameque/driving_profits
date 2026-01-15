import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:result_command/result_command.dart';

import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/core/app_constants.dart';
import 'package:driving_profits/domain/entry/entry_dto.dart';
import 'package:driving_profits/ui/feature/entry/expenses/entry_expense_list_viewmodel.dart';
import 'package:driving_profits/ui/feature/entry/expenses/widget/add_expense_dialog_widget.dart';

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
  void initState() {
    super.initState();
    viewmodel.updateEntryExpenseCommand.addListener(_expenseListener);
  }

  @override
  void dispose() {
    viewmodel.updateEntryExpenseCommand.removeListener(_expenseListener);
    super.dispose();
  }

  void _expenseListener() {
    if (viewmodel.updateEntryExpenseCommand.value.isRunning) return;

    if (viewmodel.updateEntryExpenseCommand.value.isFailure) {
      final failure =
          viewmodel.updateEntryExpenseCommand.value as FailureCommand<Object>;

      CustomSnackBar.error(
        context: context,
        message: 'Erro ao salvar gastos:\n - ${failure.error.toString()}',
      );

      return;
    }

    if (viewmodel.updateEntryExpenseCommand.value.isSuccess) {
      CustomSnackBar.success(
        context: context,
        message: 'Gastos salvos com sucesso!',
      );

      widget.onSave?.call(widget.entryDto);
      Future.delayed(const Duration(milliseconds: 300)).then((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos Mensais')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListenableBuilder(
          listenable: widget.entryDto,
          builder: (context, _) {
            return ListView.separated(
              itemCount: widget.entryDto.getEntryExpenses.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final expense = widget.entryDto.getEntryExpenses.elementAt(
                  index,
                );

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
                    widget.entryDto.removeExpense(expense);
                  },
                  child: ListTile(
                    leading: Icon(expense.expenseType.icon),
                    title: Text(expense.expenseType.descricao),
                    subtitle: Text(expense.description),
                    trailing: Text(
                      AppConstants.formatterCurrency(expense.amount),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddExpenseDialogWidget(
              entryId: widget.entryDto.id,
              onAdd: (expense) {
                widget.entryDto.addEntryExpense(expense);
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed: viewmodel.updateEntryExpenseCommand.value.isRunning
              ? null
              : () => viewmodel.updateEntryExpenseCommand.execute(
                  widget.entryDto,
                ),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Salvar Gastos'),
        ),
      ),
    );
  }
}
