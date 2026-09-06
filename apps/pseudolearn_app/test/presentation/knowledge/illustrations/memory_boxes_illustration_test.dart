import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/knowledge/illustrations/memory_boxes_illustration.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildTestWidget({required Locale locale, required Size size}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(
      body: SizedBox(width: size.width, child: const MemoryBoxesIllustration()),
    ),
  );
}

void main() {
  group('MemoryBoxesIllustration', () {
    testWidgets('Renders its three named boxes with the current language', (tester) async {
      await tester.pumpWidget(_buildTestWidget(locale: const Locale('es'), size: const Size(600, 400)));
      await tester.pumpAndSettle();

      expect(find.text('contador'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('total'), findsOneWidget);
      expect(find.text('activo'), findsOneWidget);
    });

    testWidgets('Renders in English when the interface language changes', (tester) async {
      await tester.pumpWidget(_buildTestWidget(locale: const Locale('en'), size: const Size(600, 400)));
      await tester.pumpAndSettle();

      expect(find.text('counter'), findsOneWidget);
      expect(find.text('active'), findsOneWidget);
    });

    testWidgets('Fits without overflow on the narrowest canvas', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestWidget(locale: const Locale('es'), size: const Size(360, 400)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
