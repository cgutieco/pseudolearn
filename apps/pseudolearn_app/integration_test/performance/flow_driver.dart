import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';

final class FlowDriver {
  final WidgetTester tester;
  final IntegrationTestWidgetsFlutterBinding binding;
  final Map<String, Object?> durations = {};

  FlowDriver(this.tester, this.binding);

  AppLocalizations get l10n =>
      AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

  Finder get editableCode => find.descendant(
    of: find.byType(CodeField),
    matching: find.byType(EditableText),
  );

  Future<void> settleFor(Duration duration) async {
    final clock = Stopwatch()..start();
    while (clock.elapsed < duration) {
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> waitUntil(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final clock = Stopwatch()..start();
    while (!condition()) {
      if (clock.elapsed > timeout) {
        throw StateError('Timed out after ${clock.elapsed} on: ${_visibleTexts()}');
      }
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  List<String> _visibleTexts() => find
      .byType(Text)
      .evaluate()
      .map((element) => (element.widget as Text).data ?? '')
      .where((text) => text.isNotEmpty)
      .take(40)
      .toList();

  Future<void> waitFor(Finder finder, {Duration? timeout}) => waitUntil(
    () => finder.evaluate().isNotEmpty,
    timeout: timeout ?? const Duration(seconds: 60),
  );

  Future<void> tapFirst(Finder finder) async {
    await waitFor(finder);
    await tester.tap(finder.first);
    await tester.pump(const Duration(milliseconds: 16));
  }

  Future<void> measure(String name, Future<void> Function() flow) async {
    debugPrint('flow $name started');
    final clock = Stopwatch()..start();
    await binding.watchPerformance(flow, reportKey: name);
    durations[name] = clock.elapsedMilliseconds;
    debugPrint('flow $name took ${clock.elapsedMilliseconds} ms');
  }
}
