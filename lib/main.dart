import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'shared/state/app_scope.dart';
import 'shared/state/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  final store = AppStore();
  unawaited(store.initialize());
  runApp(CultivaApp(store: store));
}

class CultivaApp extends StatelessWidget {
  const CultivaApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Cultiva+',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
