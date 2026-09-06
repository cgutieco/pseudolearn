import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/presentation/components/status_banner.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _wrap(Widget child) {
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
    home: Scaffold(body: DesignCanvas(child: child)),
  );
}

void main() {
  testWidgets('StatusBanner renders warning and success variants', (tester) async {
    await tester.pumpWidget(_wrap(
      const Column(
        children: [
          StatusBanner(
            severity: AppSeverity.warning,
            title: 'Tope alcanzado',
            message: 'Límite de pasos superado',
          ),
          StatusBanner(
            severity: AppSeverity.success,
            title: 'Éxito',
            message: 'Programa terminado',
          ),
        ],
      ),
    ));

    expect(find.text('Tope alcanzado'), findsOneWidget);
    expect(find.text('Límite de pasos superado'), findsOneWidget);
    expect(find.text('Éxito'), findsOneWidget);
    expect(find.text('Programa terminado'), findsOneWidget);
  });

  testWidgets('a banner without a body shows only its title', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBanner(severity: AppSeverity.success, title: 'Éxito'),
    ));

    expect(find.text('Éxito'), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('a banner is only dismissible when it is given a way out', (tester) async {
    await tester.pumpWidget(_wrap(
      const StatusBanner(
        severity: AppSeverity.error,
        title: 'Detenida',
        message: 'Se dividió entre cero',
      ),
    ));

    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('the dismiss control reports each press', (tester) async {
    var dismissals = 0;
    await tester.pumpWidget(_wrap(
      StatusBanner(
        severity: AppSeverity.success,
        title: 'Éxito',
        onDismiss: () => dismissals++,
      ),
    ));

    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(dismissals, 1);
  });
}
