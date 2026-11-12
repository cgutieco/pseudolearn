import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_kinds.dart';
import '../../domain/model/route/route_lesson.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/route_repository.dart';
import 'route_lesson_state.dart';
import 'route_progress.dart';

final class RouteLessonCubit extends Cubit<RouteLessonState> {
  final RouteRepository _repository;
  final LocalProgressStore _progressStore;

  RouteLessonCubit({
    required this._repository,
    required this._progressStore,
  }) : super(const RouteLessonState());

  Future<void> load(ReferenceEdition edition, String lessonId) async {
    emit(const RouteLessonState(status: RouteLessonStatus.loading));
    final lesson = await _repository.loadLesson(edition, lessonId);
    final toc = await _repository.loadToc(edition);
    if (isClosed) return;
    if (lesson is! ContentLoaded<RouteLesson>) {
      emit(const RouteLessonState(status: RouteLessonStatus.notFound));
      return;
    }
    await _progressStore.markModuleVisited(routeLessonProgressId(lessonId));
    final entries = toc is ContentLoaded<RouteToc>
        ? toc.value.lesson(lessonId)?.exercises ?? const <RouteExerciseEntry>[]
        : const <RouteExerciseEntry>[];
    final progress = RouteProgress(await _progressStore.readProgress());
    if (isClosed) return;
    emit(
      RouteLessonState(
        status: RouteLessonStatus.success,
        lesson: lesson.value,
        exercises: entries,
        completedExerciseIds: {
          for (final entry in entries)
            if (progress.isExerciseDone(entry.id)) entry.id,
        },
      ),
    );
  }
}
