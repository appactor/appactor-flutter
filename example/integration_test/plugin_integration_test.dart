import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:appactor_flutter/appactor_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppActor instance is available', (WidgetTester tester) async {
    final appActor = AppActor.instance;
    expect(appActor, isNotNull);
  });

  testWidgets('getAppUserId returns null before configure', (
    WidgetTester tester,
  ) async {
    final appUserId = await AppActor.instance.getAppUserId();
    expect(appUserId, isNull);
  });

  testWidgets('getIsAnonymous returns true before configure', (
    WidgetTester tester,
  ) async {
    final isAnonymous = await AppActor.instance.getIsAnonymous();
    expect(isAnonymous, isTrue);
  });

  testWidgets('sdkVersion returns a non-empty string', (
    WidgetTester tester,
  ) async {
    final version = await AppActor.instance.sdkVersion();
    expect(version, isNotEmpty);
  });
}
