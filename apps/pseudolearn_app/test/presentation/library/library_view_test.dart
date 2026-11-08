import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/library/library_state.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/library/library_view.dart';
import 'package:pseudolearn_app/presentation/library/components/library_section_selector.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pseudolearn_app/application/sync/sync_cubit.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_connectivity_monitor.dart';
import '../../fakes/fake_sync_coordinator.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

void _setViewSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _buildTestApp(Widget child, {Size size = const Size(800, 600)}) {
  final syncCubit = SyncCubit(
    coordinator: FakeSyncCoordinator(),
    connectivityMonitor: FakeConnectivityMonitor(),
    authGateway: FakeAuthGateway(),
    repository: InMemoryDocumentRepository(),
    syncQueue: FakeSyncQueue(),
  );
  return BlocProvider<SyncCubit>.value(
    value: syncCubit,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
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
      ),
    ),
  );
}

void main() {
  group('LibraryView responsive action', () {
    testWidgets('renders AppIconButton on compact device class', (tester) async {
      _setViewSize(tester, const Size(390, 844));
      var newDocCalled = false;
      const state = LibraryState(
        status: LibraryStatus.success,
        allDocuments: [],
        filteredDocuments: [],
        searchQuery: '',
      );

      await tester.pumpWidget(_buildTestApp(
        LibraryView(
          state: state,
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          onNewDocument: () => newDocCalled = true,
          onOpenDocument: (_) {},
          onRenameDocument: (_) {},
          onDeleteDocument: (_) {},
        ),
        size: const Size(390, 844),
      ));

      expect(find.text('Mis algoritmos'), findsOneWidget);
      expect(find.byType(AppIconButton), findsOneWidget);

      await tester.tap(find.byType(AppIconButton));
      expect(newDocCalled, isTrue);
    });

    testWidgets('renders AppButton on expanded device class', (tester) async {
      _setViewSize(tester, const Size(1200, 800));
      var newDocCalled = false;
      const state = LibraryState(
        status: LibraryStatus.success,
        allDocuments: [],
        filteredDocuments: [],
        searchQuery: '',
      );

      await tester.pumpWidget(_buildTestApp(
        LibraryView(
          state: state,
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          onNewDocument: () => newDocCalled = true,
          onOpenDocument: (_) {},
          onRenameDocument: (_) {},
          onDeleteDocument: (_) {},
        ),
        size: const Size(1200, 800),
      ));

      expect(find.text('Mis algoritmos'), findsOneWidget);
      expect(find.byType(AppIconButton), findsNothing);
      expect(find.byType(AppButton), findsWidgets);

      final headerButton = find.widgetWithText(AppButton, 'Nuevo algoritmo').first;
      await tester.tap(headerButton);
      expect(newDocCalled, isTrue);
    });
  });

  group('LibraryView content', () {
    testWidgets('renders empty state when library has no documents', (tester) async {
      _setViewSize(tester, const Size(800, 600));
      const state = LibraryState(
        status: LibraryStatus.success,
        allDocuments: [],
        filteredDocuments: [],
        searchQuery: '',
      );

      await tester.pumpWidget(_buildTestApp(
        LibraryView(
          state: state,
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          onNewDocument: () {},
          onOpenDocument: (_) {},
          onRenameDocument: (_) {},
          onDeleteDocument: (_) {},
        ),
        size: const Size(800, 600),
      ));

      expect(find.text('Mis algoritmos'), findsOneWidget);
      expect(find.text('Sin algoritmos aún'), findsOneWidget);
      expect(find.text('Nuevo algoritmo'), findsWidgets);
    });

    testWidgets('renders document list when documents exist', (tester) async {
      _setViewSize(tester, const Size(800, 600));
      final doc1 = DocumentSummary(
        id: '1',
        title: 'Algoritmo Fibonacci',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 8, 15),
        updatedAt: DateTime(2026, 8, 15),
      );
      final doc2 = DocumentSummary(
        id: '2',
        title: 'Algoritmo Matrices',
        profileId: SyntaxProfileId.english,
        revision: 1,
        createdAt: DateTime(2026, 8, 15),
        updatedAt: DateTime(2026, 8, 15),
      );

      final state = LibraryState(
        status: LibraryStatus.success,
        allDocuments: [doc1, doc2],
        filteredDocuments: [doc1, doc2],
        searchQuery: '',
      );

      await tester.pumpWidget(_buildTestApp(
        LibraryView(
          state: state,
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          onNewDocument: () {},
          onOpenDocument: (_) {},
          onRenameDocument: (_) {},
          onDeleteDocument: (_) {},
        ),
        size: const Size(800, 600),
      ));

      expect(find.text('Algoritmo Fibonacci'), findsOneWidget);
      expect(find.text('Algoritmo Matrices'), findsOneWidget);
      expect(find.text('ES'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);
    });
  });

  group('LibraryView sections', () {
    const emptyLibrary = LibraryState(
      status: LibraryStatus.success,
      allDocuments: [],
      filteredDocuments: [],
      searchQuery: '',
    );

    Widget viewWith({
      required LibrarySection section,
      ValueChanged<LibrarySection>? onSectionSelected,
      VoidCallback? onCreateExercise,
      LibraryState state = emptyLibrary,
    }) {
      return LibraryView(
        state: state,
        searchController: TextEditingController(),
        onSearchChanged: (_) {},
        onNewDocument: () {},
        onOpenDocument: (_) {},
        onRenameDocument: (_) {},
        onDeleteDocument: (_) {},
        section: section,
        onSectionSelected: onSectionSelected ?? (_) {},
        exercises: LibraryExercisesSlot(
          content: const Text('exercise-list'),
          count: 3,
          onCreate: onCreateExercise ?? () {},
        ),
      );
    }

    testWidgets('without an exercises slot there are no section tabs', (tester) async {
      _setViewSize(tester, const Size(390, 844));
      await tester.pumpWidget(_buildTestApp(
        LibraryView(
          state: emptyLibrary,
          searchController: TextEditingController(),
          onSearchChanged: (_) {},
          onNewDocument: () {},
          onOpenDocument: (_) {},
          onRenameDocument: (_) {},
          onDeleteDocument: (_) {},
        ),
        size: const Size(390, 844),
      ));
      expect(find.byKey(const ValueKey('feature:user-exercises')), findsNothing);
      expect(find.byKey(const ValueKey('feature:new-document')), findsOneWidget);
    });

    testWidgets('the heading carries only the title and creation lives in the body', (tester) async {
      _setViewSize(tester, const Size(390, 844));
      await tester.pumpWidget(_buildTestApp(viewWith(section: LibrarySection.algorithms), size: const Size(390, 844)));
      final titleBottom = tester.getBottomLeft(find.text('Mis algoritmos')).dy;
      final tabsTop = tester.getTopLeft(find.byKey(const ValueKey('feature:user-exercises'))).dy;
      final createTop = tester.getTopLeft(find.byKey(const ValueKey('feature:new-document'))).dy;
      expect(tabsTop, greaterThan(titleBottom));
      expect(createTop, greaterThan(tabsTop));
    });

    testWidgets('tabs show both counts and the algorithms toolbar searches', (tester) async {
      _setViewSize(tester, const Size(390, 844));
      final doc = DocumentSummary(
        id: '1',
        title: 'Algoritmo Fibonacci',
        profileId: SyntaxProfileId.classicSpanish,
        revision: 1,
        createdAt: DateTime(2026, 8, 15),
        updatedAt: DateTime(2026, 8, 15),
      );
      final state = LibraryState(
        status: LibraryStatus.success,
        allDocuments: [doc],
        filteredDocuments: [doc],
        searchQuery: '',
      );
      await tester.pumpWidget(_buildTestApp(
        viewWith(section: LibrarySection.algorithms, state: state),
        size: const Size(390, 844),
      ));
      expect(find.text('Algoritmos'), findsOneWidget);
      expect(find.text('Ejercicios'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Buscar algoritmos...'), findsOneWidget);
      expect(find.text('exercise-list'), findsNothing);
    });

    testWidgets('tapping the exercises tab asks to switch section', (tester) async {
      _setViewSize(tester, const Size(390, 844));
      LibrarySection? selected;
      await tester.pumpWidget(_buildTestApp(
        viewWith(section: LibrarySection.algorithms, onSectionSelected: (section) => selected = section),
        size: const Size(390, 844),
      ));
      await tester.tap(find.byKey(const ValueKey('feature:user-exercises')));
      expect(selected, LibrarySection.exercises);
    });

    testWidgets('the exercises section shows its intro, list and own create action', (tester) async {
      _setViewSize(tester, const Size(1200, 800));
      var created = false;
      await tester.pumpWidget(_buildTestApp(
        viewWith(section: LibrarySection.exercises, onCreateExercise: () => created = true),
        size: const Size(1200, 800),
      ));
      expect(find.text('exercise-list'), findsOneWidget);
      expect(find.text('Buscar algoritmos...'), findsNothing);
      expect(find.byKey(const ValueKey('feature:new-document')), findsNothing);
      await tester.tap(find.widgetWithText(AppButton, 'Nuevo ejercicio'));
      expect(created, isTrue);
    });
  });
}
