import 'coverage_count.dart';

final class NextLesson {
  final String id;
  final String number;
  final String title;
  final String partTitle;
  final CoverageCount requiredExercises;

  const NextLesson({
    required this.id,
    required this.number,
    required this.title,
    required this.partTitle,
    this.requiredExercises = const CoverageCount.empty(),
  });
}
