import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/library/library_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/presentation/knowledge/exercise_creation_launcher.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/test_dependencies.dart';

void main() {
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

  Widget buildTestApp({
    required LibraryCubit libraryCubit,
    required SettingsCubit settingsCubit,
    required GoRouter router,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LibraryCubit>.value(value: libraryCubit),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: MaterialApp.router(
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
        routerConfig: router,
      ),
    );
  }

  group('launchExerciseCreationDialog', () {
    testWidgets('creates document and navigates to /biblioteca/documento/:id on confirmation', (tester) async {
      final dependencies = buildTestDependencies();
      final libraryCubit = LibraryCubit(
        repository: dependencies.documentRepository,
        idGenerator: dependencies.identifiers,
        clock: dependencies.clock,
      );
      final settingsCubit = SettingsCubit(
        preferences: dependencies.preferences,
      );

      String? navigatedLocation;

      final router = GoRouter(
        initialLocation: '/conocimiento',
        routes: [
          GoRoute(
            path: '/conocimiento',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => launchExerciseCreationDialog(
                    context: context,
                    exercise: exercise,
                  ),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/biblioteca/documento/:id',
            builder: (context, state) {
              navigatedLocation = state.uri.toString();
              return Scaffold(
                body: Text('DocumentView: ${state.pathParameters['id']}'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          libraryCubit: libraryCubit,
          settingsCubit: settingsCubit,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Nuevo algoritmo'), findsOneWidget);
      expect(find.text('Suma de dos enteros'), findsOneWidget);

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      expect(find.text('DocumentView: id-1'), findsOneWidget);
      expect(navigatedLocation, '/biblioteca/documento/id-1');
      expect(libraryCubit.state.allDocuments.length, 1);
      expect(libraryCubit.state.allDocuments.first.title, 'Suma de dos enteros');
      expect(libraryCubit.state.allDocuments.first.exerciseId, 'CON-B1-E1');

      await libraryCubit.close();
      await settingsCubit.close();
    });

    testWidgets('cancelling dialog does not create document or navigate', (tester) async {
      final dependencies = buildTestDependencies();
      final libraryCubit = LibraryCubit(
        repository: dependencies.documentRepository,
        idGenerator: dependencies.identifiers,
        clock: dependencies.clock,
      );
      final settingsCubit = SettingsCubit(
        preferences: dependencies.preferences,
      );

      final router = GoRouter(
        initialLocation: '/conocimiento',
        routes: [
          GoRoute(
            path: '/conocimiento',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => launchExerciseCreationDialog(
                    context: context,
                    exercise: exercise,
                  ),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/biblioteca/documento/:id',
            builder: (context, state) => Scaffold(
              body: Text('DocumentView: ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          libraryCubit: libraryCubit,
          settingsCubit: settingsCubit,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Open Dialog'), findsOneWidget);
      expect(libraryCubit.state.allDocuments, isEmpty);

      await libraryCubit.close();
      await settingsCubit.close();
    });

    testWidgets('creates document with starterCode when exercise defines it', (tester) async {
      const exerciseWithStarter = Exercise(
        id: 'CON-A2-E3',
        title: 'Completar el perímetro de un cuadrado',
        statement: 'Completa el algoritmo.',
        level: ExerciseLevel.reproduce,
        kind: ExerciseKind.complete,
        moduleId: 'CON-A2',
        visibleCases: [],
        hiddenCases: [],
        starterCode: 'Proceso P\nFinProceso',
      );

      final dependencies = buildTestDependencies();
      final libraryCubit = LibraryCubit(
        repository: dependencies.documentRepository,
        idGenerator: dependencies.identifiers,
        clock: dependencies.clock,
      );
      final settingsCubit = SettingsCubit(
        preferences: dependencies.preferences,
      );

      final router = GoRouter(
        initialLocation: '/conocimiento',
        routes: [
          GoRoute(
            path: '/conocimiento',
            builder: (context, state) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => launchExerciseCreationDialog(
                    context: context,
                    exercise: exerciseWithStarter,
                  ),
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/biblioteca/documento/:id',
            builder: (context, state) => Scaffold(
              body: Text('DocumentView: ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestApp(
          libraryCubit: libraryCubit,
          settingsCubit: settingsCubit,
          router: router,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Crear'));
      await tester.pumpAndSettle();

      final docId = libraryCubit.state.allDocuments.first.id;
      final doc = await dependencies.documentRepository.loadDocument(docId);
      expect(doc!.content, 'Proceso P\nFinProceso');

      await libraryCubit.close();
      await settingsCubit.close();
    });
  });
}
