import 'package:equatable/equatable.dart';
import '../../../domain/model/analysis/source_range.dart';
import '../../../domain/model/help/help_query_result.dart';

final class SyntaxHelpState extends Equatable {
  final int documentRevision;
  final HelpQueryResult? result;
  final SourceRange? restingKeyword;

  const SyntaxHelpState({
    this.documentRevision = 0,
    this.result,
    this.restingKeyword,
  });

  bool get isVisible => result?.revision == documentRevision;

  HelpQueryResult? get visibleResult => isVisible ? result : null;

  SyntaxHelpState advancedTo(int revision) => SyntaxHelpState(
    documentRevision: revision,
    result: result?.revision == revision ? result : null,
  );

  SyntaxHelpState showing(HelpQueryResult next) =>
      SyntaxHelpState(documentRevision: next.revision, result: next);

  SyntaxHelpState cleared() =>
      SyntaxHelpState(documentRevision: documentRevision);

  SyntaxHelpState restingOn(SourceRange? keyword) => SyntaxHelpState(
    documentRevision: documentRevision,
    result: result,
    restingKeyword: keyword,
  );

  @override
  List<Object?> get props => [documentRevision, result, restingKeyword];
}
