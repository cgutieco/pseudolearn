import 'package:pseudolearn_core/pseudolearn_core.dart';

final class TraceRecorder {
  final Map<NodeId, int> lines;
  final List<Map<String, Object?>> events = [];
  final List<EnvironmentSnapshot?> snapshots = [];
  final List<int> _statements = [];
  final List<int> _calls = [];
  EnvironmentSnapshot? _latest;

  TraceRecorder(this.lines);

  int get statementEntries =>
      events.where((event) => event['class'] == 'statement_entered').length;

  void record(ExecutionEvent event) {
    switch (event) {
      case StatementEnteredEvent(:final statementId, :final snapshot):
        _statements.add(lines[statementId] ?? 0);
        _add('statement_entered', _statements.last, const {}, snapshot);
      case StatementExitedEvent(:final statementId, :final snapshot):
        if (_statements.isNotEmpty) _statements.removeLast();
        _add('statement_exited', lines[statementId] ?? 0, const {}, snapshot);
      case DecisionEvaluatedEvent():
        _add('decision', event.decisionSpan.start.line, _branch(event),
            event.snapshot);
      case SubroutineEnteredEvent(:final subroutineName, :final callSpan):
        _calls.add(callSpan.start.line);
        _add('call', callSpan.start.line, {'nombre': subroutineName},
            event.snapshot);
      case SubroutineExitedEvent(:final subroutineName, :final snapshot):
        final line = _calls.isEmpty ? 0 : _calls.removeLast();
        _add('return', line, {'nombre': subroutineName}, snapshot);
      default:
        _recordEffect(event);
    }
  }

  void fail(Diagnostic diagnostic) => _add('failure',
      diagnostic.span.start.line, {'codigo': diagnostic.code.name}, null);

  void _recordEffect(ExecutionEvent event) {
    final line = _statements.isEmpty ? 0 : _statements.last;
    switch (event) {
      case OutputProducedEvent(:final text):
        _add('output', line, {'texto': text}, null);
      case InputRequestedEvent():
        _add('input_requested', line, const {}, null);
      case InputAcceptedEvent(:final rawText):
        _add('input_received', line, {'texto': rawText}, null);
      default:
        break;
    }
  }

  void _add(String kind, int line, Map<String, Object?> payload,
      EnvironmentSnapshot? snapshot) {
    _latest = snapshot ?? _latest;
    events.add({'class': kind, 'line': line, 'data': payload});
    snapshots.add(_latest);
  }
}

Map<String, Object?> _branch(DecisionEvaluatedEvent event) =>
    switch (event.branch) {
      DecisionBranch.affirmative => {'rama': 'afirmativa'},
      DecisionBranch.negative => {'rama': 'negativa'},
      DecisionBranch.selectedCase => {
          'rama': 'caso',
          'indice': event.caseIndex ?? 0
        },
      DecisionBranch.defaultCase => {'rama': 'otro'},
    };
