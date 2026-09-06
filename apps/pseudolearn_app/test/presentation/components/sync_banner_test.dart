import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/sync/sync_cubit.dart';
import 'package:pseudolearn_app/application/sync/sync_state.dart';
import 'package:pseudolearn_app/domain/model/sync/sync_drain_outcome.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/status_banner.dart';
import 'package:pseudolearn_app/presentation/components/sync_banner.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import '../../fakes/fake_auth_gateway.dart';
import '../../fakes/fake_connectivity_monitor.dart';
import '../../fakes/fake_sync_coordinator.dart';
import '../../fakes/fake_sync_queue.dart';
import '../../fakes/in_memory_document_repository.dart';

Widget _wrap(Widget child, SyncCubit cubit) {
  return BlocProvider<SyncCubit>.value(
    value: cubit,
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
      home: Scaffold(body: DesignCanvas(child: child)),
    ),
  );
}

void main() {
  group('SyncBanner', () {
    late FakeSyncCoordinator coordinator;
    late FakeConnectivityMonitor connectivity;
    late FakeAuthGateway authGateway;
    late InMemoryDocumentRepository repository;
    late FakeSyncQueue queue;
    late SyncCubit cubit;

    setUp(() {
      coordinator = FakeSyncCoordinator();
      connectivity = FakeConnectivityMonitor();
      authGateway = FakeAuthGateway();
      repository = InMemoryDocumentRepository();
      queue = FakeSyncQueue();
      cubit = SyncCubit(
        coordinator: coordinator,
        connectivityMonitor: connectivity,
        authGateway: authGateway,
        repository: repository,
        syncQueue: queue,
      );
    });

    tearDown(() async {
      await cubit.close();
      connectivity.dispose();
    });

    testWidgets('renders nothing when idle with no conflicts', (tester) async {
      await tester.pumpWidget(_wrap(const SyncBanner(), cubit));
      expect(find.byType(StatusBanner), findsNothing);
    });

    testWidgets('renders warning banner when conflicts are detected', (tester) async {
      await tester.pumpWidget(_wrap(const SyncBanner(), cubit));
      cubit.emit(const SyncConflictDetected(conflictCount: 2));
      await tester.pump();

      expect(find.byType(StatusBanner), findsOneWidget);
      expect(find.text('Conflictos detectados'), findsOneWidget);
    });

    testWidgets('renders error banner with retry button on error', (tester) async {
      await tester.pumpWidget(_wrap(const SyncBanner(), cubit));
      cubit.emit(const SyncError(message: 'Connection failed'));
      await tester.pump();

      expect(find.byType(StatusBanner), findsOneWidget);
      expect(find.text('Error de sincronización'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);

      coordinator.outcome = SyncDrainOutcome.success;
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      expect(coordinator.drainCallCount, equals(1));
    });
  });
}
