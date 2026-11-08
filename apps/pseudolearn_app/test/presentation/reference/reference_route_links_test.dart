import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/reference/reference_route_links.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/route_fixtures.dart';

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
  home: Scaffold(body: child),
);

void main() {
  testWidgets('shows a button per lesson that opens it', (tester) async {
    final opened = <String>[];
    await tester.pumpWidget(_app(ReferenceRouteLinks(lessons: sampleToc.lessons, onOpenLesson: opened.add)));

    expect(find.text('Aprender en la ruta'), findsOneWidget);
    expect(find.byIcon(Icons.school_outlined), findsNWidgets(sampleToc.lessons.length));
    await tester.tap(find.byIcon(Icons.school_outlined).last);
    expect(opened, [sampleToc.lessons.last.id]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a section that no lesson links shows nothing', (tester) async {
    await tester.pumpWidget(_app(ReferenceRouteLinks(lessons: const [], onOpenLesson: (_) {})));

    expect(find.text('Aprender en la ruta'), findsNothing);
    expect(find.byIcon(Icons.school_outlined), findsNothing);
  });

  testWidgets('without the route links provider the footer shows nothing', (tester) async {
    await tester.pumpWidget(_app(const ReferenceRouteLinksFooter(sectionId: 'control.si')));

    expect(find.text('Aprender en la ruta'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
