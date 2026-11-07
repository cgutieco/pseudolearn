import 'package:flutter/foundation.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';

final class LessonScope {
  final ReferenceEdition edition;
  final ValueChanged<String> onOpenLink;
  final ValueChanged<String> onOpenExercise;
  final List<RouteExerciseEntry> exercises;
  final Set<String> completedExerciseIds;

  const LessonScope({
    required this.edition,
    required this.onOpenLink,
    required this.onOpenExercise,
    this.exercises = const [],
    this.completedExerciseIds = const {},
  });

  RouteExerciseEntry? exercise(String id) {
    for (final entry in exercises) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}
