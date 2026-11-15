import 'package:pseudolearn_benchmarks/pseudolearn_benchmarks.dart';
import 'package:test/test.dart';

AgentTrial _trial(
  AgentVariant variant, {
  bool first = false,
  bool loop = false,
  int credits = 2,
}) => AgentTrial(
  taskId: 't',
  variant: variant,
  compiledFirst: first,
  compiledAfterLoop: loop,
  passedCases: loop,
  credits: credits,
);

void main() {
  test('summaries are per variant with rates and mean credits', () {
    const sheet = AgentVariant(sheet: true, retrieval: false);
    const bare = AgentVariant(sheet: false, retrieval: false);
    final summaries = summarizeAgentTrials([
      _trial(sheet, first: true, loop: true, credits: 4),
      _trial(sheet, loop: true),
      _trial(bare),
    ]);
    expect(summaries.map((summary) => summary.variant), [
      'sheet+no-retrieval',
      'no-sheet+no-retrieval',
    ]);
    expect(summaries.first.firstCompileRate, 0.5);
    expect(summaries.first.loopCompileRate, 1);
    expect(summaries.first.meanCredits, 3);
    expect(summaries.last.caseRate, 0);
  });

  test(
    'no trials produce no summaries and every variant has a distinct label',
    () {
      expect(summarizeAgentTrials(const []), isEmpty);
      expect(
        AgentVariant.all.map((variant) => variant.label).toSet(),
        hasLength(4),
      );
    },
  );
}
