import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/reference/reference_index_cubit.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_search_entry.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section_kind.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_reference_repository.dart';
import 'package:pseudolearn_app/application/knowledge/bank/exercise_bank_state.dart';
import 'package:pseudolearn_app/application/knowledge/knowledge_state.dart';
import 'package:pseudolearn_app/application/knowledge/route/learning_route_state.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_card_grid.dart';
import 'package:pseudolearn_app/presentation/knowledge/components/knowledge_section_selector.dart';
import 'package:pseudolearn_app/presentation/knowledge/knowledge_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

Future<ReferenceIndexCubit> _loadedIndex() async {
  final cubit = ReferenceIndexCubit(
    repository: FakeReferenceRepository(
      index: const ReferenceIndex([
        ReferencePart(id: 'parte-3', number: 'III', title: 'Tipos y valores', summary: 'Datos', sections: [
          ReferenceIndexEntry(
            id: 'tipos.primitivos',
            number: '3.1',
            kind: ReferenceSectionKind.type,
            title: [ReferenceTextRun('Tipos primitivos')],
            phrase: [ReferenceTextRun('Cinco tipos')],
          ),
        ]),
      ]),
      search: const [ReferenceSearchEntry(text: 'Tipos primitivos', kind: 'title', sectionId: 'tipos.primitivos')],
    ),
  );
  await cubit.load(const ReferenceEdition(language: UiLanguageId.spanish, profile: SyntaxProfileId.classicSpanish));
  return cubit;
}

void main() {
  Widget buildTestApp(Widget child) {
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
      home: DesignCanvas(child: child),
    );
  }

  Widget buildView({
    required KnowledgeSectionKind activeSection,
    KnowledgeState knowledgeState = const KnowledgeState(status: KnowledgeStatus.success),
    LearningRouteState routeState = const LearningRouteState(status: LearningRouteStatus.success),
    ExerciseBankState exerciseBankState = const ExerciseBankState(status: ExerciseBankStatus.success),
    ValueChanged<KnowledgeSectionKind>? onSectionSelected,
    ValueChanged<KnowledgeEntry>? onOpenEntry,
    ValueChanged<String>? onOpenExercise,
    VoidCallback? onRetry,
  }) {
    return KnowledgeView(
      knowledgeState: knowledgeState,
      routeState: routeState,
      exerciseBankState: exerciseBankState,
      activeSection: activeSection,
      searchController: TextEditingController(text: knowledgeState.searchQuery),
      onSearchChanged: (_) {},
      onSectionSelected: onSectionSelected ?? (_) {},
      onLevelSelected: (_) {},
      onModuleSelected: (_) {},
      onConstructSelected: (_) {},
      onClearFilters: () {},
      onOpenEntry: onOpenEntry ?? (_) {},
      onOpenExercise: onOpenExercise ?? (_) {},
      onRetry: onRetry ?? () {},
    );
  }

  group('KnowledgeView (CON-F12 / CON-F14)', () {
    testWidgets('route section shows the content-empty state', (tester) async {
      await tester.pumpWidget(buildTestApp(buildView(activeSection: KnowledgeSectionKind.route)));

      expect(find.text('Base de conocimiento'), findsOneWidget);
      expect(find.text('Sin contenido'), findsOneWidget);
    });

    testWidgets('specification section shows the search-empty state with the query in the message', (tester) async {
      final cubit = await _loadedIndex();
      cubit.search('xyz');
      await tester.pumpWidget(buildTestApp(BlocProvider.value(
        value: cubit,
        child: buildView(activeSection: KnowledgeSectionKind.specification),
      )));

      expect(find.text('Ninguna sección coincide con «xyz»'), findsOneWidget);
    });

    testWidgets('error view triggers retry', (tester) async {
      var retried = false;
      await tester.pumpWidget(buildTestApp(buildView(
        activeSection: KnowledgeSectionKind.route,
        knowledgeState: const KnowledgeState(status: KnowledgeStatus.error, errorMessage: 'Manifest failure'),
        onRetry: () => retried = true,
      )));

      expect(find.text('Error de contenido'), findsOneWidget);
      await tester.tap(find.text('Reintentar'));
      expect(retried, isTrue);
    });

    testWidgets('route section renders track cards in order with the visited mark', (tester) async {
      KnowledgeEntry? opened;
      const moduleA = KnowledgeEntry(
        id: 'con-a1',
        type: KnowledgeEntryType.module,
        title: 'Qué es un algoritmo',
        summary: 'Resumen A1',
      );
      const moduleB = KnowledgeEntry(
        id: 'con-b1',
        type: KnowledgeEntryType.module,
        title: 'Datos',
        summary: 'Resumen B1',
      );

      await tester.pumpWidget(buildTestApp(buildView(
        activeSection: KnowledgeSectionKind.route,
        routeState: const LearningRouteState(
          status: LearningRouteStatus.success,
          trackA: [moduleA],
          trackB: [moduleB],
          filteredTrackA: [moduleA],
          filteredTrackB: [moduleB],
          visitedModuleIds: {'con-a1'},
        ),
        onOpenEntry: (e) => opened = e,
      )));

      expect(find.text('Tramo A · Fundamentos'), findsOneWidget);
      expect(find.text('Tramo B · Imperativo y estructurado'), findsOneWidget);
      expect(find.text('Qué es un algoritmo'), findsOneWidget);
      expect(find.text('Datos'), findsOneWidget);
      expect(find.text('Visitado'), findsOneWidget);

      await tester.tap(find.text('Qué es un algoritmo'));
      expect(opened, moduleA);
    });

    testWidgets('specification section renders the index by parts', (tester) async {
      final cubit = await _loadedIndex();
      await tester.pumpWidget(buildTestApp(BlocProvider.value(
        value: cubit,
        child: buildView(activeSection: KnowledgeSectionKind.specification),
      )));

      expect(find.text('Tipos y valores'), findsOneWidget);
      expect(find.text('3.1'), findsOneWidget);
    });

    testWidgets('exercises section renders its entries as cards with bottom padding', (tester) async {
      const exercise = Exercise(
        id: 'CON-B1-E1',
        title: 'Suma de dos enteros',
        statement: 'Calcula la suma de dos enteros.',
        level: ExerciseLevel.reproduce,
        kind: ExerciseKind.create,
        moduleId: 'CON-B1',
        visibleCases: [],
        hiddenCases: [],
      );

      await tester.pumpWidget(buildTestApp(buildView(
        activeSection: KnowledgeSectionKind.exercises,
        exerciseBankState: const ExerciseBankState(
          status: ExerciseBankStatus.success,
          allExercises: [exercise],
          filteredExercises: [exercise],
          availableModuleIds: ['CON-B1'],
        ),
      )));

      expect(find.text('Suma de dos enteros'), findsOneWidget);
      expect(find.text('Nivel 1'), findsOneWidget);
      expect(find.text('Crear'), findsOneWidget);
      final grid = tester.widget<AppCardGrid>(find.byType(AppCardGrid));
      expect(grid.padding, const EdgeInsets.only(bottom: SpacingTokens.space6));
    });

    testWidgets('tapping a section tab dispatches onSectionSelected', (tester) async {
      KnowledgeSectionKind? selected;
      await tester.pumpWidget(buildTestApp(buildView(
        activeSection: KnowledgeSectionKind.route,
        onSectionSelected: (s) => selected = s,
      )));

      await tester.tap(find.text('Ejercicios'));
      expect(selected, KnowledgeSectionKind.exercises);
    });
  });
}
