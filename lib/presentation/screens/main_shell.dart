// lib/presentation/screens/main_shell.dart
//
// This is the main container after login.
// It holds the BottomNavigationBar and swaps screens per tab.
// Think of it as the "frame" — the nav bar never rebuilds, only the content.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepal2/presentation/providers/inventory_provider.dart';
import 'package:prepal2/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:prepal2/presentation/screens/forecast/forecast_screen.dart';
import 'package:prepal2/presentation/screens/inventory/inventory_screen.dart';
import 'package:prepal2/presentation/screens/alerts/alerts_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() =>
      _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // Tracks which tab is active

  // All tab screens — index matches bottom nav position
  final List<Widget> _screens = const [
    DashboardScreen(),
    ForecastScreen(),
    InventoryScreen(),
    AlertsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    // Load inventory data when shell first loads
    // Using Future.microtask avoids calling setState during build
    Future.microtask(() {
      context
          .read<InventoryProvider>()
          .loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens alive (they don't rebuild on tab switch)
      // Alternative: use _screens[_currentIndex] to rebuild each time
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) =>
            setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed, // Shows label for all tabs
        selectedItemColor: const Color(0xFFD32F2F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Forecast',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
