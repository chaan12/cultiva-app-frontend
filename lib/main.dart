import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/app_config.dart';
import 'core/config/env_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'shared/state/app_scope.dart';
import 'shared/state/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.instance.load();
  final configErrors = AppConfig.validate();
  if (configErrors.isNotEmpty) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: const EnvConfigException(
          'Configuración de entorno incompleta o inválida.',
        ),
        library: 'Cultiva+',
        context: ErrorDescription('validando configuración de entorno'),
      ),
    );
  }
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
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cultiva+',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: store.settings.darkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
