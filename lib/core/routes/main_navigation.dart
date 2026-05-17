import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/my_crops/screens/my_crops_screen.dart';
import '../../features/crops_catalog/screens/crops_catalog_screen.dart';
import '../../features/market/screens/market_prices_screen.dart';
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
    final pages = [
      const DashboardScreen(),
      const MyCropsScreen(),
      ColoredBox(
        color: AppColors.screenBackground(context),
        child: const SafeArea(child: CatalogoScreen()),
      ),
      const MarketPricesScreen(),
      const ClimaScreen(),
      const ConfiguracionScreen(),
    ];
    final overlayStyle = currentIndex == 2
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground(context),
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: SafeArea(
          child: CultivaBottomNav(currentIndex: currentIndex, onTap: goToTab),
        ),
      ),
    );
  }
}
