import 'package:flutter/widgets.dart';

import 'app_store.dart';

class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('AppScope not found in widget tree');
    }
    return scope.notifier!;
  }
}
