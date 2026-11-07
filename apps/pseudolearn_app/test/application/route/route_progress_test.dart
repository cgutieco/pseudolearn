import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/route/route_progress.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_progress.dart';
import 'package:pseudolearn_app/domain/model/route/route_kinds.dart';
import '../../fakes/route_fixtures.dart';

void main() {
  final first = sampleToc.lessons.first;

  test('a lesson without progress has not started', () {
    final progress = RouteProgress(const ContentProgress());
    expect(progress.lessonProgress(first), LessonProgress.notStarted);
    expect(progress.nextLesson(sampleToc)?.id, 'inicio.primero');
  });

  test('visiting a lesson marks it as visited', () {
    final progress = RouteProgress(
      ContentProgress(visitedModuleIds: {routeLessonProgressId(first.id)}),
    );
    expect(progress.lessonProgress(first), LessonProgress.visited);
  });

  test('solving every required exercise completes the lesson and unlocks the next', () {
    final progress = RouteProgress(
      ContentProgress(completedExerciseIds: {
        routeExerciseProgressId('inicio.primero.a'),
        routeExerciseProgressId('inicio.primero.b'),
      }),
    );
    expect(progress.lessonProgress(first), LessonProgress.completed);
    expect(progress.nextLesson(sampleToc)?.id, 'imperativo.segundo');
  });

  test('the retired route ids never count', () {
    final progress = RouteProgress(
      const ContentProgress(completedExerciseIds: {'inicio.primero.a', 'CON-A1-E1'}),
    );
    expect(progress.isExerciseDone('inicio.primero.a'), isFalse);
  });

  test('a lesson with no required exercise completes on its visit', () {
    final lesson = lessonEntry('solo', exercises: [exerciseEntry('solo.a', required: false)]);
    final progress = RouteProgress(
      ContentProgress(visitedModuleIds: {routeLessonProgressId('solo')}),
    );
    expect(progress.isLessonCompleted(lesson), isTrue);
  });
}
