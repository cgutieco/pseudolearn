import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/route/route_lesson_reader.dart';
import 'route_widget_support.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('renders lesson 0.1 on a phone without layout errors (dark: $dark)', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final lesson = await tester.runAsync(() => bundledLesson('inicio.primer-problema'));
      await tester.pumpWidget(
        routeTestApp(RouteLessonReader(lesson: lesson!, scope: scopeRecording([])), dark: dark),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tu primer problema'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reveals the attempt answer on demand', (tester) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final lesson = await tester.runAsync(() => bundledLesson('inicio.primer-problema'));
    await tester.pumpWidget(routeTestApp(RouteLessonReader(lesson: lesson!, scope: scopeRecording([]))));
    await tester.pumpAndSettle();

    expect(find.textContaining('Hay que pedir'), findsNothing);
    await tester.tap(find.text('Ya lo intenté: ver la respuesta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hay que pedir'), findsOneWidget);
  });

  testWidgets('specification pills and the next lesson open their targets', (tester) async {
    tester.view.physicalSize = const Size(800, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final opened = <String>[];
    final lesson = await tester.runAsync(() => bundledLesson('inicio.primer-problema'));
    await tester.pumpWidget(routeTestApp(RouteLessonReader(lesson: lesson!, scope: scopeRecording(opened))));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Especificación §8.1'));
    await tester.pumpAndSettle();
    expect(opened, contains('programas.estructura'));
  });
}
