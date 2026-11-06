import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/document/components/working_directory_note.dart';

const _explanation =
    'Los archivos que tu programa crea o lee se guardan en la carpeta de este algoritmo.';

Widget _wrap(Widget child) => MaterialApp(
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

void main() {
  group('WorkingDirectoryNote', () {
    testWidgets('before any run it explains without a path', (tester) async {
      await tester.pumpWidget(_wrap(const WorkingDirectoryNote(directory: null)));

      expect(find.text(_explanation), findsOneWidget);
      expect(find.byType(SelectableText), findsNothing);
    });

    testWidgets('after a run it shows the selectable folder path', (tester) async {
      await tester.pumpWidget(
        _wrap(const WorkingDirectoryNote(directory: '/docs/execution/doc-1')),
      );

      expect(find.text(_explanation), findsOneWidget);
      expect(find.text('/docs/execution/doc-1'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('a very long path wraps instead of overflowing', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _wrap(WorkingDirectoryNote(directory: '/var/mobile/${'a' * 200}')),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
