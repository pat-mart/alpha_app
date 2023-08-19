import 'package:astro_planner/main.dart';
import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  testWidgets('Plan list smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Main());

    PlanViewModel().debugClearList();

    await tester.tap(find.byIcon(CupertinoIcons.info_circle));

    await tester.pump();

    await tester.tap(find.widgetWithText(CupertinoButton, 'Add to plans'));

    await tester.pump();

    expect(find.text('Orion'), findsOneWidget);
  });
}
