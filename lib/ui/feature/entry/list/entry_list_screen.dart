import 'package:driving_profits/configuration/dependecies.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:driving_profits/domain/entry/entry_status.dart';
import 'package:driving_profits/ui/feature/entry/edit/edit_entry_screen.dart';
import 'package:driving_profits/ui/feature/entry/close/close_entry_screen.dart';
import 'package:driving_profits/ui/feature/entry/expenses/expenses_screen.dart';
import 'package:driving_profits/ui/feature/entry/start/start_entry_screen.dart';
import 'package:driving_profits/ui/feature/entry/list/entry_list_viewmodel.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:result_command/result_command.dart';

class EntryListScreen extends StatefulWidget {
  const EntryListScreen({super.key});

  @override
  State<EntryListScreen> createState() => _EntryListScreenState();
}

class _EntryListScreenState extends State<EntryListScreen> {
  final viewmodel = injector.get<EntryListViewmodel>();

  @override
  void initState() {
    super.initState();
    viewmodel.fetchCommand.addListener(_fetchListener);
    viewmodel.deleteCommand.addListener(_deleteListener);

    viewmodel.fetchCommand.execute();
  }

  @override
  void dispose() {
    viewmodel.fetchCommand.removeListener(_fetchListener);
    viewmodel.deleteCommand.removeListener(_deleteListener);

    super.dispose();
  }

  void _fetchListener() {
    if (viewmodel.fetchCommand.value.isRunning) return;

    if (viewmodel.fetchCommand.value.isFailure) {
      final failure = viewmodel.fetchCommand.value as FailureCommand<Object>;

      CustomSnackBar.error(
        context: context,
        //TODO: colocar o texto em um arquivo de localização
        message: "Erro ao consultar registros:\n - ${failure.error.toString()}",
      );
      return;
    }
  }

  void _deleteListener() {
    if (viewmodel.deleteCommand.value.isRunning) return;

    if (viewmodel.deleteCommand.value.isFailure) {
      final failure = viewmodel.deleteCommand.value as FailureCommand<Object>;

      CustomSnackBar.error(
        context: context,
        //TODO: colocar o texto em um arquivo de localização
        message: "Erro ao apagar registro:\n - ${failure.error.toString()}",
      );
      return;
    }

    if (viewmodel.deleteCommand.value.isSuccess) {
      CustomSnackBar.success(
        context: context,
        //TODO: colocar o texto em um arquivo de localização
        message: 'Lançamento excluido!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    return Scaffold(
      //TODO: colocar o texto em um arquivo de localização
      appBar: AppBar(title: Text('Lançamentos Diários')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListenableBuilder(
          listenable: viewmodel.fetchCommand,
          builder: (context, _) {
            return ListView.builder(
              itemCount: viewmodel.entries.length,
              itemBuilder: (ctx, i) {
                final entryDto = viewmodel.entries[i];
                return Dismissible(
                  key: Key(entryDto.id.toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        //TODO: colocar o texto em um arquivo de localização
                        title: Text('Tem certeza?'),
                        content: Text('Deseja apagar este lançamento?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text('Não'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),

                            //TODO: colocar o texto em um arquivo de localização
                            child: Text('Sim'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    viewmodel.deleteCommand.execute(entryDto.id);
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
                            //TODO: colocar o texto em um arquivo de localização
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
                                        //TODO: colocar o texto em um arquivo de localização
                                        'KM Inicial',
                                        '${entryDto.kmStart ?? "-"}',
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'KM Final',
                                        '${entryDto.kmEnd ?? "-"}',
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'KM Total',
                                        entryDto.kmStart == null ||
                                                entryDto.kmEnd == null
                                            ? '-'
                                            : (entryDto.kmEnd! -
                                                      entryDto.kmStart!)
                                                  .toString(),
                                      ),
                                      _buildTableRow(
                                        'Qtd. Viagens',
                                        entryDto.numberOfTrips.toString(),
                                      ),
                                      _buildTableRow(
                                        'Hora Inicial',
                                        entryDto.startTime.format(context),
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Hora Final',
                                        entryDto.endTime != null
                                            ? entryDto.endTime!.format(context)
                                            : '-',
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Hora Total',
                                        entryDto.totalHoursWorkedStr,
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Combustível',
                                        currencyFormat.format(
                                          entryDto.fuelCost,
                                        ),
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Gastos (Outros)',
                                        currencyFormat.format(
                                          entryDto.totalCosts -
                                              entryDto.fuelCost,
                                        ),
                                      ),
                                      _buildTableRow(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Ganhos ',
                                        currencyFormat.format(
                                          entryDto.totalEarnings,
                                        ),
                                      ),
                                      TableRow(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 0.0,
                                            ),

                                            //TODO: colocar o texto em um arquivo de localização
                                            child: Text('Lucro Líquido'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Text(
                                              currencyFormat.format(
                                                entryDto.netEarnings,
                                              ),
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: entryDto.netEarnings >= 0
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

                                //TODO: colocar o texto em um arquivo de localização
                                child: Text('Fechar'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Card(
                      color: entryDto.status == EntryStatus.open
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
                              backgroundColor:
                                  entryDto.status == EntryStatus.open
                                  ? Colors.amber[200]
                                  : Colors.grey[400],
                              child: Text(
                                DateFormat(
                                  'dd\nMMM',
                                  'pt_BR',
                                ).format(entryDto.date),
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
                                      if (entryDto.status == EntryStatus.open)
                                        Container(
                                          margin: EdgeInsets.only(right: 8),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[200],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            //TODO: colocar o texto em um arquivo de localização
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            //TODO: colocar o texto em um arquivo de localização
                                            'FECHADO',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[900],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        //TODO: colocar o texto em um arquivo de localização
                                        'Lucro: ${currencyFormat.format(entryDto.netEarnings)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: entryDto.netEarnings >= 0
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
                                        currencyFormat.format(
                                          entryDto.totalEarnings,
                                        ),
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
                                        currencyFormat.format(
                                          entryDto.totalCosts,
                                        ),
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
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.blueGrey,
                                  ),
                                  //TODO: colocar o texto em um arquivo de localização
                                  tooltip: 'Editar',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => EditEntryScreen(
                                          entryDto: entryDto,
                                          onSave: viewmodel.updateEntryLocal,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (entryDto.status == EntryStatus.open) ...[
                                  IconButton(
                                    icon: Icon(
                                      Icons.receipt,
                                      color: Colors.deepPurple,
                                    ),
                                    //TODO: colocar o texto em um arquivo de localização
                                    tooltip: 'Gastos',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => ExpensesScreen(
                                            entryDto: entryDto,
                                            onSave: viewmodel.updateEntryLocal,
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
                                    //TODO: colocar o texto em um arquivo de localização
                                    tooltip: 'Fechar',
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (ctx) => CloseEntryScreen(
                                            entryDto: entryDto,
                                            onSave: viewmodel.updateEntryLocal,
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  StartEntryScreen(onSave: viewmodel.addEntryLocal),
            ),
          );
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
