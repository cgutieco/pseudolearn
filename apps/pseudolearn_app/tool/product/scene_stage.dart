import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';

final class SceneStage {
  final WidgetTester tester;

  const SceneStage(this.tester);

  BuildContext get appContext => tester.element(find.byType(Navigator).first);

  AppLocalizations get l10n => AppLocalizations.of(appContext)!;

  Future<void> tapIcon(IconData icon) async {
    await tester.tap(find.byIcon(icon).first);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String label) async {
    await tester.tap(find.text(label).first);
    await tester.pumpAndSettle();
  }
}
