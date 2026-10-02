import '../../domain/model/knowledge/content_progress.dart';
import '../../domain/model/review/review_prompt_policy.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/store_review_prompt.dart';

final class ReviewPromptingProgressStore implements LocalProgressStore {
  final LocalProgressStore _inner;
  final StoreReviewPrompt _prompt;
  final ReviewPromptPolicy _policy;

  const ReviewPromptingProgressStore({
    required LocalProgressStore inner,
    required StoreReviewPrompt prompt,
    ReviewPromptPolicy policy = ReviewPromptPolicy.standard,
  })  : _inner = inner,
        _prompt = prompt,
        _policy = policy;

  @override
  Future<bool> isModuleVisited(String moduleId) =>
      _inner.isModuleVisited(moduleId);

  @override
  Future<void> markModuleVisited(String moduleId) =>
      _inner.markModuleVisited(moduleId);

  @override
  Future<bool> isExerciseCompleted(String exerciseId) =>
      _inner.isExerciseCompleted(exerciseId);

  @override
  Future<void> markExerciseCompleted(String exerciseId) async {
    final wasCompleted = await _inner.isExerciseCompleted(exerciseId);
    await _inner.markExerciseCompleted(exerciseId);
    if (wasCompleted) return;
    final progress = await _inner.readProgress();
    if (!_policy.isMilestone(progress.completedExerciseIds.length)) return;
    await _prompt.request();
  }

  @override
  Future<ContentProgress> readProgress() => _inner.readProgress();
}
