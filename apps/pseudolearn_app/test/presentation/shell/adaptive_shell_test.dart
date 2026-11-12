import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/destinations.dart';
import 'package:pseudolearn_app/presentation/shell/shell_bottom_bar.dart';
import 'package:pseudolearn_app/presentation/shell/shell_navigation_rail.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/typography.dart';
import '../../fakes/pump_app.dart';
import '../../fakes/subscribed_agent.dart';

final class _Window {
  final String name;
  final Size size;
  final EdgeInsets padding;
  final bool expectsRail;

  const _Window(this.name, this.size, this.padding, {required this.expectsRail});
}

const List<_Window> _windows = <_Window>[
  _Window('iPhone Duo inner, landscape', Size(951, 669), EdgeInsets.only(right: 84, bottom: 34), expectsRail: true),
  _Window('iPhone Duo inner, portrait', Size(669, 951), EdgeInsets.only(top: 84, bottom: 34), expectsRail: true),
  _Window('iPhone Duo outer, portrait', Size(466, 678), EdgeInsets.only(right: 84, bottom: 34), expectsRail: false),
  _Window('iPhone Duo outer, landscape', Size(678, 466), EdgeInsets.only(right: 84, bottom: 21), expectsRail: true),
  _Window('iPhone, landscape with side island', Size(874, 402), EdgeInsets.only(left: 62, right: 62, bottom: 21), expectsRail: true),
  _Window('iPhone, portrait', Size(402, 874), EdgeInsets.only(top: 62, bottom: 34), expectsRail: false),
  _Window('iPad, landscape', Size(1180, 820), EdgeInsets.only(top: 24, bottom: 20), expectsRail: true),
  _Window('just below medium', Size(599, 800), EdgeInsets.only(right: 40), expectsRail: false),
  _Window('exactly medium', Size(600, 800), EdgeInsets.only(right: 40), expectsRail: true),
  _Window('just below expanded', Size(959, 640), EdgeInsets.only(left: 40), expectsRail: true),
  _Window('exactly expanded', Size(960, 640), EdgeInsets.only(left: 40), expectsRail: true),
];

Future<void> _pumpWindow(WidgetTester tester, _Window window, {double textScale = 1}) async {
  final padding = FakeViewPadding(
    left: window.padding.left,
    top: window.padding.top,
    right: window.padding.right,
    bottom: window.padding.bottom,
  );
  tester.view.padding = padding;
  tester.view.viewPadding = padding;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewPadding);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await pumpApp(tester, window.size, dependencies: buildSubscribedDependencies());
}

String _currentPath(WidgetTester tester) {
  final context = tester.element(find.byType(Navigator).first);
  return GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
}

Rect _safeRect(_Window window) => window.padding.deflateRect(Offset.zero & window.size);

Finder _navigation(_Window window) =>
    window.expectsRail ? find.byType(ShellNavigationRail) : find.byType(ShellBottomBar);

Future<void> _tapEveryDestination(WidgetTester tester, _Window window) async {
  final l10n = AppLocalizations.of(tester.element(_navigation(window)))!;
  for (final destination in appDestinations.reversed) {
    final label = find.descendant(of: _navigation(window), matching: find.text(destination.label(l10n)));
    await tester.ensureVisible(label);
    await tester.pumpAndSettle();
    await tester.tap(label);
    await tester.pumpAndSettle();
    expect(_currentPath(tester), destination.path);
  }
}

void main() {
  for (final window in _windows) {
    group(window.name, () {
      testWidgets('lays out without overflow and with the expected navigation', (tester) async {
        final errors = await collectLayoutErrors(() async {
          await _pumpWindow(tester, window);
          for (final destination in appDestinations) {
            await visitDestination(tester, destination.path);
          }
        });
        expect(errors.map((error) => error.exceptionAsString()).toList(), isEmpty);
        expect(_navigation(window), findsOneWidget);
      });

      testWidgets('every destination responds to a tap', (tester) async {
        await _pumpWindow(tester, window);
        await _tapEveryDestination(tester, window);
      });

      testWidgets('the Nodo launcher stays inside the safe area and opens the panel', (tester) async {
        await _pumpWindow(tester, window);
        final launcher = find.byKey(const ValueKey('feature:agent'));
        final bounds = tester.getRect(launcher);
        final safe = _safeRect(window);
        expect(safe.contains(bounds.topLeft) && safe.contains(bounds.bottomRight - const Offset(1, 1)), isTrue,
            reason: 'launcher $bounds is outside the safe area $safe');
        await tester.tap(launcher);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('agent-chat-panel')), findsOneWidget);
      });

      testWidgets('the Nodo panel stays inside the safe area without overflow', (tester) async {
        final errors = await collectLayoutErrors(() async {
          await _pumpWindow(tester, window);
          await tester.tap(find.byKey(const ValueKey('feature:agent')));
          await tester.pumpAndSettle();
        });
        expect(errors.map((error) => error.exceptionAsString()).toList(), isEmpty);
        final panel = tester.getRect(find.byKey(const ValueKey('agent-chat-panel')));
        final safe = _safeRect(window);
        expect(panel.left >= safe.left && panel.right <= safe.right && panel.bottom <= safe.bottom, isTrue,
            reason: 'panel $panel is outside the safe area $safe');
      });
    });
  }

  group('largest supported text', () {
    for (final window in <_Window>[_windows[0], _windows[2], _windows[4]]) {
      testWidgets('${window.name}: destinations still respond', (tester) async {
        final errors = await collectLayoutErrors(() async {
          await _pumpWindow(tester, window, textScale: TypographyTokens.textScaleMax);
          await _tapEveryDestination(tester, window);
        });
        expect(errors.map((error) => error.exceptionAsString()).toList(), isEmpty);
      });
    }
  });

  group('unhappy paths', () {
    testWidgets('a tap inside the status bar column neither navigates nor opens the panel', (tester) async {
      final window = _windows[0];
      await _pumpWindow(tester, window);
      final before = _currentPath(tester);
      await tester.tapAt(Offset(window.size.width - window.padding.right / 2, window.size.height - 60));
      await tester.pumpAndSettle();
      expect(_currentPath(tester), before);
      expect(find.byKey(const ValueKey('agent-chat-panel')), findsNothing);
    });

    testWidgets('the panel follows a fold while open instead of keeping the unfolded layout', (tester) async {
      final unfolded = _windows[0];
      final folded = _windows[2];
      await _pumpWindow(tester, unfolded);
      await tester.tap(find.byKey(const ValueKey('feature:agent')));
      await tester.pumpAndSettle();
      final errors = await collectLayoutErrors(() async {
        tester.view.physicalSize = folded.size;
        await tester.pumpAndSettle();
      });
      expect(errors.map((error) => error.exceptionAsString()).toList(), isEmpty);
      final panel = tester.getRect(find.byKey(const ValueKey('agent-chat-panel')));
      expect(panel.width, _safeRect(folded).width);
    });

    testWidgets('the panel follows an unfold while open and leaves room for the content', (tester) async {
      final folded = _windows[2];
      final unfolded = _windows[0];
      await _pumpWindow(tester, folded);
      await tester.tap(find.byKey(const ValueKey('feature:agent')));
      await tester.pumpAndSettle();
      tester.view.physicalSize = unfolded.size;
      await tester.pumpAndSettle();
      final panel = tester.getRect(find.byKey(const ValueKey('agent-chat-panel')));
      expect(panel.width, lessThan(_safeRect(unfolded).width / 2));
      expect(panel.right, _safeRect(unfolded).right);
    });

    testWidgets('the launcher hides while the keyboard is visible', (tester) async {
      await _pumpWindow(tester, _windows[2]);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('feature:agent')), findsNothing);
    });
  });
}
