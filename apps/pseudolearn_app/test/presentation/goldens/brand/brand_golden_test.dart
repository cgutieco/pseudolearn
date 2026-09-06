import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/brand/brand_lockup.dart';
import 'package:pseudolearn_app/presentation/brand/brand_symbol.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_primitives.dart';

const List<double> _reductionSizes = <double>[16, 24, 32, 48];

const Map<String, String> _brandFaces = <String, String>{
  'IBMPlexMono': 'assets/fonts/IBMPlexMono-Medium.ttf',
  'IBMPlexSans': 'assets/fonts/IBMPlexSans-Bold.ttf',
};

Future<void> _loadBrandFaces() async {
  for (final entry in _brandFaces.entries) {
    final loader = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
    await loader.load();
  }
}

Future<void> _pump(WidgetTester tester, Size size, ThemeData theme, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
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

Widget _reductionRow(Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      for (final size in _reductionSizes)
        Padding(
          padding: const EdgeInsets.all(8),
          child: BrandSymbol(size: size, color: color),
        ),
    ],
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadBrandFaces();
  });

  group('Brand goldens', () {
    testWidgets('the symbol holds its turns down to 16 px · light', (tester) async {
      await _pump(tester, const Size(320, 120), AppTheme.light(),
          _reductionRow(ColorPrimitives.brand700));

      await expectLater(find.byType(MaterialApp), matchesGoldenFile('brand_symbol_light.png'));
    });

    testWidgets('the symbol holds its turns down to 16 px · dark', (tester) async {
      await _pump(tester, const Size(320, 120), AppTheme.dark(),
          _reductionRow(ColorPrimitives.brand300));

      await expectLater(find.byType(MaterialApp), matchesGoldenFile('brand_symbol_dark.png'));
    });

    testWidgets('the horizontal lockup · light', (tester) async {
      await _pump(tester, const Size(360, 120), AppTheme.light(),
          const BrandLockup(typeSize: 24));

      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('brand_lockup_horizontal_light.png'));
    });

    testWidgets('the horizontal lockup · dark', (tester) async {
      await _pump(tester, const Size(360, 120), AppTheme.dark(),
          const BrandLockup(typeSize: 24));

      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('brand_lockup_horizontal_dark.png'));
    });

    testWidgets('the vertical lockup · light', (tester) async {
      await _pump(tester, const Size(360, 260), AppTheme.light(),
          const BrandLockup(typeSize: 40, orientation: BrandLockupOrientation.vertical));

      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('brand_lockup_vertical_light.png'));
    });

    testWidgets('the vertical lockup · dark', (tester) async {
      await _pump(tester, const Size(360, 260), AppTheme.dark(),
          const BrandLockup(typeSize: 40, orientation: BrandLockupOrientation.vertical));

      await expectLater(
          find.byType(MaterialApp), matchesGoldenFile('brand_lockup_vertical_dark.png'));
    });
  });
}
