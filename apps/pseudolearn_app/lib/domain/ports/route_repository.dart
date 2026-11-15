import '../model/knowledge/content_load_result.dart';
import '../model/reference/reference_edition.dart';
import '../model/route/route_exercise.dart';
import '../model/route/route_lesson.dart';
import '../model/route/route_toc.dart';

abstract interface class RouteRepository {
  Future<ContentLoadResult<RouteToc>> loadToc(ReferenceEdition edition);

  Future<ContentLoadResult<RouteLesson>> loadLesson(
    ReferenceEdition edition,
    String lessonId,
  );

  Future<ContentLoadResult<RouteExercise>> loadExercise(
    ReferenceEdition edition,
    String exerciseId,
  );

  Future<ContentLoadResult<Map<String, List<String>>>> loadSpecLinks(
    ReferenceEdition edition,
  );
}
