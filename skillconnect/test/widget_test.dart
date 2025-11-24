import 'package:flutter_test/flutter_test.dart';
import 'package:skillconnect/main.dart';

void main() {
  testWidgets('SkillConnect App loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(SkillConnectApp());

    // Verify that our app title appears
    expect(find.text('SkillConnect'), findsOneWidget);

    // Verify that location text appears
    expect(find.text('Your Location'), findsOneWidget);

    // Verify that service categories section appears
    expect(find.text('Service Categories'), findsOneWidget);

    // Verify that quick actions section appears
    expect(find.text('Quick Actions'), findsOneWidget);

    // Verify that Post a Job button exists
    expect(find.text('Post a Job'), findsOneWidget);
  });
}
