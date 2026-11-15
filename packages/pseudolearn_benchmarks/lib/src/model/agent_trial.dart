final class AgentVariant {
  final bool sheet;
  final bool retrieval;

  const AgentVariant({required this.sheet, required this.retrieval});

  static const List<AgentVariant> all = [
    AgentVariant(sheet: true, retrieval: true),
    AgentVariant(sheet: true, retrieval: false),
    AgentVariant(sheet: false, retrieval: true),
    AgentVariant(sheet: false, retrieval: false),
  ];

  String get label =>
      '${sheet ? 'sheet' : 'no-sheet'}+${retrieval ? 'retrieval' : 'no-retrieval'}';
}

final class AgentTrial {
  final String taskId;
  final AgentVariant variant;
  final bool compiledFirst;
  final bool compiledAfterLoop;
  final bool passedCases;
  final int credits;

  const AgentTrial({
    required this.taskId,
    required this.variant,
    required this.compiledFirst,
    required this.compiledAfterLoop,
    required this.passedCases,
    required this.credits,
  });

  Map<String, Object?> toJson() => {
    'task': taskId,
    'variant': variant.label,
    'compiled_first': compiledFirst,
    'compiled_after_loop': compiledAfterLoop,
    'passed_cases': passedCases,
    'credits': credits,
  };
}

final class AgentVariantSummary {
  final String variant;
  final int trials;
  final double firstCompileRate;
  final double loopCompileRate;
  final double caseRate;
  final double meanCredits;

  const AgentVariantSummary({
    required this.variant,
    required this.trials,
    required this.firstCompileRate,
    required this.loopCompileRate,
    required this.caseRate,
    required this.meanCredits,
  });

  Map<String, Object?> toJson() => {
    'variant': variant,
    'trials': trials,
    'first_compile_rate': firstCompileRate,
    'loop_compile_rate': loopCompileRate,
    'case_rate': caseRate,
    'mean_credits': meanCredits,
  };
}

List<AgentVariantSummary> summarizeAgentTrials(List<AgentTrial> trials) => [
  for (final variant in AgentVariant.all)
    if (trials.any((trial) => trial.variant.label == variant.label))
      _summary(
        variant.label,
        trials.where((trial) => trial.variant.label == variant.label).toList(),
      ),
];

AgentVariantSummary _summary(String variant, List<AgentTrial> trials) {
  double rate(bool Function(AgentTrial trial) passes) =>
      trials.where(passes).length / trials.length;
  final credits = trials.fold<int>(0, (total, trial) => total + trial.credits);
  return AgentVariantSummary(
    variant: variant,
    trials: trials.length,
    firstCompileRate: rate((trial) => trial.compiledFirst),
    loopCompileRate: rate((trial) => trial.compiledAfterLoop),
    caseRate: rate((trial) => trial.passedCases),
    meanCredits: credits / trials.length,
  );
}
