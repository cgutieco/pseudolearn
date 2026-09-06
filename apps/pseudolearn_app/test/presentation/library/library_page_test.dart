import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/library/library_state.dart';
import 'package:pseudolearn_app/domain/model/documents/document.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/library/library_page.dart';
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
}
