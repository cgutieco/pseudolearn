import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_bank_state.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import 'package:pseudolearn_app/presentation/route/route_bank_view.dart';
import '../../fakes/route_fixtures.dart';
import 'route_widget_support.dart';

void main() {
  testWidgets('shows the exercises and sends filters and openings', (tester) async {
    final filters = <RouteBankFilter>[];
    final opened = <RouteExerciseEntry>[];
    await tester.pumpWidget(routeTestApp(RouteBankView(
        state: RouteBankState(
          status: RouteBankStatus.success,
          parts: sampleToc.parts,
          visible: sampleToc.exercises,
          completedIds: const {'inicio.primero.a'},
        ),
        onFilter: filters.add,
        onOpenExercise: opened.add,
      )));
    await tester.pumpAndSettle();

    expect(find.text('inicio.primero.a'), findsOneWidget);
    await tester.tap(find.text('Árbol').first);
    expect(filters.single.level, RouteLevel.tree);
    await tester.tap(find.text('inicio.primero.b'));
    expect(opened.single.id, 'inicio.primero.b');
  });

  testWidgets('an empty filter result explains itself', (tester) async {
    await tester.pumpWidget(routeTestApp(RouteBankView(
        state: const RouteBankState(status: RouteBankStatus.success),
        onFilter: (_) {},
        onOpenExercise: (_) {},
      )));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.filter_alt_off_outlined), findsOneWidget);
  });
}
