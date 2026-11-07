import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/route_repository.dart';
import 'route_index_state.dart';
import 'route_progress.dart';

final class RouteIndexCubit extends Cubit<RouteIndexState> {
  final RouteRepository _repository;
  final LocalProgressStore _progressStore;

  RouteIndexCubit({
    required RouteRepository repository,
    required LocalProgressStore progressStore,
  }) : _repository = repository,
       _progressStore = progressStore,
       super(const RouteIndexState());

  Future<void> load(ReferenceEdition edition) async {
    emit(RouteIndexState(status: RouteIndexStatus.loading, edition: edition));
    final toc = await _repository.loadToc(edition);
    final progress = RouteProgress(await _progressStore.readProgress());
    if (isClosed) return;
    if (toc is! ContentLoaded<RouteToc>) {
      emit(RouteIndexState(status: RouteIndexStatus.error, edition: edition));
      return;
    }
    emit(
      RouteIndexState(
        status: RouteIndexStatus.success,
        edition: edition,
        toc: toc.value,
        lessonProgress: {
          for (final lesson in toc.value.lessons)
            lesson.id: progress.lessonProgress(lesson),
        },
        nextLessonId: progress.nextLesson(toc.value)?.id,
      ),
    );
  }

  Future<void> refresh() async {
    final edition = state.edition;
    if (edition != null) await load(edition);
  }
}
