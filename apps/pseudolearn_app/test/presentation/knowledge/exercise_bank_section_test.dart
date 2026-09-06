import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/empty/app_empty_state.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_card_grid.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/exercise_bank/exercise_bank_card.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/exercise_bank/exercise_bank_section.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/exercise_bank/exercise_filter_bar.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

void main() {
  Widget buildTestWidget(Widget child) {
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
      builder: (context, c) =>
          DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: child),
    );
  }

  group('ExerciseBankSection Widget Tests (CON-F14)', () {
    const exercise1 = Exercise(
      id: 'CON-B1-E1',
      title: 'Suma de dos números',
      statement: 'Calcula la suma de dos enteros.',
      level: ExerciseLevel.reproduce,
      kind: ExerciseKind.create,
      moduleId: 'CON-B1',
      visibleCases: [],
      hiddenCases: [],
    );

    const exercise2 = Exercise(
      id: 'CON-B4-E1',
      title: 'Tabla de multiplicar',
      statement: 'Usa un bucle contado para imprimir la tabla.',
      level: ExerciseLevel.compose,
      kind: ExerciseKind.complete,
      moduleId: 'CON-B4',
      visibleCases: [],
      hiddenCases: [],
      assertions: [
        ContainsConstructAssertion(
          requirement: 'Usa bucle Para',
          construct: AstConstruct.countedLoop,
        ),
      ],
    );

    const exercise3 = Exercise(
      id: 'CON-GEN-E1',
      title: 'Simulador bancario',
      statement: 'Diseña un sistema completo de cuentas.',
      level: ExerciseLevel.design,
      kind: ExerciseKind.modify,
      visibleCases: [],
      hiddenCases: [],
    );

    testWidgets('Renders exercise cards with badges and responds to tap',
        (tester) async {
      String? openedExerciseId;

      const state = ExerciseBankState(
        status: ExerciseBankStatus.success,
        allExercises: [exercise1, exercise2, exercise3],
        filteredExercises: [exercise1, exercise2, exercise3],
        completedExerciseIds: {'CON-B1-E1'},
        availableModuleIds: ['CON-B1', 'CON-B4'],
        availableConstructs: [AstConstruct.countedLoop],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseBankSection(
            state: state,
            onLevelSelected: (_) {},
            onModuleSelected: (_) {},
            onConstructSelected: (_) {},
            onClearFilters: () {},
            onOpenExercise: (id) => openedExerciseId = id,
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseFilterBar), findsOneWidget);
      expect(find.byType(ExerciseBankCard), findsNWidgets(3));
      final grid = tester.widget<AppCardGrid>(find.byType(AppCardGrid));
      expect(grid.padding, const EdgeInsets.only(bottom: SpacingTokens.space6));

      expect(find.text('Suma de dos números'), findsOneWidget);
      expect(find.text('Nivel 1'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
      expect(find.text('Superado'), findsOneWidget);

      expect(find.text('Tabla de multiplicar'), findsOneWidget);
      expect(find.text('Nivel 2'), findsOneWidget);
      expect(find.text('Completar'), findsOneWidget);

      expect(find.text('Simulador bancario'), findsOneWidget);
      expect(find.text('Nivel 3'), findsOneWidget);
      expect(find.text('Modificar'), findsOneWidget);

      await tester.tap(find.text('Tabla de multiplicar'));
      await tester.pump();
      expect(openedExerciseId, equals('CON-B4-E1'));
    });

    testWidgets('Renders empty filter result view with clear button',
        (tester) async {
      var cleared = false;

      const state = ExerciseBankState(
        status: ExerciseBankStatus.success,
        allExercises: [exercise1],
        filteredExercises: [],
        availableModuleIds: ['CON-B1'],
        selectedLevel: ExerciseLevel.design,
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseBankSection(
            state: state,
            onLevelSelected: (_) {},
            onModuleSelected: (_) {},
            onConstructSelected: (_) {},
            onClearFilters: () => cleared = true,
            onOpenExercise: (_) {},
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin resultados'), findsOneWidget);
      expect(
          find.text(
              'Ningún ejercicio coincide con los filtros o la búsqueda seleccionada.'),
          findsOneWidget);
      expect(find.text('Limpiar filtros'), findsNWidgets(2));

      await tester.tap(find.widgetWithText(AppButton, 'Limpiar filtros').last);
      await tester.pump();
      expect(cleared, isTrue);
    });

    testWidgets('Renders empty bank view when no exercises exist in catalog',
        (tester) async {
      const state = ExerciseBankState(
        status: ExerciseBankStatus.success,
        allExercises: [],
        filteredExercises: [],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseBankSection(
            state: state,
            onLevelSelected: (_) {},
            onModuleSelected: (_) {},
            onConstructSelected: (_) {},
            onClearFilters: () {},
            onOpenExercise: (_) {},
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin ejercicios'), findsOneWidget);
      expect(
          find.text(
              'No hay ejercicios disponibles en la base de conocimiento.'),
          findsOneWidget);
    });

    testWidgets('Renders error view with retry callback', (tester) async {
      var retried = false;

      const state = ExerciseBankState(
        status: ExerciseBankStatus.error,
        errorMessage: 'Fallo al cargar',
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseBankSection(
            state: state,
            onLevelSelected: (_) {},
            onModuleSelected: (_) {},
            onConstructSelected: (_) {},
            onClearFilters: () {},
            onOpenExercise: (_) {},
            onRetry: () => retried = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Error de contenido'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      expect(retried, isTrue);
    });
  });
}
