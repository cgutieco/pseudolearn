import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/agent/agent_chat_presentation.dart';
import '../../fakes/pump_app.dart';
import '../../fakes/subscribed_agent.dart';

const ValueKey<String> _launcher = ValueKey('feature:agent');
const ValueKey<String> _panel = ValueKey('agent-chat-panel');

Future<Rect> _openPanel(WidgetTester tester, Size size) async {
  await pumpApp(tester, size, dependencies: buildSubscribedDependencies());
  await tester.tap(find.byKey(_launcher));
  await tester.pumpAndSettle();
  return tester.getRect(find.byKey(_panel));
}

void main() {
  group('Nodo panel placement', () {
    testWidgets('a compact window shows the panel across the bottom', (tester) async {
      final panel = await _openPanel(tester, const Size(466, 678));
      expect(panel.width, 466);
      expect(panel.bottom, 678);
      expect(panel.top, greaterThan(0));
    });

    testWidgets('a medium window shows the panel on the trailing side', (tester) async {
      final panel = await _openPanel(tester, const Size(951, 669));
      expect(panel.right, 951);
      expect(panel.height, 669);
      expect(panel.width, lessThan(951 / 2));
    });

    testWidgets('the 600 breakpoint is the first width with a side panel', (tester) async {
      expect((await _openPanel(tester, const Size(599, 800))).width, 599);
      Navigator.of(tester.element(find.byKey(_panel))).pop();
      await tester.pumpAndSettle();
      expect((await _openPanel(tester, const Size(600, 800))).width, lessThan(300));
    });

    testWidgets('the panel leaves every inset free', (tester) async {
      tester.view.padding = const FakeViewPadding(left: 30, top: 20, right: 84, bottom: 34);
      addTearDown(tester.view.resetPadding);
      final panel = await _openPanel(tester, const Size(951, 669));
      expect(panel.right, 951 - 84);
      expect(panel.top, 20);
      expect(panel.bottom, 669 - 34);
    });

    testWidgets('the keyboard lifts the panel', (tester) async {
      await _openPanel(tester, const Size(466, 678));
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_panel)).bottom, 678 - 250);
    });

    testWidgets('a tap on the barrier closes the panel', (tester) async {
      await _openPanel(tester, const Size(951, 669));
      await tester.tapAt(const Offset(100, 300));
      await tester.pumpAndSettle();
      expect(find.byKey(_panel), findsNothing);
    });

    testWidgets('a resize while open swaps the placement without closing the panel', (tester) async {
      await _openPanel(tester, const Size(951, 669));
      tester.view.physicalSize = const Size(466, 678);
      await tester.pumpAndSettle();
      expect(find.byType(AgentChatPlacement), findsOneWidget);
      expect(tester.getRect(find.byKey(_panel)).width, 466);
      tester.view.physicalSize = const Size(951, 669);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(_panel)).right, 951);
      expect(tester.getRect(find.byKey(_panel)).width, lessThan(951 / 2));
    });
  });
}
