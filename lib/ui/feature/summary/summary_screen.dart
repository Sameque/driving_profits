import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:driving_profits/ui/feature/summary/summary_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:driving_profits/ui/feature/summary/widget/filter_chips.dart';
import 'package:driving_profits/ui/feature/summary/widget/info_list_tile.dart';
import 'package:driving_profits/ui/feature/summary/widget/loading_state.dart';
import 'package:driving_profits/ui/feature/summary/widget/primary_metric_card.dart';
import 'package:driving_profits/ui/feature/summary/widget/secondary_metric_card.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      log('delay...');
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SummaryViewmodel>();

    return Scaffold(
      appBar: AppBar(title: const Text("Posts")),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const LoadingState();
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          final currencyFormat = NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$',
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilterChips(
                      selectedPeriod: viewModel.selectedPeriod,
                      onPeriodChanged: viewModel.onPeriodChanged,
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label:
                          'Lucro líquido total de ${currencyFormat.format(viewModel.totalNetProfit)}',
                      child: PrimaryMetricCard(
                        title: 'Lucro Líquido Total',
                        value: currencyFormat.format(viewModel.totalNetProfit),
                        description:
                            'Este é o valor final após todas as despesas.',
                        onTap: () {
                          // TODO: Navegar para a tela de detalhes do lucro
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Navegando para detalhes do lucro...',
                              ),
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
                                'Receita bruta de ${currencyFormat.format(viewModel.totalGains)}',
                            child: SecondaryMetricCard(
                              title: 'Receita Bruta',
                              value: currencyFormat.format(
                                viewModel.totalGains,
                              ),
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
                                'Total de despesas de ${currencyFormat.format(viewModel.totalExpenses)}',
                            child: SecondaryMetricCard(
                              title: 'Despesas',
                              value: currencyFormat.format(
                                viewModel.totalExpenses,
                              ),
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
                      value: '${viewModel.totalKmDriven.toStringAsFixed(1)} km',
                      icon: Icons.directions_car_filled_outlined,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    InfoListTile(
                      title: 'Ganho por KM',
                      value:
                          '${currencyFormat.format(viewModel.averageGainPerKm)} / km',
                      icon: Icons.local_gas_station_outlined,
                    ),
                    const SizedBox(height: 16),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
              },
            ),
          );
        },
      ),
    );
  }
}
