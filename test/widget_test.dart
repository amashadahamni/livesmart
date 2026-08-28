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
import 'package:livesmart/services/property_nlp.dart';

void main() {
  testWidgets('LiveSmart app loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(LiveSmartApp());

    expect(find.byType(Image), findsOneWidget);
  });

  test('property dataset contains only LiveSmartFinalExcel3 listings', () {
    expect(PropertyData.all, hasLength(218));
    expect(PropertyData.all, everyElement(
      predicate<Map<String, String>>(
        (property) => property['sourceUrl'] == 'Uploaded workbook: LiveSmartFinalExcel3 - Final.xlsx',
      ),
    ));
  });

  test('property NLP responds to a greeting', () {
    final result = PropertyNlp.answer('Hello', PropertyData.all, now: DateTime(2026, 8, 25, 9));

    expect(result.properties, isEmpty);
    expect(result.answer, contains('Good morning'));
  });

  test('property NLP filters houses for sale in Colombo under 200 million', () {
    final result = PropertyNlp.answer('Show me houses for sale in Colombo under 200 million rupees', PropertyData.all);

    expect(result.properties, isNotEmpty);
    expect(result.properties, everyElement(predicate<Map<String, String>>((property) => property['category'] == 'House')));
    expect(result.properties, everyElement(predicate<Map<String, String>>((property) => property['city']!.toLowerCase().contains('colombo'))));
  });

  test('property NLP finds Galle land and rental apartments', () {
    final landResult = PropertyNlp.answer('lands in Galle', PropertyData.all);
    final apartmentResult = PropertyNlp.answer('2-bedroom apartment for rent in Colombo', PropertyData.all);

    expect(landResult.properties, isNotEmpty);
    expect(landResult.properties.first['category'], 'Land');
    expect(landResult.properties.first['city']!.toLowerCase(), contains('galle'));
    expect(apartmentResult.properties, isNotEmpty);
    expect(apartmentResult.properties, everyElement(predicate<Map<String, String>>((property) => property['category'] == 'Apartment' && property['transactionType'] == 'Rent' && property['beds'] == '2')));
  });

  test('property NLP evaluates land prices per perch against total budget', () {
    final result = PropertyNlp.answer('land in Colombo under 200 million', PropertyData.all);

    expect(result.properties, isNotEmpty);
    expect(result.properties, everyElement(predicate<Map<String, String>>((property) => property['category'] == 'Land')));
    expect(result.properties.any((property) => property['id'] == 'EXCEL22-12'), isFalse);
  });
}
