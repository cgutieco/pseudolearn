import 'package:equatable/equatable.dart';
import '../editor/caret_range.dart';

final class HelpPart extends Equatable {
  final String identity;
  final String text;

  const HelpPart({required this.identity, required this.text});

  @override
  List<Object?> get props => [identity, text];
}

final class HelpExampleLink extends Equatable {
  final String specification;
  final String version;
  final String caseId;
  final String profile;
  final String strictness;
  final String kind;
  final String label;

  const HelpExampleLink({
    required this.specification,
    required this.version,
    required this.caseId,
    required this.profile,
    required this.strictness,
    required this.kind,
    required this.label,
  });

  @override
  List<Object?> get props => [
    specification,
    version,
    caseId,
    profile,
    strictness,
    kind,
    label,
  ];
}

final class HelpCardSections extends Equatable {
  final String id;
  final String title;
  final String summary;
  final String purpose;
  final List<HelpPart> parts;
  final List<String> constraints;
  final List<String> commonErrors;
  final List<HelpExampleLink> examples;

  const HelpCardSections({
    required this.id,
    required this.title,
    required this.summary,
    this.purpose = '',
    this.parts = const [],
    this.constraints = const [],
    this.commonErrors = const [],
    this.examples = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    purpose,
    parts,
    constraints,
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

  @override
  List<Object?> get props => [headline, description, card, range, isPartial];
}
