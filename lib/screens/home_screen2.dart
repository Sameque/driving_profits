// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'daily_list_screen.dart';
import 'summary_screen2.dart';
// Importe a tela de manutenção quando a criar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DailyListScreen(),
    SummaryScreen(),
    // Coloque a tela de Manutenção aqui quando for criada
    Center(child: Text('Tela de Manutenção (em breve)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Lançamentos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Resumo'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Manutenção'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
