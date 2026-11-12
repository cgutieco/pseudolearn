import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pseudolearn_app/application/route/route_index_cubit.dart';
import 'package:pseudolearn_app/application/route/route_index_state.dart';

import 'scene_actions.dart';
import 'scene_stage.dart';

const Duration _readSlice = Duration(milliseconds: 50);
const Duration _frameSlice = Duration(milliseconds: 100);
const int _readAttempts = 80;
const int _trailingFrames = 12;

final class BundledLesson {
  final String id;
  final String title;

  const BundledLesson({required this.id, required this.title});
}

BundledLesson firstBundledLesson(String localeTag) {
  final toc =
      jsonDecode(
            File(
              'assets/route/$localeTag/$localeTag/toc.json',
            ).readAsStringSync(),
          )
          as List<dynamic>;
  final lesson =
      (toc.first as Map<String, dynamic>)['lessons'].first
          as Map<String, dynamic>;
  final runs = lesson['title'] as List<dynamic>;
  final title = runs
      .map((run) => (run as Map<String, dynamic>)['text'] as String)
      .join();
  return BundledLesson(id: lesson['id'] as String, title: title);
}

SceneAction openBundledLesson(BundledLesson lesson) {
  return (stage) async {
    GoRouter.of(stage.appContext).go('$knowledgeRoute/ruta/${lesson.id}');
    await settleUntil(
      stage,
      () => lessonTitleFinder(lesson).evaluate().isNotEmpty,
    );
  };
}

SceneAction openRouteIndex() {
  return (stage) async {
    final route = BlocProvider.of<RouteIndexCubit>(stage.appContext);
    GoRouter.of(stage.appContext).go(knowledgeRoute);
    await settleUntil(
      stage,
      () => route.state.status == RouteIndexStatus.success,
    );
  };
}

Finder lessonTitleFinder(BundledLesson lesson) =>
    find.text(lesson.title, findRichText: true);

Future<void> settleUntil(SceneStage stage, bool Function() ready) async {
  for (var attempt = 0; attempt < _readAttempts; attempt++) {
    await stage.tester.pump();
    await stage.tester.runAsync(() => Future<void>.delayed(_readSlice));
    if (ready()) break;
  }
  for (var frame = 0; frame < _trailingFrames; frame++) {
    await stage.tester.pump(_frameSlice);
  }
}
