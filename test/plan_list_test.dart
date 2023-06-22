import 'package:astro_planner/main.dart';
import 'package:astro_planner/viewmodels/plan_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main () {
  testWidgets('Plan list smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Main());

    PlanViewModel().debugClearList();

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(find.text('Orion Nebula'), findsWidgets);
  });
}
