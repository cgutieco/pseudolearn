import '../../domain/model/execution/output_line.dart';
import 'rust_execution_event_effects.dart';
import 'rust_execution_readers.dart';
import 'rust_focus_tracker.dart';
import 'rust_program_view.dart';
import 'rust_state_api.dart';
import 'rust_transport.dart';
import 'rust_watch_rows.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

final class RustExecutionEventConsumer {
  final RustWatchRows _watch;
  final RustExecutionEventEffects _effects = RustExecutionEventEffects();

  RustExecutionEventConsumer(RustTransport transport)
    : _watch = RustWatchRows(RustStateApi(transport));

  List<OutputLine> get outputLines => _effects.outputLines;

  String? get inputPrompt => _effects.inputPrompt;

  void clear() => _effects.clear();

  void clearInputPrompt() => _effects.clearInputPrompt();

  String? consume({
    required RustEvent event,
    required int eventIndex,
    required int execution,
    required RustProgramView view,
    required SourceOffsetIndex offsets,
    required RustFocusTracker tracker,
  }) {
    try {
      if (!tracker.apply(event, eventIndex)) return 'invalid_event_sequence';
    } on Object {
      return 'invalid_event';
    }
    _effects.record(event, view, offsets);
    if (!rustEventRequiresEnvironment(event.eventClass)) return null;
    final result = _watch.at(
      execution: execution,
      event: eventIndex,
      taskId: tracker.currentTaskId,
      depth: event.depth,
    );
    if (result is RustEnvironmentFailure) return result.reason;
    final environment = (result as RustEnvironmentValue).environment;
    tracker.recordEnvironment(
      taskId: tracker.currentTaskId,
      eventIndex: eventIndex,
      scopeName: environment.scopeName,
      scopeDepth: environment.depth,
      variables: environment.rows,
    );
    return null;
  }
}
