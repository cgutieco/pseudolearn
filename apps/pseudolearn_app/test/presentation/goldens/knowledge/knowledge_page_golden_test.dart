import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_state.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/knowledge_section_selector.dart';
import 'package:pseudolearn_app/presentation/knowledge/knowledge_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const _routeState = LearningRouteState(
  status: LearningRouteStatus.success,
  trackA: [
    KnowledgeEntry(
      id: 'CON-A1',
      type: KnowledgeEntryType.module,
      title: 'Qué es un algoritmo',
      summary: 'Secuencia, precisión y ambigüedad, sin escribir ninguna línea de código todavía.',
    ),
  ],
  trackB: [
    KnowledgeEntry(
      id: 'CON-B1',
      type: KnowledgeEntryType.module,
      title: 'Variables y tipos de datos',
      summary: 'Aprende a declarar y utilizar variables numéricas, cadenas y lógicas en pseudocódigo.',
    ),
  ],
  filteredTrackA: [
    KnowledgeEntry(
      id: 'CON-A1',
      type: KnowledgeEntryType.module,
      title: 'Qué es un algoritmo',
      summary: 'Secuencia, precisión y ambigüedad, sin escribir ninguna línea de código todavía.',
    ),
  ],
  filteredTrackB: [
    KnowledgeEntry(
      id: 'CON-B1',
      type: KnowledgeEntryType.module,
      title: 'Variables y tipos de datos',
      summary: 'Aprende a declarar y utilizar variables numéricas, cadenas y lógicas en pseudocódigo.',
    ),
  ],
  visitedModuleIds: {'CON-A1'},
);

const _specificationEntries = [
  KnowledgeEntry(
    id: 'spec-tipos',
    type: KnowledgeEntryType.specificationSection,
    title: 'Tipos primitivos',
    summary: 'Enteros, reales, cadenas y lógicos, con sus rangos exactos.',
  ),
  KnowledgeEntry(
    id: 'reference-classic-spanish',
    type: KnowledgeEntryType.reference,
    title: 'Referencia de sintaxis (Español)',
    summary: 'Resumen completo de palabras reservadas, tipos y operadores del perfil español clásico.',
    profileId: SyntaxProfileId.classicSpanish,
  ),
];

const _exercise1 = Exercise(
  id: 'CON-B1-E1',
  title: 'Suma de dos enteros',
  statement: 'Solicita dos números e imprime su resultado.',
  level: ExerciseLevel.reproduce,
  kind: ExerciseKind.create,
  moduleId: 'CON-B1',
  visibleCases: [],
  hiddenCases: [],
);

const _exercise2 = Exercise(
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

const _bankState = ExerciseBankState(
  status: ExerciseBankStatus.success,
  allExercises: [_exercise1, _exercise2],
  filteredExercises: [_exercise1, _exercise2],
  completedExerciseIds: {'CON-B1-E1'},
  availableModuleIds: ['CON-B1', 'CON-B4'],
  availableConstructs: [AstConstruct.countedLoop],
);

const _knowledgeState = KnowledgeState(
  status: KnowledgeStatus.success,
  specificationEntries: _specificationEntries,
  filteredSpecificationEntries: _specificationEntries,
);

Future<void> _pumpKnowledgeView(
  WidgetTester tester, {
  required Size size,
  required ThemeData theme,
  required KnowledgeSectionKind activeSection,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
      home: KnowledgeView(
        knowledgeState: _knowledgeState,
        routeState: _routeState,
        exerciseBankState: _bankState,
        activeSection: activeSection,
        searchController: TextEditingController(),
        onSearchChanged: (_) {},
        onSectionSelected: (_) {},
        onLevelSelected: (_) {},
        onModuleSelected: (_) {},
        onConstructSelected: (_) {},
        onClearFilters: () {},
        onOpenEntry: (_) {},
        onOpenExercise: (_) {},
        onRetry: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('KnowledgePage Goldens (CON-F12/CON-F14) — three widths, two themes, route section', () {
    final widths = <String, double>{
      'compact': 360,
      'medium': 600,
      'expanded': 960,
    };

    for (final entry in widths.entries) {
      testWidgets('${entry.key} · light', (tester) async {
        await _pumpKnowledgeView(
          tester,
          size: Size(entry.value, 800),
          theme: AppTheme.light(),
          activeSection: KnowledgeSectionKind.route,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_${entry.key}_light.png'),
        );
      });

      testWidgets('${entry.key} · dark', (tester) async {
        await _pumpKnowledgeView(
          tester,
          size: Size(entry.value, 800),
          theme: AppTheme.dark(),
          activeSection: KnowledgeSectionKind.route,
        );
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('knowledge_${entry.key}_dark.png'),
        );
      });
    }
  });

  group('KnowledgePage Goldens (CON-F12/CON-F14) — specification and exercises sections', () {
    testWidgets('specification · medium · light', (tester) async {
      await _pumpKnowledgeView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.light(),
        activeSection: KnowledgeSectionKind.specification,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('knowledge_specification_medium_light.png'),
      );
    });

    testWidgets('specification · medium · dark', (tester) async {
      await _pumpKnowledgeView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.dark(),
        activeSection: KnowledgeSectionKind.specification,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('knowledge_specification_medium_dark.png'),
      );
    });

    testWidgets('exercises · medium · light', (tester) async {
      await _pumpKnowledgeView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.light(),
        activeSection: KnowledgeSectionKind.exercises,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('knowledge_exercises_medium_light.png'),
      );
    });

    testWidgets('exercises · medium · dark', (tester) async {
      await _pumpKnowledgeView(
        tester,
        size: const Size(600, 800),
        theme: AppTheme.dark(),
        activeSection: KnowledgeSectionKind.exercises,
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('knowledge_exercises_medium_dark.png'),
      );
    });
  });
}
