import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';

final class RouteSpecLinksState {
  final ReferenceEdition? edition;
  final Map<String, List<RouteLessonEntry>> lessonsBySection;

  const RouteSpecLinksState({this.edition, this.lessonsBySection = const {}});

  List<RouteLessonEntry> lessonsOf(String sectionId) =>
      lessonsBySection[sectionId] ?? const [];
}
