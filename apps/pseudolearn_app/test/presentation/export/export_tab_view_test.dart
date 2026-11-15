import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/export/export_blocker.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/presentation/components/button/app_copy_button.dart';
import 'package:pseudolearn_app/presentation/components/empty/app_empty_state.dart';
import 'package:pseudolearn_app/presentation/editor/code_field.dart';
import 'package:pseudolearn_app/presentation/export/components/target_language_selector.dart';
import 'package:pseudolearn_app/presentation/export/export_tab_view.dart';
import 'package:pseudolearn_app/composition/app_localization_delegates.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildWrapper(Widget child, [Locale locale = const Locale('es')]) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: appLocalizationDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.light(),
    home: Scaffold(
      body: DesignCanvas(
        child: child,
      ),
    ),
  );
}

const ExportState _withheld = ExportState(
  selectedLanguage: TargetLanguageId.rust,
  status: ExportStatus.unavailable,
  blockers: [
    ExportBlocker(
      construct: 'input',
      origin: ProgramNodeId(3),
      range: SourceRange(
        startOffset: 4,
        endOffset: 10,
        startLine: 2,
        startColumn: 1,
        endLine: 2,
        endColumn: 7,
      ),
    ),
    ExportBlocker(
      construct: 'switch',
      origin: ProgramNodeId(5),
      range: SourceRange(
        startOffset: 12,
        endOffset: 30,
        startLine: 3,
        startColumn: 1,
        endLine: 5,
        endColumn: 9,
      ),
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExportTabView Presentation Tests', () {
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

    testWidgets('names the withheld constructs and their line in Spanish', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(state: _withheld, onLanguageSelected: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('no tiene un código equivalente comprobado en Rust: input, switch'),
        findsOneWidget,
      );
      expect(find.textContaining('línea 2'), findsOneWidget);
      expect(find.byType(CodeField), findsNothing);
      expect(find.byType(AppCopyButton), findsNothing);
    });

    testWidgets('names the withheld constructs and their line in English', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          ExportTabView(state: _withheld, onLanguageSelected: (_) {}),
          const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('no verified equivalent code in Rust: input, switch'),
        findsOneWidget,
      );
      expect(find.textContaining('line 2'), findsOneWidget);
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
