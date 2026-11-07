import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_lesson.dart';
import 'package:pseudolearn_app/domain/model/route/route_toc.dart';
import 'package:pseudolearn_app/domain/ports/route_repository.dart';

class FakeRouteRepository implements RouteRepository {
  final RouteToc toc;
  final Map<String, RouteLesson> lessons;
  final Map<String, RouteExercise> exercises;
  final Map<String, List<String>> specLinks;
  final bool failToc;
  final List<ReferenceEdition> requestedEditions = [];

  FakeRouteRepository({
    this.toc = const RouteToc.empty(),
    this.lessons = const {},
    this.exercises = const {},
    this.specLinks = const {},
    this.failToc = false,
  });

  @override
  Future<ContentLoadResult<RouteToc>> loadToc(ReferenceEdition edition) async {
    requestedEditions.add(edition);
    if (failToc) {
      return const ContentLoadFailed(
        failure: ContentLoadFailure.malformedRoute,
        detail: 'toc',
      );
    }
    return ContentLoaded(toc);
  }

  @override
  Future<ContentLoadResult<RouteLesson>> loadLesson(
    ReferenceEdition edition,
    String lessonId,
  ) async => _found(lessons[lessonId], lessonId);

  @override
  Future<ContentLoadResult<RouteExercise>> loadExercise(
    ReferenceEdition edition,
    String exerciseId,
  ) async => _found(exercises[exerciseId], exerciseId);

  @override
  Future<ContentLoadResult<Map<String, List<String>>>> loadSpecLinks(
    ReferenceEdition edition,
  ) async => ContentLoaded(specLinks);

  ContentLoadResult<T> _found<T>(T? value, String id) {
    if (value == null) {
      return ContentLoadFailed(failure: ContentLoadFailure.assetMissing, detail: id);
    }
    return ContentLoaded(value);
  }
}
