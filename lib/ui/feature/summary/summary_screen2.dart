import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uber_tracker/providers/entry_provider.dart';

// Simulação do seu EntryProvider para o código ser executável.
// class EntryProvider with ChangeNotifier {
//   double get totalGains => 8550.75;
//   double get totalExpenses => 3245.50;
//   double get totalNetProfit => 5305.25;
//   double get totalKmDriven => 1240.5;
//   double get averageGainPerKm => totalNetProfit / totalKmDriven;
//   bool get entriesIsEmpty => false; // Mude para 'true' para ver o estado vazio
// }

/// Tela de resumo final que incorpora:
/// 1. Estado de Carregamento (Shimmer Effect)
/// 2. Animações de Entrada
/// 3. Filtros de Período
/// 4. Interatividade nos Cards
/// 5. Acessibilidade (Semantics)
class SummaryScreenFinal extends StatefulWidget {
  const SummaryScreenFinal({super.key});

  @override
  State<SummaryScreenFinal> createState() => _SummaryScreenFinalState();
}

class _SummaryScreenFinalState extends State<SummaryScreenFinal> {
  bool _isLoading = true;
  String _selectedPeriod = 'Mensal'; // Período inicial selecionado

  @override
  void initState() {
    super.initState();
    // Simula uma busca de dados (ex: de uma API ou banco de dados)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  // Lógica para lidar com a mudança de filtro
  void _onPeriodChanged(String? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
        _isLoading = true;
      });
      // Simula uma nova busca de dados para o novo período
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = Provider.of<EntryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumo'),
        centerTitle: false,
        elevation: 0,
      ),
      body: _isLoading
          ? const _LoadingState()
          : entryProvider.entries.isEmpty
          ? const _EmptyState()
          : _buildContent(context, entryProvider),
    );
  }

  /// Constrói o conteúdo principal da tela quando os dados estão disponíveis.
  Widget _buildContent(BuildContext context, EntryProvider entryProvider) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );

    // Anima toda a lista de widgets para uma entrada suave na tela.
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterChips(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: _onPeriodChanged,
          ),
          const SizedBox(height: 16),
          // Melhoria de Acessibilidade: Rótulo semântico para o card principal.
          Semantics(
            label:
                'Lucro líquido total de ${currencyFormat.format(entryProvider.totalNetProfit)}',
            child: _PrimaryMetricCard(
              title: 'Lucro Líquido Total',
              value: currencyFormat.format(entryProvider.totalNetProfit),
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
                      'Receita bruta de ${currencyFormat.format(entryProvider.totalGains)}',
                  child: _SecondaryMetricCard(
                    title: 'Receita Bruta',
                    value: currencyFormat.format(entryProvider.totalGains),
                    icon: Icons.arrow_upward_rounded,
                    iconColor: Colors.green.shade600,
                    onTap: () {
                      // TODO: Navegar para a tela de detalhes de ganhos
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
                      'Total de despesas de ${currencyFormat.format(entryProvider.totalExpenses)}',
                  child: _SecondaryMetricCard(
                    title: 'Despesas',
                    value: currencyFormat.format(entryProvider.totalExpenses),
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
          _InfoListTile(
            title: 'Total de KM Rodados',
            value: '${entryProvider.totalKmDriven.toStringAsFixed(1)} km',
            icon: Icons.directions_car_filled_outlined,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _InfoListTile(
            title: 'Ganho por KM',
            value:
                '${currencyFormat.format(entryProvider.averageGainPerKm)} / km',
            icon: Icons.local_gas_station_outlined,
          ),
          const SizedBox(height: 16),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms),
    );
  }
}

// --- WIDGETS COMPONENTIZADOS ---

/// Efeito de esqueleto (skeleton) para simular o carregamento dos dados.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton para os filtros
            Row(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Container(
                      width: 60,
                      height: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Skeleton para o card principal
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),

            // Skeleton para os cards secundários
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(width: 200, height: 20, color: Colors.white),
            const SizedBox(height: 16),
            Container(height: 50, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 50, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Chips para seleção de período (semanal, mensal, anual).
class _FilterChips extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String?> onPeriodChanged;

  const _FilterChips({
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ['Semanal', 'Mensal', 'Anual'];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: periods.map((period) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(period),
              selected: selectedPeriod == period,
              onSelected: (isSelected) {
                if (isSelected) {
                  onPeriodChanged(period);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Card de destaque interativo.
class _PrimaryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final VoidCallback onTap;

  const _PrimaryMetricCard({
    required this.title,
    required this.value,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      clipBehavior:
          Clip.antiAlias, // Garante que o efeito de toque respeite as bordas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card secundário interativo.
class _SecondaryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _SecondaryMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Os widgets _InfoListTile e _EmptyState permanecem os mesmos da versão anterior.
// Foram omitidos aqui para brevidade, mas devem ser incluídos no seu arquivo final.

class _InfoListTile extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _InfoListTile({
    required this.title,
    required this.value,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum dado encontrado',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione seus primeiros ganhos e despesas para ver o resumo aqui.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                /* TODO: Adicionar lógica */
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar Lançamento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
