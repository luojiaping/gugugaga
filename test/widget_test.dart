import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gugugaga/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GuguGagaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
