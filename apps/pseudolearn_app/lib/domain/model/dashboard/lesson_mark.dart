enum LessonStage { pending, inProgress, completed }

final class LessonMark {
  final String lessonId;
  final String number;
  final LessonStage stage;
  final bool isNext;

  const LessonMark({
    required this.lessonId,
    required this.number,
    required this.stage,
    this.isNext = false,
  });

  bool get isTouched => stage != LessonStage.pending;
}
