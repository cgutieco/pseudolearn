import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_toc.dart';
import '../reference/reference_json.dart';
import '../reference/reference_run_parser.dart';

RouteToc parseRouteToc(Object? json) =>
    RouteToc(mappedList(json, (part) => _part(objectOf(part))));

RoutePartEntry _part(Map<String, Object?> source) => RoutePartEntry(
  id: textOf(source, 'id'),
  number: textOf(source, 'number'),
  title: textOf(source, 'title'),
  motto: optionalTextOf(source, 'motto'),
  summary: optionalTextOf(source, 'summary'),
  lessons: mappedList(source['lessons'], (lesson) => _lesson(objectOf(lesson))),
);

RouteLessonEntry _lesson(Map<String, Object?> source) {
  final id = textOf(source, 'id');
  return RouteLessonEntry(
    id: id,
    number: textOf(source, 'number'),
    kind: lessonKindOf(textOf(source, 'kind')),
    title: parseRuns(source['title']),
    briefProblem: optionalTextOf(source, 'brief_problem'),
    minutes: numberOf(source, 'minutes'),
    levels: mappedList(source['levels'], (level) => levelOf('$level')),
    needs: mappedList(source['needs'], (need) => '$need'),
    exercises: mappedList(
      source['exercises'],
      (exercise) => _exercise(id, objectOf(exercise)),
    ),
  );
}

RouteExerciseEntry _exercise(String lessonId, Map<String, Object?> source) =>
    RouteExerciseEntry(
      id: textOf(source, 'id'),
      lessonId: lessonId,
      kind: exerciseKindOf(textOf(source, 'kind')),
      level: levelOf(textOf(source, 'level')),
      required: flagOf(source, 'required'),
      title: parseRuns(source['title']),
    );

RouteLessonKind lessonKindOf(String slug) =>
    RouteLessonKind.fromSlug(slug) ??
    (throw FormatException('unknown lesson kind $slug'));

RouteLevel levelOf(String slug) =>
    RouteLevel.fromSlug(slug) ?? (throw FormatException('unknown level $slug'));

RouteExerciseKind exerciseKindOf(String slug) =>
    RouteExerciseKind.fromSlug(slug) ??
    (throw FormatException('unknown exercise kind $slug'));
