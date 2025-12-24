import 'package:driving_profits/ui/feature/expenses/expense_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:driving_profits/ui/feature/list/daily_list_screen.dart';
import 'package:driving_profits/ui/feature/summary/summary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DailyListScreen(),
    const SummaryScreen(),
    ExpenseListScreen(),
    // Placeholder para tela futura
    _buildPlaceholder(),
  ];

  static Widget _buildPlaceholder() {
    return Center(
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Em Desenvolvimento',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uber Tracker'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 4,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        shape: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: 'Lançamentos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Resumo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              activeIcon: Icon(Icons.attach_money_rounded),
              label: 'Gastos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build),
              activeIcon: Icon(Icons.build_rounded),
              label: 'Manutenção',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
          selectedLabelStyle: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.labelSmall,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
