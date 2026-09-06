import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/blocks/data_block_views.dart';
import 'package:pseudolearn_app/presentation/knowledge/illustrations/memory_boxes_illustration.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Future<void> _pump(WidgetTester tester, FigureBlock block) async {
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(body: FigureBlockView(block: block)),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('FigureBlockView', () {
    testWidgets('Renders the catalog illustration and its caption for a known id', (tester) async {
      await _pump(
        tester,
        const FigureBlock(illustrationId: 'cajas-memoria', caption: 'Cajas de memoria con nombre'),
      );

      expect(find.byType(MemoryBoxesIllustration), findsOneWidget);
      expect(find.text('Cajas de memoria con nombre'), findsOneWidget);
    });

    testWidgets('Falls back to the caption alone for an unknown illustration id', (tester) async {
      await _pump(
        tester,
        const FigureBlock(illustrationId: 'no-existe', caption: 'Ilustración pendiente'),
      );

      expect(find.byType(MemoryBoxesIllustration), findsNothing);
      expect(find.text('Ilustración pendiente'), findsOneWidget);
    });
  });
}
