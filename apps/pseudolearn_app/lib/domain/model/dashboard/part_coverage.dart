import 'coverage_count.dart';

final class PartCoverage {
  final String partId;
  final String number;
  final String title;
  final CoverageCount lessons;

  const PartCoverage({
    required this.partId,
    required this.number,
    required this.title,
    required this.lessons,
  });
}
