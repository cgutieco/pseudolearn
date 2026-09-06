import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/document/components/tab_selector.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/border_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

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
    home: Scaffold(body: DesignCanvas(child: child)),
  );
}

void main() {
  group('TabSelector Component Tests (RFC 003 #13)', () {
    testWidgets('Renders all four tab items with localized labels', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.editor,
          onTabSelected: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Diagramas'), findsOneWidget);
      expect(find.text('Prueba de escritorio'), findsOneWidget);
      expect(find.text('Código equivalente'), findsOneWidget);
    });

    testWidgets('Tapping a tab fires onTabSelected with correct DocumentTabKind', (tester) async {
      DocumentTabKind? selected;
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.editor,
          onTabSelected: (tab) => selected = tab,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Diagramas'));
      await tester.pumpAndSettle();
      expect(selected, DocumentTabKind.flowchart);

      await tester.tap(find.text('Código equivalente'));
      await tester.pumpAndSettle();
      expect(selected, DocumentTabKind.equivalentCode);
    });

    testWidgets('the companion toggle is absent unless the canvas allows it', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(activeTab: DocumentTabKind.editor, onTabSelected: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Acompañar'), findsNothing);
    });

    testWidgets('the companion toggle reports each press', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.trace,
          onTabSelected: (_) {},
          canAccompany: true,
          onToggleCompanion: () => toggles++,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Acompañar'), findsOneWidget);
      await tester.tap(find.text('Acompañar'));
      await tester.pumpAndSettle();

      expect(toggles, 1);
    });

    testWidgets('without room for the label the toggle is only its icon', (tester) async {
      var toggles = 0;
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.flowchart,
          onTabSelected: (_) {},
          canAccompany: true,
          showsCompanionLabel: false,
          companionDirection: Axis.vertical,
          onToggleCompanion: () => toggles++,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Acompañar'), findsNothing);
      expect(find.byIcon(Icons.crop_square), findsOneWidget);

      await tester.tap(find.byIcon(Icons.crop_square));
      await tester.pumpAndSettle();

      expect(toggles, 1);
    });

    testWidgets('the active icon names the axis the split would use', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.flowchart,
          onTabSelected: (_) {},
          canAccompany: true,
          isAccompanying: true,
          companionDirection: Axis.vertical,
          onToggleCompanion: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.horizontal_split), findsOneWidget);
      expect(find.byIcon(Icons.vertical_split), findsNothing);
    });

    testWidgets('the toggle keeps a full touch target with no label', (tester) async {
      await tester.pumpWidget(_buildTestWrapper(
        child: TabSelector(
          activeTab: DocumentTabKind.flowchart,
          onTabSelected: (_) {},
          canAccompany: true,
          showsCompanionLabel: false,
          onToggleCompanion: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final target = tester.getSize(find.ancestor(
        of: find.byIcon(Icons.crop_square),
        matching: find.byType(InkWell),
      ).first);
      final barHeight = tester.getSize(find.byType(TabSelector)).height;

      expect(target.width, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
      expect(target.height, barHeight - BorderMetricsTokens.widthHairline);
    });
  });
}
