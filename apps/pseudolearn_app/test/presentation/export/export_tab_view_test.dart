import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/presentation/components/button/app_copy_button.dart';
import 'package:pseudolearn_app/presentation/components/empty/app_empty_state.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/export/components/target_language_selector.dart';
import 'package:pseudolearn_app/presentation/export/export_tab_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildWrapper(Widget child) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: Scaffold(
      body: DesignCanvas(
        child: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportTabView Presentation Tests (PANT-02D-F2)', () {
    testWidgets('renders unavailable state when exporter status is unavailable', (tester) async {
      const state = ExportState(
        status: ExportStatus.unavailable,
        unavailableReason: 'Motor de exportación en desarrollo',
      );

      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(
            state: state,
            onLanguageSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Motor de exportación en desarrollo'), findsOneWidget);
    });

    testWidgets('renders analysis error state when source code has errors', (tester) async {
      const state = ExportState(
        status: ExportStatus.analysisError,
      );

      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(
            state: state,
            onLanguageSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Programa con errores'), findsOneWidget);
      expect(find.text('Corrige los errores en el editor para ver el código exportado.'), findsOneWidget);
    });

    testWidgets('renders empty state when code is empty', (tester) async {
      const state = ExportState(
        status: ExportStatus.ready,
        exportedCode: '',
      );

      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(
            state: state,
            onLanguageSelected: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Escribe o abre un algoritmo para ver su traducción.'), findsOneWidget);
    });

    testWidgets('renders ready state with code field, copy button and language selector', (tester) async {
      TargetLanguageId? selectedLang;
      const state = ExportState(
        selectedLanguage: TargetLanguageId.python,
        status: ExportStatus.ready,
        exportedCode: 'def main():\n    print("hola")',
        notes: ['Nota: tipo inferido'],
      );

      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(
            state: state,
            onLanguageSelected: (lang) => selectedLang = lang,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TargetLanguageSelector), findsOneWidget);
      expect(find.byType(AppCopyButton), findsOneWidget);
      expect(find.byType(CodeField), findsOneWidget);
      expect(find.text('def main():\n    print("hola")'), findsOneWidget);
      expect(find.text('Nota: tipo inferido'), findsOneWidget);

      await tester.tap(find.text('Rust'));
      await tester.pumpAndSettle();

      expect(selectedLang, equals(TargetLanguageId.rust));
    });
  });
}
