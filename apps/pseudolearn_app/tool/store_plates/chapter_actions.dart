import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../product/scene_actions.dart';

const ValueKey<String> agentLauncherKey = ValueKey<String>('feature:agent');
const ValueKey<String> agentComposerKey = ValueKey<String>('agent-composer');
const ValueKey<String> agentSendKey = ValueKey<String>('agent-send');

SceneAction openNodo() {
  return (stage) async {
    await stage.tester.tap(find.byKey(agentLauncherKey));
    await stage.tester.pumpAndSettle();
  };
}

SceneAction askNodo(String question) {
  return (stage) async {
    final field = find.descendant(
      of: find.byKey(agentComposerKey),
      matching: find.byType(TextField),
    );
    await stage.tester.enterText(field, question);
    await stage.tester.tap(find.byKey(agentSendKey));
    await stage.tester.pumpAndSettle();
    await stage.tester.testTextInput.receiveAction(TextInputAction.done);
    FocusManager.instance.primaryFocus?.unfocus();
    await stage.tester.pumpAndSettle();
  };
}

SceneAction selectRustExport() {
  return (stage) async => stage.tapText('Rust');
}
