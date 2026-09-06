import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/dashboard/dashboard_state.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/activity_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/concepts_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/creations_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/exercises_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/learning_route_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/library_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/next_step_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/specification_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/components/sync_card.dart';
import 'package:pseudolearn_app/presentation/dashboard/dashboard_view.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'dashboard_view_fixture.dart';

Widget _appWith({
  required DashboardState state,
  DateTime? lastSyncAt,
  ValueChanged<String>? onOpenModule,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: DashboardView(
      state: state,
      lastSyncAt: lastSyncAt,
      onOpenModule: onOpenModule ?? (_) {},
    ),
  );
}

Future<void> _pump(WidgetTester tester, Widget app, {Size size = const Size(1280, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  group('DashboardView (PANT-06-F5)', () {
    testWidgets('shows the nine cards with local data and no session', (tester) async {
      await _pump(tester, _appWith(state: populatedDashboardState()));

      expect(find.byType(LibraryCard), findsOneWidget);
      expect(find.byType(LearningRouteCard), findsOneWidget);
      expect(find.byType(NextStepCard), findsOneWidget);
      expect(find.byType(ExercisesCard), findsOneWidget);
      expect(find.byType(ConceptsCard), findsOneWidget);
      expect(find.byType(SpecificationCard), findsOneWidget);
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.byType(CreationsCard), findsOneWidget);
      expect(find.byType(SyncCard), findsOneWidget);
    });

    testWidgets('reports the number of algorithms held on the device', (tester) async {
      await _pump(tester, _appWith(state: populatedDashboardState()));

      expect(find.text('4'), findsWidgets);
    });

    testWidgets('without a synchronisation it says so instead of a date', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      await _pump(tester, _appWith(state: populatedDashboardState()));

      expect(find.text(l10n.dashboardSyncNever), findsOneWidget);
    });

    testWidgets('with a synchronisation it prints its day', (tester) async {
      await _pump(
        tester,
        _appWith(
          state: populatedDashboardState(),
          lastSyncAt: DateTime(2026, 9, 1, 8, 30),
        ),
      );

      expect(find.text('2026-09-01'), findsOneWidget);
    });

    testWidgets('opening the suggested module reports its identifier', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      String? opened;
      await _pump(
        tester,
        _appWith(
          state: populatedDashboardState(),
          onOpenModule: (moduleId) => opened = moduleId,
        ),
      );

      await tester.tap(find.text(l10n.dashboardNextStepOpen));
      await tester.pumpAndSettle();

      expect(opened, 'CON-B3');
    });

    testWidgets('a device with nothing recorded shows the empty state', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      await _pump(tester, _appWith(state: emptyDashboardState()));

      expect(find.text(l10n.dashboardEmptyTitle), findsOneWidget);
      expect(find.byType(LibraryCard), findsNothing);
    });

    testWidgets('a failed reading shows the error and its detail', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('es'));
      await _pump(
        tester,
        _appWith(
          state: const DashboardState(
            status: DashboardStatus.error,
            errorMessage: 'manifest_es.json',
          ),
        ),
      );

      expect(find.text(l10n.dashboardErrorTitle), findsOneWidget);
      expect(find.text('manifest_es.json'), findsOneWidget);
    });

    testWidgets('the initial state does not paint cards yet', (tester) async {
      tester.view.physicalSize = const Size(1280, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_appWith(state: const DashboardState()));
      await tester.pump();

      expect(find.byType(LibraryCard), findsNothing);
    });

    testWidgets('lays out without overflowing at the narrowest width', (tester) async {
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;

      await _pump(
        tester,
        _appWith(state: populatedDashboardState()),
        size: const Size(360, 900),
      );
      FlutterError.onError = previous;

      expect(errors, isEmpty);
    });
  });
}
