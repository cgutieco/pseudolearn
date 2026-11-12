enum ReplyMark { strong, emphasis, strikethrough, code }

final class ReplyRun {
  final String text;
  final Set<ReplyMark> marks;
  final String? target;

  const ReplyRun(this.text, {this.marks = const {}, this.target});

  bool has(ReplyMark mark) => marks.contains(mark);
}

String plainTextOfRuns(List<ReplyRun> runs) => runs.map((run) => run.text).join();
