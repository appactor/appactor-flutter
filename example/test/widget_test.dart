import 'package:flutter_test/flutter_test.dart';
import 'package:appactor_flutter_example/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AppActorExampleApp());
    expect(find.text('AppActor Example'), findsOneWidget);
  });
}
