import 'package:astro_planner/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  testWidgets('Number validator test', (WidgetTester tester) async {
    await tester.pumpWidget(const Main());

    await tester.tap(find.byIcon(CupertinoIcons.add_circled));
    await tester.pump();

    await tester.enterText(find.byKey(const Key('Latitude')), 'AAA');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Enter a valid latitude'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('Latitude')), '40.1');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Enter a valid latitude'), findsNothing);

    await tester.enterText(find.byKey(const Key('Longitude')), 'AAA');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Enter a valid latitude'), findsNothing);
    expect(find.text('Enter a valid longitude'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('Longitude')), '75.2');
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Enter a valid latitude'), findsNothing);
    expect(find.text('Enter a valid longitude'), findsNothing);
  });
}
