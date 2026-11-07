import '../../domain/model/route/lesson_block.dart';
import '../../domain/model/route/route_lesson.dart';
import '../reference/reference_block_parser.dart';
import '../reference/reference_figure_parser.dart';
import '../reference/reference_json.dart';
import '../reference/reference_run_parser.dart';
import 'route_toc_parser.dart';

const Set<String> _routeTypes = {
  'phrase',
  'problem',
  'attempt',
  'cycle',
  'phase_heading',
  'brief',
  'roles',
  'paradigm',
  'recall',
  'spec_links',
  'deepen',
  'practice',
  'next',
  'spec_figure',
  'callout',
};

RouteLesson parseRouteLesson(Object? json) {
  final source = objectOf(json);
  return RouteLesson(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    partId: textOf(source, 'part'),
    kind: lessonKindOf(textOf(source, 'kind')),
    title: parseRuns(source['title']),
    minutes: numberOf(source, 'minutes'),
    needs: mappedList(source['needs'], parseLessonReference),
    introducedLabels: mappedList(
      source['introduces'],
      (term) => textOf(objectOf(term), 'label'),
    ),
    previous: _optionalReference(source['previous']),
    next: _optionalReference(source['next']),
    blocks: parseLessonBlocks(source['blocks']),
  );
}

LessonReference parseLessonReference(Object? value) {
  final source = objectOf(value);
  return LessonReference(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    title: textOf(source, 'title'),
  );
}

LessonReference? _optionalReference(Object? value) =>
    value == null ? null : parseLessonReference(value);

List<LessonBlock> parseLessonBlocks(Object? value) =>
    mappedList(value, (block) => parseLessonBlock(objectOf(block)));

LessonBlock parseLessonBlock(Map<String, Object?> source) {
  final type = textOf(source, 'type');
  if (!_routeTypes.contains(type)) return SharedLessonBlock(parseBlock(source));
  return switch (type) {
    'phrase' => PhraseLessonBlock(parseRuns(source['runs'])),
    'problem' => ProblemLessonBlock(parseLessonBlocks(source['blocks'])),
    'attempt' => AttemptLessonBlock(
      prompt: parseLessonBlocks(source['prompt']),
      answer: parseLessonBlocks(source['answer']),
    ),
    'cycle' => CycleLessonBlock(_phases(source)),
    'phase_heading' => PhaseHeadingLessonBlock(
      id: textOf(source, 'id'),
      phases: _phases(source),
      runs: parseRuns(source['runs']),
    ),
    'brief' => _brief(source),
    'paradigm' => _paradigm(source),
    _ => _toolBlock(type, source),
  };
}

LessonBlock _toolBlock(String type, Map<String, Object?> source) {
  return switch (type) {
    'roles' => RolesLessonBlock(mappedList(source['roles'], _role)),
    'recall' => RecallLessonBlock(
      term: textOf(source, 'term'),
      label: textOf(source, 'label'),
      runs: parseRuns(source['runs']),
      lesson: parseLessonReference(source['lesson']),
    ),
    'spec_links' => SpecLinksLessonBlock(
      mappedList(source['links'], parseSectionLink),
    ),
    'deepen' => DeepenLessonBlock(
      title: optionalTextOf(source, 'title'),
      blocks: parseLessonBlocks(source['blocks']),
    ),
    'practice' => PracticeLessonBlock(
      mappedList(source['exercises'], (entry) => textOf(objectOf(entry), 'id')),
    ),
    _ => _closingBlock(type, source),
  };
}

LessonBlock _closingBlock(String type, Map<String, Object?> source) {
  return switch (type) {
    'next' => NextLessonBlock(
      lesson: _optionalReference(source['lesson']),
      runs: parseRuns(source['runs']),
    ),
    'spec_figure' => SpecFigureLessonBlock(
      sectionId: textOf(source, 'section'),
      number: textOf(source, 'number'),
      figure: parseFigure(objectOf(source['figure'])),
    ),
    _ => CalloutLessonBlock(
      kind: parseCalloutKind(textOf(source, 'kind')),
      collapsible: flagOf(source, 'collapsible'),
      blocks: parseLessonBlocks(source['blocks']),
    ),
  };
}

List<int> _phases(Map<String, Object?> source) =>
    mappedList(source['phases'], (phase) => phase is int ? phase : 0);

LessonBlock _brief(Map<String, Object?> source) => BriefLessonBlock(
  inputs: parseRuns(source['inputs']),
  outputs: parseRuns(source['outputs']),
  relation: parseRuns(source['relation']),
  examples: parseRunGroups(source['examples']),
);

LessonBlock _paradigm(Map<String, Object?> source) => ParadigmLessonBlock(
  question: parseRuns(source['question']),
  metaphor: parseRuns(source['metaphor']),
  history: parseRuns(source['history']),
  cost: parseRuns(source['cost']),
);

RouteRole _role(Object? value) {
  final source = objectOf(value);
  return RouteRole(
    name: textOf(source, 'name'),
    description: parseRuns(source['description']),
    figure: parseFigure(objectOf(source['figure'])),
  );
}
