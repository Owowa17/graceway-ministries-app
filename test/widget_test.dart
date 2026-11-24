import 'package:flutter_test/flutter_test.dart';
import 'package:graceway_ministries_app/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GracewayApp());

    // Verify that the app root exists
    expect(find.byType(GracewayApp), findsOneWidget);
  });
}
