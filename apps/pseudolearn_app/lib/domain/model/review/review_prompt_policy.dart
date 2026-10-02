final class ReviewPromptPolicy {
  static const ReviewPromptPolicy standard = ReviewPromptPolicy({1, 10, 30});

  final Set<int> solvedExerciseMilestones;

  const ReviewPromptPolicy(this.solvedExerciseMilestones);

  bool isMilestone(int solvedExercises) =>
      solvedExerciseMilestones.contains(solvedExercises);
}
