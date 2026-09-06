enum ExecutionBranchKind { affirmative, negative, selectedCase, defaultCase }

final class ExecutionBranch {
  final ExecutionBranchKind kind;
  final int? caseIndex;

  const ExecutionBranch({required this.kind, this.caseIndex});

  bool get isAffirmative => kind == ExecutionBranchKind.affirmative;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExecutionBranch &&
          kind == other.kind &&
          caseIndex == other.caseIndex;

  @override
  int get hashCode => Object.hash(kind, caseIndex);
}
