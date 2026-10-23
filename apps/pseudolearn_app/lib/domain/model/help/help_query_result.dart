import 'package:equatable/equatable.dart';
import 'syntax_help.dart';

enum HelpOutcome { help, symbol, noHelp, invalidPosition, failure }

final class HelpQueryResult extends Equatable {
  final HelpOutcome outcome;
  final int revision;
  final SyntaxHelp? help;

  const HelpQueryResult._(this.outcome, this.revision, this.help);

  const HelpQueryResult.help(SyntaxHelp help, {required int revision})
    : this._(HelpOutcome.help, revision, help);

  const HelpQueryResult.symbol(SyntaxHelp help, {required int revision})
    : this._(HelpOutcome.symbol, revision, help);

  const HelpQueryResult.noHelp({required int revision})
    : this._(HelpOutcome.noHelp, revision, null);

  const HelpQueryResult.invalidPosition({required int revision})
    : this._(HelpOutcome.invalidPosition, revision, null);

  const HelpQueryResult.failure({required int revision})
    : this._(HelpOutcome.failure, revision, null);

  @override
  List<Object?> get props => [outcome, revision, help];
}
