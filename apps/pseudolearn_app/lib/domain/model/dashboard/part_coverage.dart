import 'coverage_count.dart';
import 'lesson_mark.dart';

final class PartCoverage {
  final String partId;
  final String number;
  final String title;
  final CoverageCount lessons;
  final List<LessonMark> marks;

  const PartCoverage({
    required this.partId,
    required this.number,
    required this.title,
    required this.lessons,
    this.marks = const [],
  });

  int get touchedLessons => marks.where((mark) => mark.isTouched).length;
}
