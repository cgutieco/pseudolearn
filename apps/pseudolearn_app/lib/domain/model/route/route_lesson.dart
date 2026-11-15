import '../reference/reference_run.dart';
import 'lesson_block.dart';
import 'route_kinds.dart';

final class RouteLesson {
  final String id;
  final String number;
  final String partId;
  final RouteLessonKind kind;
  final List<ReferenceRun> title;
  final int minutes;
  final List<LessonReference> needs;
  final List<String> introducedLabels;
  final LessonReference? previous;
  final LessonReference? next;
  final List<LessonBlock> blocks;

  const RouteLesson({
    required this.id,
    required this.number,
    required this.partId,
    required this.kind,
    required this.title,
    required this.minutes,
    required this.needs,
    required this.introducedLabels,
    required this.previous,
    required this.next,
    required this.blocks,
  });
}
