// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:livesmart/main.dart';
import 'package:livesmart/data/property_data.dart';

void main() {
  testWidgets('LiveSmart app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(LiveSmartApp());

    expect(find.byType(Image), findsOneWidget);
  });

  test('property dataset contains 420 rows', () {
    expect(PropertyData.all, hasLength(420));
  });
}
