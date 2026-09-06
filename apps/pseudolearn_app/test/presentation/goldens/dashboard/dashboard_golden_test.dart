import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/dashboard/dashboard_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../dashboard/dashboard_view_fixture.dart';

Future<void> _pumpDashboard(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: DashboardView(
        state: populatedDashboardState(),
        lastSyncAt: DateTime(2026, 9, 1, 8, 30),
        onOpenModule: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('Dashboard goldens (PANT-06-F5) — eight widths, two themes', () {
    final widths = <String, double>{
      'compact': 360,
      'compact_wide': 480,
      'medium': 600,
      'medium_wide': 800,
      'expanded': 960,
      'expanded_desktop': 1280,
      'expanded_wide': 1920,
      'expanded_ultrawide': 2560,
    };

    for (final entry in widths.entries) {
      testWidgets('${entry.key} · light', (tester) async {
        await _pumpDashboard(
          tester,
          size: Size(entry.value, 1000),
          theme: AppTheme.light(),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('dashboard_${entry.key}_light.png'),
        );
      });

      testWidgets('${entry.key} · dark', (tester) async {
        await _pumpDashboard(
          tester,
          size: Size(entry.value, 1000),
          theme: AppTheme.dark(),
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('dashboard_${entry.key}_dark.png'),
        );
      });
    }
  });
}
