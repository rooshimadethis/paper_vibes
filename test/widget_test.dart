import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paper_vibes/gratitude_popup.dart';

void main() {
  testWidgets('GratitudeJournalPopup renders and functions correctly', (WidgetTester tester) async {
    bool closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GratitudeJournalPopup(
            onClose: () {
              closed = true;
            },
          ),
        ),
      ),
    );

    // Verify header text
    expect(find.text('Gratitude Journal'), findsOneWidget);
    expect(find.text('What are you grateful for right now?'), findsOneWidget);

    // Verify text field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify save button exists
    expect(find.text('Save'), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'I am grateful for coding.');
    expect(find.text('I am grateful for coding.'), findsOneWidget);

    // Tap save button
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Verify close callback was called
    expect(closed, isTrue);

    // Reset and test close button
    closed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GratitudeJournalPopup(
            onClose: () {
              closed = true;
            },
          ),
        ),
      ),
    );

    // Find close icon button
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(closed, isTrue);
  });
}
