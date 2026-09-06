import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/presentation/knowledge/detail/components/exercise_detail_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

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
      builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: child),
    );
  }

  group('ExerciseDetailView Tests', () {
    const exercise = Exercise(
      id: 'CON-B1-E1',
      title: 'Sumar dos números',
      statement: 'Escribe un algoritmo que sume dos números y muestre el resultado.',
      level: ExerciseLevel.reproduce,
      kind: ExerciseKind.complete,
      moduleId: 'CON-B1',
      visibleCases: [
        ExerciseCase(inputs: ['2', '3'], expectedOutputs: ['5'], expectedValueKind: ExpectedValueKind.numeric),
      ],
      hiddenCases: [],
    );

    testWidgets('Renders statement, badges, visible cases, and invokes the callback on tap', (tester) async {
      Exercise? openedExercise;

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseDetailView(
            content: const ExerciseDetailContent(exercise: exercise),
            onOpenInNewDocument: (e) => openedExercise = e,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Escribe un algoritmo que sume dos números y muestre el resultado.'), findsOneWidget);
      expect(find.text('Nivel 1 · Reproducir'), findsOneWidget);
      expect(find.text('Completar'), findsOneWidget);
      expect(find.text('Entrada: 2, 3'), findsOneWidget);
      expect(find.text('Salida esperada: 5'), findsOneWidget);
      expect(find.text('Abrir en un documento nuevo'), findsOneWidget);

      await tester.tap(find.text('Abrir en un documento nuevo'));
      await tester.pump();
      expect(openedExercise, equals(exercise));
    });

    testWidgets('Renders without a visible-cases section when the exercise has none', (tester) async {
      const exerciseWithoutCases = Exercise(
        id: 'CON-B1-E2',
        title: 'Diseñar un algoritmo',
        statement: 'Diseña un algoritmo abierto.',
        level: ExerciseLevel.design,
        kind: ExerciseKind.create,
        visibleCases: [],
        hiddenCases: [],
      );

      await tester.pumpWidget(
        buildTestWidget(
          ExerciseDetailView(
            content: const ExerciseDetailContent(exercise: exerciseWithoutCases),
            onOpenInNewDocument: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Diseña un algoritmo abierto.'), findsOneWidget);
      expect(find.text('Casos de prueba visibles:'), findsNothing);
    });

    testWidgets('Renders completed badge when isCompleted is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          ExerciseDetailView(
            content: const ExerciseDetailContent(exercise: exercise, isCompleted: true),
            onOpenInNewDocument: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Superado'), findsOneWidget);
    });
  });
}
