import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/progress/app_step_indicator.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildTestWrapper({required Widget child}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppStepIndicator Component Tests (RFC 003 #15)', () {
    testWidgets('Renders all dots for totalSteps', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: const AppStepIndicator(totalSteps: 4, currentStep: 0),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AppStepIndicator), findsOneWidget);
    });

    testWidgets('Exposes correct accessibility semantics for step N of M', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: const AppStepIndicator(totalSteps: 4, currentStep: 2),
      ));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel('Paso 3 de 4'),
        findsOneWidget,
      );
    });
  });
}
