import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/knowledge/illustrations/memory_boxes_illustration.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, {required Size size, required ThemeData theme}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: DesignCanvas(child: Padding(padding: EdgeInsets.all(24), child: MemoryBoxesIllustration())),
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('MemoryBoxesIllustration goldens', () {
    testWidgets('medium · light', (tester) async {
      await _pump(tester, size: const Size(600, 300), theme: AppTheme.light());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('memory_boxes_medium_light.png'));
    });

    testWidgets('medium · dark', (tester) async {
      await _pump(tester, size: const Size(600, 300), theme: AppTheme.dark());
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('memory_boxes_medium_dark.png'));
    });
  });
}
