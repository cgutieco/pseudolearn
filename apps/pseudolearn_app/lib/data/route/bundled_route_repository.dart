import 'dart:convert';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_exercise.dart';
import '../../domain/model/route/route_lesson.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/ports/route_repository.dart';
import '../reference/bundled_reference_repository.dart';
import '../reference/reference_json.dart';
import 'route_exercise_parser.dart';
import 'route_lesson_parser.dart';
import 'route_toc_parser.dart';

const String routeAssetRoot = 'assets/route/';

final class BundledRouteRepository implements RouteRepository {
  final ReferenceAssetLoader _assetLoader;

  const BundledRouteRepository({required this._assetLoader});

  @override
  Future<ContentLoadResult<RouteToc>> loadToc(ReferenceEdition edition) =>
      _load(edition, 'toc.json', parseRouteToc);

  @override
  Future<ContentLoadResult<RouteLesson>> loadLesson(
    ReferenceEdition edition,
    String lessonId,
  ) => _load(edition, 'lessons/$lessonId.json', parseRouteLesson);

  @override
  Future<ContentLoadResult<RouteExercise>> loadExercise(
    ReferenceEdition edition,
    String exerciseId,
  ) => _load(edition, 'exercises/$exerciseId.json', parseRouteExercise);

  @override
  Future<ContentLoadResult<Map<String, List<String>>>> loadSpecLinks(
    ReferenceEdition edition,
  ) => _load(edition, 'spec-links.json', _parseSpecLinks);

  Future<ContentLoadResult<T>> _load<T>(
    ReferenceEdition edition,
    String file,
    T Function(Object? json) parse,
  ) async {
    final path = '$routeAssetRoot${edition.directory}/$file';
    final String text;
    try {
      text = await _assetLoader(path);
    } catch (_) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.assetMissing,
        detail: path,
      );
    }
    try {
      return ContentLoaded(parse(jsonDecode(text)));
    } on FormatException catch (error) {
      return ContentLoadFailed(
        failure: ContentLoadFailure.malformedRoute,
        detail: '$path: ${error.message}',
      );
    }
  }
}

Map<String, List<String>> _parseSpecLinks(Object? json) {
  final source = objectOf(json);
  return {
    for (final entry in source.entries)
      entry.key: mappedList(entry.value, (lesson) => '$lesson'),
  };
}
