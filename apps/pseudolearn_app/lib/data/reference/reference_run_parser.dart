import '../../domain/model/analysis/highlight_span.dart';
import '../../domain/model/reference/reference_run.dart';
import '../../domain/model/reference/reference_token.dart';
import 'reference_json.dart';

List<ReferenceRun> parseRuns(Object? value) => mappedList(value, parseRun);

ReferenceRun parseRun(Object? value) {
  final source = objectOf(value);
  return switch (textOf(source, 'type')) {
    'text' => ReferenceTextRun(textOf(source, 'text')),
    'strong' => ReferenceTextRun(
      textOf(source, 'text'),
      emphasis: ReferenceEmphasis.strong,
    ),
    'emphasis' => ReferenceTextRun(
      textOf(source, 'text'),
      emphasis: ReferenceEmphasis.italic,
    ),
    'code' => ReferenceCodeRun(parseTokens(source['tokens'])),
    'slot' => ReferenceSlotRun(textOf(source, 'text')),
    'link' => ReferenceLinkRun(
      sectionId: textOf(source, 'section'),
      text: textOf(source, 'text'),
    ),
    'term' => ReferenceTermRun(
      term: textOf(source, 'term'),
      text: textOf(source, 'text'),
    ),
    final other => _routeRun(other, source),
  };
}

ReferenceRun _routeRun(String type, Map<String, Object?> source) {
  return switch (type) {
    'definition' => ReferenceDefinitionRun(
      term: textOf(source, 'term'),
      text: textOf(source, 'text'),
    ),
    'spec_link' => ReferenceSpecLinkRun(
      sectionId: textOf(source, 'section'),
      anchor: source['anchor'] is String ? source['anchor'] as String : null,
      text: textOf(source, 'text'),
    ),
    'lesson_link' => ReferenceLessonLinkRun(
      lessonId: textOf(source, 'lesson'),
      text: textOf(source, 'text'),
    ),
    final other => throw FormatException('unknown run $other'),
  };
}

List<ReferenceToken> parseTokens(Object? value) =>
    mappedList(value, parseToken);

ReferenceToken parseToken(Object? value) {
  final pair = listOf(value);
  final text = pair.isNotEmpty ? pair.first : null;
  if (text is! String) throw const FormatException('a token needs its text');
  final category = pair.length > 1 ? pair[1] : null;
  return ReferenceToken(text: text, category: _category(category));
}

HighlightCategory? _category(Object? name) {
  if (name is! String) return null;
  for (final category in HighlightCategory.values) {
    if (category.name == name) return category;
  }
  throw FormatException('unknown category $name');
}

List<List<ReferenceRun>> parseRunGroups(Object? value) =>
    mappedList(value, parseRuns);
