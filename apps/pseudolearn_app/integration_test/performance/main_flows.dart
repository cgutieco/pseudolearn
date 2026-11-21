import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';

import 'flow_driver.dart';
import 'flow_programs.dart';

Future<void> replaceCode(FlowDriver driver, String source) async {
  await driver.tester.enterText(driver.editableCode, source);
  await driver.settleFor(const Duration(milliseconds: 600));
}

Future<void> skipOnboardingIfShown(FlowDriver driver) async {
  await driver.settleFor(const Duration(seconds: 2));
  final skip = find.text(driver.l10n.onboardingActionSkip);
  if (skip.evaluate().isNotEmpty) {
    await driver.tapFirst(skip);
    await driver.settleFor(const Duration(seconds: 1));
  }
}

Future<void> createDocument(FlowDriver driver, String name) async {
  await driver.tapFirst(find.byKey(const ValueKey('feature:new-document')));
  final nameField = find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is AppTextField && widget.label == driver.l10n.dialogNewDocNameLabel,
    ),
    matching: find.byType(EditableText),
  );
  await driver.waitFor(nameField);
  await driver.tester.enterText(nameField, name);
  await driver.settleFor(const Duration(milliseconds: 500));
  await driver.tester.testTextInput.receiveAction(TextInputAction.done);
  await driver.settleFor(const Duration(milliseconds: 500));
  final create = find.text(driver.l10n.actionCreate);
  if (create.evaluate().isNotEmpty) await driver.tapFirst(create);
  await driver.waitFor(driver.editableCode);
  await driver.settleFor(const Duration(seconds: 1));
}

Future<void> typeProgramLineByLine(FlowDriver driver) async {
  final typed = StringBuffer();
  for (final line in typedProgramLines) {
    for (final word in line.split(' ')) {
      typed.write(typed.isEmpty || typed.toString().endsWith('\n') ? word : ' $word');
      await driver.tester.enterText(driver.editableCode, typed.toString());
      await driver.settleFor(const Duration(milliseconds: 120));
    }
    typed.write('\n');
  }
  await driver.settleFor(const Duration(seconds: 1));
}

Future<void> runToEnd(FlowDriver driver, {int continuations = 20}) async {
  await driver.tapFirst(find.byIcon(Icons.play_arrow));
  for (var round = 0; round <= continuations; round++) {
    await driver.settleFor(const Duration(milliseconds: 500));
    await driver.waitUntil(
      () => hasFinished(driver) || isPausedAtSafetyLimit(driver),
      timeout: const Duration(minutes: 10),
    );
    if (hasFinished(driver)) break;
    await driver.tapFirst(find.byIcon(Icons.play_arrow));
  }
  await driver.settleFor(const Duration(seconds: 1));
}

bool hasFinished(FlowDriver driver) =>
    find.text(driver.l10n.runResultFinished).evaluate().isNotEmpty ||
    find.text(driver.l10n.runResultError).evaluate().isNotEmpty;

bool isPausedAtSafetyLimit(FlowDriver driver) =>
    find.text(driver.l10n.runResultUiSafetyLimit).evaluate().isNotEmpty;

Future<void> stepRepeatedly(FlowDriver driver, int steps) async {
  await driver.tapFirst(find.byIcon(Icons.skip_next));
  for (var step = 1; step < steps; step++) {
    await driver.settleFor(const Duration(milliseconds: 150));
    final stepInto = find.byIcon(Icons.arrow_downward);
    await driver.tapFirst(stepInto.evaluate().isEmpty ? find.byIcon(Icons.skip_next) : stepInto);
  }
  await driver.settleFor(const Duration(milliseconds: 500));
  await driver.tapFirst(find.byIcon(Icons.stop));
  await driver.settleFor(const Duration(seconds: 1));
}

Future<void> openTabAndScroll(FlowDriver driver, String label) async {
  await driver.tapFirst(find.text(label));
  await driver.settleFor(const Duration(seconds: 1));
  await scrollVisibleContent(driver);
}

Future<void> scrollVisibleContent(FlowDriver driver) async {
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isEmpty) return;
  for (var gesture = 0; gesture < 3; gesture++) {
    await driver.tester.fling(scrollables.last, const Offset(0, -500), 1500, warnIfMissed: false);
    await driver.settleFor(const Duration(milliseconds: 700));
  }
  await driver.tester.fling(scrollables.last, const Offset(0, 1500), 3000, warnIfMissed: false);
  await driver.settleFor(const Duration(seconds: 1));
}
