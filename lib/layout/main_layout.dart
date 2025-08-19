import 'package:event_management/screens/event_list_screen.dart';
import 'package:event_management/screens/home_screen.dart';
import 'package:event_management/screens/orders_screen.dart';
import 'package:event_management/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:mkx_ui_kit/widgets/custom_bottom_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedIndex = 0;
  final List<NavigationItem> navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      label: 'Home',
      selectedIcon: Icons.home_filled,
    ),
    NavigationItem(
      icon: Icons.event_outlined,
      label: 'Events',
      selectedIcon: Icons.event,
    ),
    NavigationItem(
      icon: Icons.receipt_outlined,
      label: 'Orders',
      selectedIcon: Icons.receipt,
    ),

    NavigationItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
      selectedIcon: Icons.settings,
    ),
  ];
  void handleChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(selectedIndex),
      bottomNavigationBar: CustomBottomBar(
        handleChange: handleChange,
        selectedIndex: selectedIndex,
        navItems: navItems,
      ),
    );
  }
}

Widget _buildBody(int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return HomeScreen();
    case 1:
      return EventListScreen();
    case 2:
      return OrdersScreen();
    case 3:
      return SettingsScreen();
    default:
      return HomeScreen();
  }
}
