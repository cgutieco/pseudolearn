import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/ports/local_progress_store.dart';
import 'progress_updates.dart';

final class PublishingProgressStore implements LocalProgressStore {
  final LocalProgressStore _inner;
  final ProgressUpdates _updates;

  const PublishingProgressStore({
    required this._inner,
    required this._updates,
  });

  @override
  Future<bool> isModuleVisited(String moduleId) =>
      _inner.isModuleVisited(moduleId);

  @override
  Future<void> markModuleVisited(String moduleId) async {
    await _inner.markModuleVisited(moduleId);
    _updates.publish();
  }

  @override
  Future<bool> isExerciseCompleted(String exerciseId) =>
      _inner.isExerciseCompleted(exerciseId);

  @override
  Future<void> markExerciseCompleted(String exerciseId) async {
    await _inner.markExerciseCompleted(exerciseId);
    _updates.publish();
  }

  @override
  Future<ContentProgress> readProgress() => _inner.readProgress();
}
