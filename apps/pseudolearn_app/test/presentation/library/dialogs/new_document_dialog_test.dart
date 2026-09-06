import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/library/dialogs/new_document_dialog.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  Widget buildTestApp({
    required void Function(BuildContext context) onOpen,
  }) {
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
      builder: (context, child) =>
          DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => onOpen(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('NewDocumentDialog', () {
    testWidgets('shows empty error when submitting with empty title',
        (tester) async {
      String? confirmedTitle;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showNewDocumentDialog(
          context: context,
          onConfirm: (title, profile) => confirmedTitle = title,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo algoritmo'), findsOneWidget);

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre no puede estar vacío'), findsOneWidget);
      expect(confirmedTitle, isNull);
    });

    testWidgets('shows duplicate error when title exists in existingTitles',
        (tester) async {
      String? confirmedTitle;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showNewDocumentDialog(
          context: context,
          existingTitles: ['Algoritmo Principal'],
          onConfirm: (title, profile) => confirmedTitle = title,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextField), '  algoritmo   principal ');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(
          find.text('Ya existe un documento con este nombre'), findsOneWidget);
      expect(confirmedTitle, isNull);

      await tester.enterText(find.byType(TextField), 'Algoritmo Secundario');
      await tester.pumpAndSettle();
      expect(find.text('Ya existe un documento con este nombre'), findsNothing);

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();
      expect(confirmedTitle, 'Algoritmo Secundario');
      expect(find.text('Nuevo algoritmo'), findsNothing);
    });

    testWidgets('submits normalized title and selected profile',
        (tester) async {
      String? confirmedTitle;
      SyntaxProfileId? confirmedProfile;

      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showNewDocumentDialog(
          context: context,
          initialTitle: '  Mi   Algoritmo  ',
          onConfirm: (title, profile) {
            confirmedTitle = title;
            confirmedProfile = profile;
          },
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(confirmedTitle, 'Mi Algoritmo');
      expect(confirmedProfile, SyntaxProfileId.classicSpanish);
      expect(find.text('Nuevo algoritmo'), findsNothing);
    });
  });
}
