import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/card/app_card.dart';

import '../component_test_harness.dart';

void main() {
  group('AppCard (RFC 003 §1)', () {
    testWidgets('renders its child', (tester) async {
      await pumpComponent(tester, const AppCard(child: Text('content')));
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('tapping invokes onTap', (tester) async {
      var tapped = false;
      await pumpComponent(
        tester,
        AppCard(onTap: () => tapped = true, child: const Text('tap me')),
      );
      await tester.tap(find.byType(AppCard));
      expect(tapped, isTrue);
    });

    testWidgets('with no onTap, the card still renders and never throws on tap gestures', (tester) async {
      await pumpComponent(tester, const AppCard(child: Text('static')));
      await tester.tap(find.byType(AppCard));
      expect(tester.takeException(), isNull);
    });

    testWidgets('hovering raises the elevation and leaving restores it', (tester) async {
      await pumpComponent(tester, AppCard(onTap: () {}, child: const Text('hover me')));
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();

      final container = find.descendant(of: find.byType(AppCard), matching: find.byType(AnimatedContainer));
      final restingDecoration = tester.widget<AnimatedContainer>(container).decoration as BoxDecoration;

      await gesture.moveTo(tester.getCenter(find.byType(AppCard)));
      await tester.pump();
      final hoveredDecoration = tester.widget<AnimatedContainer>(container).decoration as BoxDecoration;

      expect(hoveredDecoration.boxShadow, isNot(equals(restingDecoration.boxShadow)));
    });

    testWidgets('a nested card in expanded gets the larger nested padding', (tester) async {
      await pumpComponent(
        tester,
        const AppCard(isNested: true, child: SizedBox(width: 10, height: 10)),
        size: const Size(960, 900),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(AppCard), findsOneWidget);
    });
  });
}
