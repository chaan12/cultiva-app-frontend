import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() {
  runApp(const CultivaApp());
}

class CultivaApp extends StatelessWidget {
  const CultivaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cultiva+',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}
