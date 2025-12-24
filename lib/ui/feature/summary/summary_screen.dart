import 'package:driving_profits/configuration/dependecies.dart';
import 'package:driving_profits/ui/feature/summary/widget/period.dart';
import 'package:driving_profits/ui/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:driving_profits/ui/feature/summary/summary_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:driving_profits/ui/feature/summary/widget/filter_chips.dart';
import 'package:driving_profits/ui/feature/summary/widget/info_list_tile.dart';
import 'package:driving_profits/ui/feature/summary/widget/loading_state.dart';
import 'package:driving_profits/ui/feature/summary/widget/primary_metric_card.dart';
import 'package:driving_profits/ui/feature/summary/widget/secondary_metric_card.dart';
import 'package:result_command/result_command.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final viewmodel = injector.get<SummaryViewmodel>();
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();

    viewmodel.onPeriodChangedCommand.addListener(_listener);

    viewmodel.onPeriodChangedCommand.execute(Period.daily);
  }

  void _listener() {
    if (viewmodel.onPeriodChangedCommand.value.isFailure) {
      final failure =
          viewmodel.onPeriodChangedCommand.value as FailureCommand<Object>;
      if (mounted) {
        CustomSnackBar.error(
          context: context,
          //TODO: colocar o texto em um arquivo de localização
          message:
              "Erro ao consultar registros:\n - ${failure.error.toString()}",
        );
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resumo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListenableBuilder(
          listenable: viewmodel.onPeriodChangedCommand,
          builder: (context, _) {
            if (viewmodel.onPeriodChangedCommand.value.isRunning) {
              return const LoadingState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilterChips(
                  selectedPeriod: viewmodel.selectedPeriod,
                  onPeriodChanged: viewmodel.onPeriodChangedCommand.execute,
                ),
                const SizedBox(height: 16),
                Semantics(
                  label:
                      'Lucro líquido total de ${currencyFormat.format(viewmodel.totalNetProfit)}',
                  child: PrimaryMetricCard(
                    title: 'Lucro Líquido Total',
                    value: currencyFormat.format(viewmodel.totalNetProfit),
                    description: 'Este é o valor final após todas as despesas.',
                    onTap: () {
                      // TODO: Navegar para a tela de detalhes do lucro
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navegando para detalhes do lucro...'),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        label:
                            'Receita bruta de ${currencyFormat.format(viewmodel.totalGains)}',
                        child: SecondaryMetricCard(
                          title: 'Receita Bruta',
                          value: currencyFormat.format(viewmodel.totalGains),
                          icon: Icons.arrow_upward_rounded,
                          iconColor: Colors.green.shade600,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Navegando para detalhes da receita...',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Semantics(
                        label:
                            'Total de despesas de ${currencyFormat.format(viewmodel.totalExpenses)}',
                        child: SecondaryMetricCard(
                          title: 'Despesas',
                          value: currencyFormat.format(viewmodel.totalExpenses),
                          icon: Icons.arrow_downward_rounded,
                          iconColor: Colors.red.shade600,
                          onTap: () {
                            // TODO: Navegar para a tela de detalhes de despesas
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Navegando para detalhes das despesas...',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Métricas de Desempenho',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                InfoListTile(
                  title: 'Total de KM Rodados',
                  value: '${viewmodel.totalKmDriven.toStringAsFixed(1)} km',
                  icon: Icons.directions_car_filled_outlined,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                InfoListTile(
                  title: 'Ganho por KM',
                  value:
                      '${currencyFormat.format(viewmodel.averageGainPerKm)} / km',
                  icon: Icons.local_gas_station_outlined,
                ),
                const SizedBox(height: 16),
              ],
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
          },
        ),
      ),
    );
  }
}
