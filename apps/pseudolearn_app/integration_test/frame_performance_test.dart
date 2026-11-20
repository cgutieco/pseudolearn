import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pseudolearn_app/main.dart' as application;

import 'performance/flow_driver.dart';
import 'performance/flow_programs.dart';
import 'performance/main_flows.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  testWidgets('main flows render within the frame budget', (tester) async {
    final driver = FlowDriver(tester, binding);
    binding.testTextInput.register();
    addTearDown(binding.testTextInput.unregister);
    await application.main();
    await skipOnboardingIfShown(driver);
    await driver.measure('open_document', () => createDocument(driver, 'Rendimiento ${DateTime.now().millisecondsSinceEpoch}'));
    await driver.measure('typing_with_diagnostics', () => typeProgramLineByLine(driver));
    await driver.measure('step_by_step', () => stepRepeatedly(driver, 40));
    await measureDocumentSurfaces(driver);
    await measureExtremePrograms(driver);
    await measureShellSurfaces(driver);
    binding.reportData = {...?binding.reportData, 'durations_millis': driver.durations};
  });
}

Future<void> measureDocumentSurfaces(FlowDriver driver) async {
  await driver.measure('diagrams', () => openTabAndScroll(driver, driver.l10n.tabDiagrams));
  await driver.measure(
    'equivalent_code',
    () => openTabAndScroll(driver, driver.l10n.tabEquivalentCode),
  );
  await driver.tapFirst(find.text(driver.l10n.tabEditor));
  await driver.settleFor(const Duration(seconds: 1));
}

Future<void> measureEditLatency(FlowDriver driver) async {
  for (final statements in const [50, 200, 500, 1000]) {
    final source = longProgram(statements);
    await replaceCode(driver, source);
    final samples = <int>[];
    for (var edit = 0; edit < 7; edit++) {
      final clock = Stopwatch()..start();
      await driver.tester.enterText(driver.editableCode, '$source\nEscribir $edit;');
      samples.add(clock.elapsedMilliseconds);
      await driver.settleFor(const Duration(milliseconds: 300));
    }
    samples.sort();
    driver.durations['edit_latency_median_${statements}_statements'] = samples[samples.length ~/ 2];
    debugPrint('flow edit latency $statements statements took ${samples[samples.length ~/ 2]} ms');
  }
}

Future<void> measureExtremePrograms(FlowDriver driver) async {
  await measureEditLatency(driver);
  await replaceCode(driver, outputProgram(1500));
  await driver.measure('continuous_execution_1500_lines', () => runToEnd(driver));
  await driver.measure('long_program_load_3000_statements', () async {
    await replaceCode(driver, longProgram(3000));
    await driver.settleFor(const Duration(seconds: 2));
  });
  await driver.measure('long_program_typing', () async {
    final source = longProgram(3000);
    for (var edit = 0; edit < 5; edit++) {
      await driver.tester.enterText(driver.editableCode, '$source\nEscribir $edit;');
      await driver.settleFor(const Duration(milliseconds: 150));
    }
  });
  await replaceCode(driver, branchingProgram(150));
  await driver.measure(
    'large_diagram_150_branches',
    () => openTabAndScroll(driver, driver.l10n.tabDiagrams),
  );
  await driver.tapFirst(find.text(driver.l10n.tabEditor));
  await driver.settleFor(const Duration(seconds: 1));
}

Future<void> measureShellSurfaces(FlowDriver driver) async {
  await driver.tapFirst(find.byIcon(Icons.arrow_back));
  await driver.settleFor(const Duration(seconds: 1));
  await driver.measure('knowledge_base', () async {
    await driver.tapFirst(find.text(driver.l10n.navKnowledge));
    await driver.settleFor(const Duration(seconds: 1));
    await scrollVisibleContent(driver);
  });
  await driver.measure('learning_progress', () async {
    await driver.tapFirst(find.text(driver.l10n.navProgress));
    await driver.settleFor(const Duration(seconds: 1));
    await scrollVisibleContent(driver);
  });
  await driver.tapFirst(find.text(driver.l10n.navLibrary));
  await driver.settleFor(const Duration(seconds: 1));
  final launcher = find.byKey(const ValueKey('feature:agent'));
  if (launcher.evaluate().isEmpty) return;
  await driver.measure('agent_panel', () async {
    await driver.tapFirst(launcher);
    await driver.settleFor(const Duration(seconds: 2));
    await scrollVisibleContent(driver);
  });
}
