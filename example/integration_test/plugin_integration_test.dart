import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppActor instance is available', (WidgetTester tester) async {
    final appActor = AppActor.instance;
    expect(appActor, isNotNull);
  });

  testWidgets('isConfigured returns false before configure',
      (WidgetTester tester) async {
    final configured = await AppActor.instance.isConfigured();
    expect(configured, isFalse);
  });

  testWidgets('sdkVersion returns a non-empty string',
      (WidgetTester tester) async {
    final version = await AppActor.instance.sdkVersion();
    expect(version, isNotEmpty);
  });
}
