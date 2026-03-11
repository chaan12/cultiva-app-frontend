import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/my_crops/screens/my_crops_scree.dart';
import '../../features/crops_catalog/screens/crops_catalog_screen.dart';
import '../../features/weather/screens/weather_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

import '../../shared/components/bottom_navbar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static MainNavigationState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainNavigationState>();
  }

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardScreen(),
    const MisCultivosScreen(),
    const CatalogoScreen(),
    const ClimaScreen(),
    const ConfiguracionScreen(),
  ];

  void goToTab(int index) {
    if (index == currentIndex) {
      return;
    }
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: CultivaBottomNav(
        currentIndex: currentIndex,
        onTap: goToTab,
      ),
    );
  }
}
