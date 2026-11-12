import 'dart:async';
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
  late final StreamSubscription<void> _progressChanges;

  RouteIndexCubit({
    required this._repository,
    required this._progressStore,
    Stream<void> progressChanges = const Stream.empty(),
  }) : super(const RouteIndexState()) {
    _progressChanges = progressChanges.listen((_) => refresh());
  }

  Future<void> load(ReferenceEdition edition) async {
    emit(RouteIndexState(status: RouteIndexStatus.loading, edition: edition));
    await _project(edition);
  }

  Future<void> refresh() async {
    final edition = state.edition;
    if (edition != null) await _project(edition);
  }

  Future<void> _project(ReferenceEdition edition) async {
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
        requiredExercises: {
          for (final lesson in toc.value.lessons)
            lesson.id: progress.requiredExercisesOf(lesson),
        },
        nextLessonId: progress.nextLesson(toc.value)?.id,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _progressChanges.cancel();
    return super.close();
  }
}
