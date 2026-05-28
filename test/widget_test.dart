import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finance_analysis_app/main.dart';

void main() {
  testWidgets('Finance app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceApp());

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
