import '../reference/reference_block.dart';
import '../reference/reference_callout_kind.dart';
import '../reference/reference_figure.dart';
import '../reference/reference_run.dart';

final class LessonReference {
  final String id;
  final String number;
  final String title;

  const LessonReference({
    required this.id,
    required this.number,
    required this.title,
  });
}

final class RouteRole {
  final String name;
  final List<ReferenceRun> description;
  final ReferenceFigure figure;

  const RouteRole({
    required this.name,
    required this.description,
    required this.figure,
  });
}

sealed class LessonBlock {
  const LessonBlock();
}

final class SharedLessonBlock extends LessonBlock {
  final ReferenceBlock block;

  const SharedLessonBlock(this.block);
}

final class PhraseLessonBlock extends LessonBlock {
  final List<ReferenceRun> runs;

  const PhraseLessonBlock(this.runs);
}

final class ProblemLessonBlock extends LessonBlock {
  final List<LessonBlock> blocks;

  const ProblemLessonBlock(this.blocks);
}

final class AttemptLessonBlock extends LessonBlock {
  final List<LessonBlock> prompt;
  final List<LessonBlock> answer;

  const AttemptLessonBlock({required this.prompt, required this.answer});
}

final class CycleLessonBlock extends LessonBlock {
  final List<int> phases;

  const CycleLessonBlock(this.phases);
}

final class PhaseHeadingLessonBlock extends LessonBlock {
  final String id;
  final List<int> phases;
  final List<ReferenceRun> runs;

  const PhaseHeadingLessonBlock({
    required this.id,
    required this.phases,
    required this.runs,
  });
}

final class BriefLessonBlock extends LessonBlock {
  final List<ReferenceRun> inputs;
  final List<ReferenceRun> outputs;
  final List<ReferenceRun> relation;
  final List<List<ReferenceRun>> examples;

  const BriefLessonBlock({
    required this.inputs,
    required this.outputs,
    required this.relation,
    required this.examples,
  });
}

final class RolesLessonBlock extends LessonBlock {
  final List<RouteRole> roles;

  const RolesLessonBlock(this.roles);
}

final class ParadigmLessonBlock extends LessonBlock {
  final List<ReferenceRun> question;
  final List<ReferenceRun> metaphor;
  final List<ReferenceRun> history;
  final List<ReferenceRun> cost;

  const ParadigmLessonBlock({
    required this.question,
    required this.metaphor,
    required this.history,
    required this.cost,
  });
}

final class RecallLessonBlock extends LessonBlock {
  final String term;
  final String label;
  final List<ReferenceRun> runs;
  final LessonReference lesson;

  const RecallLessonBlock({
    required this.term,
    required this.label,
    required this.runs,
    required this.lesson,
  });
}

final class SpecLinksLessonBlock extends LessonBlock {
  final List<ReferenceSectionLink> links;

  const SpecLinksLessonBlock(this.links);
}

final class DeepenLessonBlock extends LessonBlock {
  final String title;
  final List<LessonBlock> blocks;

  const DeepenLessonBlock({required this.title, required this.blocks});
}

final class PracticeLessonBlock extends LessonBlock {
  final List<String> exerciseIds;

  const PracticeLessonBlock(this.exerciseIds);
}

final class NextLessonBlock extends LessonBlock {
  final LessonReference? lesson;
  final List<ReferenceRun> runs;

  const NextLessonBlock({required this.lesson, required this.runs});
}

final class SpecFigureLessonBlock extends LessonBlock {
  final String sectionId;
  final String number;
  final ReferenceFigure figure;

  const SpecFigureLessonBlock({
    required this.sectionId,
    required this.number,
    required this.figure,
  });
}

final class CalloutLessonBlock extends LessonBlock {
  final ReferenceCalloutKind kind;
  final bool collapsible;
  final List<LessonBlock> blocks;

  const CalloutLessonBlock({
    required this.kind,
    required this.collapsible,
    required this.blocks,
  });
}
