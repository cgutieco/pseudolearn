import 'package:equatable/equatable.dart';
import '../editor/caret_range.dart';
import 'help_form.dart';
import 'help_part.dart';
import 'help_program.dart';

final class HelpCardSections extends Equatable {
  final String id;
  final String title;
  final String summary;
  final HelpCategory? category;
  final List<HelpFormLine> form;
  final List<HelpPart> parts;
  final String? result;
  final List<String> rules;
  final List<HelpCommonError> commonErrors;
  final List<HelpExample> examples;

  const HelpCardSections({
    required this.id,
    required this.title,
    required this.summary,
    this.category,
    this.form = const [],
    this.parts = const [],
    this.result,
    this.rules = const [],
    this.commonErrors = const [],
    this.examples = const [],
  });

  HelpCardSections withPrograms({
    required List<HelpCommonError> commonErrors,
    required List<HelpExample> examples,
  }) => HelpCardSections(
    id: id,
    title: title,
    summary: summary,
    category: category,
    form: form,
    parts: parts,
    result: result,
    rules: rules,
    commonErrors: commonErrors,
    examples: examples,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    category,
    form,
    parts,
    result,
    rules,
    commonErrors,
    examples,
  ];
}

final class SyntaxHelp extends Equatable {
  final String headline;
  final String? description;
  final HelpCardSections? card;
  final CaretRange range;
  final bool isPartial;

  const SyntaxHelp({
    required this.headline,
    required this.range,
    this.description,
    this.card,
    this.isPartial = false,
  });

  SyntaxHelp withCard(HelpCardSections? value) => SyntaxHelp(
    headline: headline,
    range: range,
    description: description,
    card: value,
    isPartial: isPartial,
  );

  @override
  List<Object?> get props => [headline, description, card, range, isPartial];
}
