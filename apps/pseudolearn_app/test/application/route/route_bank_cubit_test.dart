import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_bank_cubit.dart';
import 'package:pseudolearn_app/application/route/route_bank_state.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../../fakes/fake_route_repository.dart';
import '../../fakes/in_memory_local_progress_store.dart';
import '../../fakes/route_fixtures.dart';

const ReferenceEdition _edition = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

void main() {
  test('projects every exercise of the route with its progress', () async {
    final store = InMemoryLocalProgressStore();
    await store.markExerciseCompleted(routeExerciseProgressId('inicio.primero.b'));
    final cubit = RouteBankCubit(repository: FakeRouteRepository(toc: sampleToc), progressStore: store);

    await cubit.load(_edition);

    expect(cubit.state.status, RouteBankStatus.success);
    expect(cubit.state.visible.length, 4);
    expect(cubit.state.completedIds, {'inicio.primero.b'});
    expect(cubit.state.filter.isEmpty, isTrue);
  });

  test('filters by part, kind and level together', () async {
    final cubit = RouteBankCubit(repository: FakeRouteRepository(toc: sampleToc), progressStore: InMemoryLocalProgressStore());
    await cubit.load(_edition);

    cubit.filter(const RouteBankFilter(partId: 'parte-inicio'));
    expect(cubit.state.visible.length, 3);

    cubit.filter(const RouteBankFilter(partId: 'parte-inicio', kind: RouteExerciseKind.predict));
    expect(cubit.state.visible.single.id, 'inicio.primero.b');

    cubit.filter(const RouteBankFilter(level: RouteLevel.tree));
    expect(cubit.state.visible.single.id, 'imperativo.segundo.a');

    cubit.filter(const RouteBankFilter(kind: RouteExerciseKind.trace));
    expect(cubit.state.visible, isEmpty);
  });

  test('a missing bundle is an error state', () async {
    final cubit = RouteBankCubit(repository: FakeRouteRepository(failToc: true), progressStore: InMemoryLocalProgressStore());
    await cubit.load(_edition);
    expect(cubit.state.status, RouteBankStatus.error);
  });

  test('a progress change marks the solved exercise and keeps the filter', () async {
    final store = InMemoryLocalProgressStore();
    final changes = StreamController<void>.broadcast();
    final cubit = RouteBankCubit(
      repository: FakeRouteRepository(toc: sampleToc),
      progressStore: store,
      progressChanges: changes.stream,
    );
    await cubit.load(_edition);
    cubit.filter(const RouteBankFilter(partId: 'parte-inicio'));

    await store.markExerciseCompleted(routeExerciseProgressId('inicio.primero.a'));
    changes.add(null);
    await cubit.stream.first;

    expect(cubit.state.status, RouteBankStatus.success);
    expect(cubit.state.completedIds, {'inicio.primero.a'});
    expect(cubit.state.filter.partId, 'parte-inicio');
    expect(cubit.state.visible.length, 3);
    await cubit.close();
    await changes.close();
  });

  test('a progress change before any load does not read the route', () async {
    final repository = FakeRouteRepository(toc: sampleToc);
    final changes = StreamController<void>.broadcast();
    final cubit = RouteBankCubit(
      repository: repository,
      progressStore: InMemoryLocalProgressStore(),
      progressChanges: changes.stream,
    );

    changes.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(repository.requestedEditions, isEmpty);
    expect(cubit.state.status, RouteBankStatus.initial);
    await cubit.close();
    expect(changes.hasListener, isFalse);
    await changes.close();
  });
}
