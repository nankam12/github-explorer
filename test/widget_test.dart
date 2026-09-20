import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:github_explorer/main.dart';

void main() {
  testWidgets('Search screen is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const GithubExplorerApp());

    expect(find.text('GitHub Explorer'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Search'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
