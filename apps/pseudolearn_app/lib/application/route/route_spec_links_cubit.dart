import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/ports/route_repository.dart';
import 'route_spec_links_state.dart';

final class RouteSpecLinksCubit extends Cubit<RouteSpecLinksState> {
  final RouteRepository _repository;

  RouteSpecLinksCubit({required this._repository})
    : super(const RouteSpecLinksState());

  Future<void> load(ReferenceEdition edition) async {
    if (state.edition == edition) return;
    final links = await _repository.loadSpecLinks(edition);
    final toc = await _repository.loadToc(edition);
    if (isClosed) return;
    if (links is! ContentLoaded<Map<String, List<String>>> ||
        toc is! ContentLoaded<RouteToc>) {
      emit(RouteSpecLinksState(edition: edition));
      return;
    }
    emit(
      RouteSpecLinksState(
        edition: edition,
        lessonsBySection: lessonsBySection(links.value, toc.value),
      ),
    );
  }
}

Map<String, List<RouteLessonEntry>> lessonsBySection(
  Map<String, List<String>> links,
  RouteToc toc,
) {
  final lessons = {for (final lesson in toc.lessons) lesson.id: lesson};
  return {
    for (final entry in links.entries)
      entry.key: [
        for (final lessonId in entry.value) ?lessons[lessonId],
      ],
  };
}
