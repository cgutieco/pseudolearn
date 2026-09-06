import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/library/dialogs/delete_rename_document_dialog.dart';
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
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
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

  group('RenameDocumentDialog', () {
    testWidgets('shows empty error when submitting with empty title', (tester) async {
      String? confirmedTitle;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showRenameDocumentDialog(
          context: context,
          currentTitle: 'Original',
          onConfirm: (title) => confirmedTitle = title,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Renombrar'));
      await tester.pumpAndSettle();

      expect(find.text('El nombre no puede estar vacío'), findsOneWidget);
      expect(confirmedTitle, isNull);
    });

    testWidgets('shows duplicate error when title matches another document in existingTitles', (tester) async {
      String? confirmedTitle;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showRenameDocumentDialog(
          context: context,
          currentTitle: 'Doc A',
          existingTitles: ['Doc A', 'Doc B'],
          onConfirm: (title) => confirmedTitle = title,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'doc b');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Renombrar'));
      await tester.pumpAndSettle();

      expect(find.text('Ya existe un documento con este nombre'), findsOneWidget);
      expect(confirmedTitle, isNull);
    });

    testWidgets('allows keeping own title when submitting', (tester) async {
      String? confirmedTitle;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showRenameDocumentDialog(
          context: context,
          currentTitle: 'Doc A',
          existingTitles: ['Doc A', 'Doc B'],
          onConfirm: (title) => confirmedTitle = title,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Renombrar'));
      await tester.pumpAndSettle();

      expect(confirmedTitle, 'Doc A');
      expect(find.text('Renombrar algoritmo'), findsNothing);
    });
  });

  group('DeleteDocumentDialog', () {
    testWidgets('calls onConfirm when delete button is pressed', (tester) async {
      var deleted = false;
      await tester.pumpWidget(buildTestApp(
        onOpen: (context) => showDeleteDocumentDialog(
          context: context,
          documentTitle: 'Mi Algoritmo',
          onConfirm: () => deleted = true,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Eliminar algoritmo'), findsOneWidget);
      expect(
        find.textContaining('¿Estás seguro de que deseas eliminar'),
        findsOneWidget,
      );

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
      expect(find.text('Eliminar algoritmo'), findsNothing);
    });
  });
}
