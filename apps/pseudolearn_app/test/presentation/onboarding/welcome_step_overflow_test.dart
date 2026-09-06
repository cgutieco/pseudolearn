import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/welcome_step_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pumpWelcome(WidgetTester tester, double textScale) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: DesignCanvas(child: child ?? const SizedBox.shrink()),
        );
      },
      home: const Scaffold(
        body: SingleChildScrollView(child: WelcomeStepView()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('WelcomeStepView text scaling', () {
    testWidgets('fits the smallest canvas at the default scale',
        (tester) async {
      await _pumpWelcome(tester, 1.0);

      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomeStepView), findsOneWidget);
    });

    testWidgets('fits the smallest canvas at the largest supported scale',
        (tester) async {
      await _pumpWelcome(tester, 2.0);

      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomeStepView), findsOneWidget);
    });
  });
}
