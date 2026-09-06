import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'test_dependencies.dart';

Future<void> pumpApp(WidgetTester tester, Size size,
    {Locale locale = const Locale('es')}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[locale];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);

  await tester.pumpWidget(CubitScope(dependencies: buildTestDependencies()));
  await tester.pumpAndSettle();
}

Future<void> visitDestination(WidgetTester tester, String path) async {
  final context = tester.element(find.byType(Navigator).first);
  GoRouter.of(context).go(path);
  await tester.pumpAndSettle();
}

Future<List<FlutterErrorDetails>> collectLayoutErrors(
  Future<void> Function() body,
) async {
  final collected = <FlutterErrorDetails>[];
  final previousOnError = FlutterError.onError;
  FlutterError.onError = collected.add;
  try {
    await body();
  } finally {
    FlutterError.onError = previousOnError;
  }
  return collected;
}
