import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/brand/brand_lockup.dart';
import 'package:pseudolearn_app/presentation/brand/brand_lockup_layout.dart';
import 'package:pseudolearn_app/presentation/brand/brand_symbol.dart';
import 'package:pseudolearn_app/presentation/brand/brand_wordmark.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/brand_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_primitives.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('BrandSymbol', () {
    testWidgets('takes exactly the square it is given', (tester) async {
      await _pump(tester, const BrandSymbol(size: 32, color: ColorPrimitives.brand700));

      expect(tester.getSize(find.byType(BrandSymbol)), const Size(32, 32));
    });

    testWidgets('is decorative: it announces nothing to the screen reader', (tester) async {
      await _pump(tester, const BrandSymbol(size: 32, color: ColorPrimitives.brand700));

      expect(find.bySemanticsLabel('PseudoLearn'), findsNothing);
    });

    testWidgets('a size of zero paints nothing instead of failing', (tester) async {
      await _pump(tester, const BrandSymbol(size: 0, color: ColorPrimitives.brand700));

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(BrandSymbol)), Size.zero);
    });
  });

  group('BrandWordmark', () {
    testWidgets('measures its own ink box, not the typographic box', (tester) async {
      await _pump(tester, const BrandWordmark(typeSize: 100, color: ColorPrimitives.brand900));

      final size = tester.getSize(find.byType(BrandWordmark));
      expect(size.width, closeTo(BrandMetricsTokens.wordmarkInkWidth * 100, 0.001));
      expect(size.height, closeTo(BrandMetricsTokens.wordmarkInkHeight * 100, 0.001));
    });

    testWidgets('says the product name to the screen reader', (tester) async {
      await _pump(tester, const BrandWordmark(typeSize: 20, color: ColorPrimitives.brand900));

      expect(find.bySemanticsLabel('PseudoLearn'), findsOneWidget);
    });
  });

  group('BrandLockup', () {
    testWidgets('the horizontal composition adds its clear space around the box', (tester) async {
      const typeSize = 20.0;
      final layout = BrandLockupLayout.horizontal(typeSize);
      await _pump(tester, const BrandLockup(typeSize: typeSize));

      final size = tester.getSize(find.byType(BrandLockup));
      expect(size.width, closeTo(layout.size.width + layout.clearSpace * 2, 0.001));
      expect(size.height, closeTo(layout.size.height + layout.clearSpace * 2, 0.001));
    });

    testWidgets('the vertical composition stacks plate over wordmark', (tester) async {
      const typeSize = 20.0;
      await _pump(
        tester,
        const BrandLockup(typeSize: typeSize, orientation: BrandLockupOrientation.vertical),
      );

      final lockup = tester.getRect(find.byType(BrandLockup));
      final wordmark = tester.getRect(find.byType(BrandWordmark));
      final symbol = tester.getRect(find.byType(BrandSymbol));
      expect(symbol.bottom, lessThan(wordmark.top));
      expect(lockup.width, greaterThan(lockup.height * 0.5));
    });

    testWidgets('the plate follows the icon appearance of the active theme', (tester) async {
      await _pump(tester, const BrandLockup(typeSize: 20), theme: AppTheme.dark());

      final symbol = tester.widget<BrandSymbol>(find.byType(BrandSymbol));
      expect(symbol.color, ColorPrimitives.brand100);
    });
  });
}
