import '../../domain/model/profiles/syntax_profile_id.dart';
import 'rust_editor_vocabulary.dart';
import '../../domain/model/execution/output_line.dart';
import '../../domain/model/execution/read_request.dart';
import 'rust_execution_event_effects.dart';
import 'rust_execution_readers.dart';
import 'rust_focus_tracker.dart';
import 'rust_program_view.dart';
import 'rust_state_api.dart';
import 'rust_transport.dart';
import 'rust_watch_rows.dart';
import 'rust_wire_models.dart';
import 'source_offset_index.dart';

String? _applied(RustFocusTracker tracker, RustEvent event, int eventIndex) {
  try {
    return tracker.apply(event, eventIndex) ? null : 'invalid_event_sequence';
  } on Object {
    return 'invalid_event';
  }
}

final class RustExecutionEventConsumer {
  final RustWatchRows _watch;
  final RustEditorVocabulary _vocabulary;
  final RustExecutionEventEffects _effects = RustExecutionEventEffects();
  bool observesEnvironment = true;

  RustExecutionEventConsumer(RustTransport transport)
    : _watch = RustWatchRows(RustStateApi(transport)),
      _vocabulary = RustEditorVocabulary(transport);

  List<OutputLine> get outputLines => _effects.outputLines;

  ReadRequest? get readRequest => _effects.readRequest;

  void clear() => _effects.clear();

  void configure(SyntaxProfileId profile) =>
      _watch.useReceiverName(_vocabulary.receiverName(profile));

  void submitInput(String text) => _effects.submitInput(text);

  String? consume({
    required RustEvent event,
    required int eventIndex,
    required int execution,
    required RustProgramView view,
    required SourceOffsetIndex offsets,
    required RustFocusTracker tracker,
    List<(int, int)> errorRanges = const [],
    String? rejectionMessage,
  }) {
    final rejected = _applied(tracker, event, eventIndex);
    if (rejected != null) return rejected;
    _effects.record(
      event,
      view,
      offsets,
      errorRanges: errorRanges,
      rejectionMessage: rejectionMessage,
    );
    if (!observesEnvironment) return null;
    if (!rustEventRequiresEnvironment(event.eventClass)) return null;
    return _observeEnvironment(
      event: event,
      eventIndex: eventIndex,
      execution: execution,
      tracker: tracker,
    );
  }

  String? _observeEnvironment({
    required RustEvent event,
    required int eventIndex,
    required int execution,
    required RustFocusTracker tracker,
  }) {
    final result = _watch.at(
      execution: execution,
      event: eventIndex,
      taskId: tracker.currentTaskId,
      depth: event.depth,
    );
    if (result is RustEnvironmentUnavailable &&
        tracker.isResumingCancelledTask) {
      return null;
    }
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
