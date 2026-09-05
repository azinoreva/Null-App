// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:null_app/main.dart';
import 'package:null_app/screens/signup_screen.dart';

void main() {
  testWidgets('shows signup for a new user', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'is_launched': true,
      'is_logged_in': false,
      'has_signed_up': false,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SignupScreen), findsOneWidget);
  });
}
