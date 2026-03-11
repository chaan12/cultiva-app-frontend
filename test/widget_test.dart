import 'package:flutter_test/flutter_test.dart';

import 'package:cultiva_app_frontend/main.dart';
import 'package:cultiva_app_frontend/shared/state/app_store.dart';

void main() {
  testWidgets('shows splash title on startup', (WidgetTester tester) async {
    await tester.pumpWidget(CultivaApp(store: AppStore()));

    expect(find.text('Cultiva+'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
