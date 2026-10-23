import 'package:pseudolearn_app/application/editor/editor_cubit.dart';
import 'package:pseudolearn_app/application/editor/help/syntax_help_cubit.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/domain/model/help/help_query_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/domain/ports/clock.dart';
import 'package:pseudolearn_app/domain/ports/document_repository.dart';
import 'package:pseudolearn_app/domain/ports/text_entry_modality.dart';
import 'package:pseudolearn_app/engine/rust/rust_syntax_help_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

Future<Map<String, Object?>> runHelpScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  if (input['interface_languages'] is List<Object?>) {
    return _languageIndependence(transport, input);
  }
  if (input.containsKey('assistance_enabled')) {
    return _explicitQuery(transport, input);
  }
  final recorder = _RecordingTransport(transport);
  final result = _query(recorder, input, _language(input['interface_language']));
  return _projection(result, recorder);
}

Future<Map<String, Object?>> runHelpRevisionScenario(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final cubit = SyntaxHelpCubit(source: RustSyntaxHelpSource(transport));
  for (final event in (input['events'] as List<Object?>).cast<Map<String, Object?>>()) {
    final revision = event['revision'] as int;
    if (event['type'] == 'document_changed') {
      cubit.documentChanged(revision);
      continue;
    }
    cubit.request(
      sourceCode: event['document'] as String,
      profileId: SyntaxProfileId.classicSpanish,
      languageId: UiLanguageId.spanish,
      cursorUtf16: event['cursor_utf16'] as int,
      revision: revision,
    );
  }
  final visible = cubit.state.visibleResult;
  await cubit.close();
  return {
    'visible_revision': visible?.revision,
    'help_visible': visible != null,
    'stale_request_applied': visible != null &&
        visible.revision < cubit.state.documentRevision,
  };
}

Map<String, Object?> _languageIndependence(
  RustTransport transport,
  Map<String, Object?> input,
) {
  final titles = <String?>[];
  final identities = <Object?>{};
  final ranges = <Object?>{};
  for (final code in (input['interface_languages'] as List<Object?>)) {
    final recorder = _RecordingTransport(transport);
    final result = _query(recorder, input, _language(code));
    titles.add(result.help?.card?.title);
    final resolution = recorder.responses.last['resolution'] as Map?;
    identities.add('${resolution?['identity']}');
    ranges.add('${result.help?.range.start}-${result.help?.range.end}');
  }
  return {
    'titles': titles,
    'same_identity': identities.length == 1,
    'same_range': ranges.length == 1,
  };
}

Future<Map<String, Object?>> _explicitQuery(
  RustTransport transport,
  Map<String, Object?> input,
) async {
  final document = input['document'] as String;
  final services = buildRustEngineServices(transport);
  final editor = EditorCubit(
    repository: _UnusedRepository(),
    analyzer: services.analyzer,
    completionSource: services.completionSource,
    keySource: services.editorKeySource,
    sourceEditor: services.sourceEditor,
    textEntry: const _PhysicalEntry(),
    clock: const _FixedClock(),
  );
  editor.updateSourceCode(
    document,
    cursorUtf16: input['cursor_utf16'] as int,
    assisted: input['assistance_enabled'] == true,
  );
  final before = editor.state;
  final recorder = _RecordingTransport(transport);
  final help = SyntaxHelpCubit(source: RustSyntaxHelpSource(recorder));
  help.request(
    sourceCode: editor.state.sourceCode,
    profileId: SyntaxProfileId.classicSpanish,
    languageId: _language(input['interface_language']),
    cursorUtf16: input['cursor_utf16'] as int,
    revision: editor.state.completionRevision,
  );
  final unchanged = editor.state.sourceCode == before.sourceCode;
  final selectionKept = editor.state.pendingEdit == before.pendingEdit;
  await help.close();
  await editor.close();
  return {
    'help_requested': recorder.requests.any(
      (request) => request['operation'] == 'help_query',
    ),
    'document_changed': !unchanged || editor.state.sourceCode != document,
    'selection_preserved': selectionKept,
  };
}

HelpQueryResult _query(
  RustTransport transport,
  Map<String, Object?> input,
  UiLanguageId language,
) => RustSyntaxHelpSource(transport).query(
  sourceCode: input['document'] as String,
  profileId: input['profile'] == 'en'
      ? SyntaxProfileId.english
      : SyntaxProfileId.classicSpanish,
  languageId: language,
  cursorUtf16: input['cursor_utf16'] as int,
  revision: 1,
);

UiLanguageId _language(Object? code) =>
    code == 'en' ? UiLanguageId.english : UiLanguageId.spanish;

Map<String, Object?> _projection(
  HelpQueryResult result,
  _RecordingTransport recorder,
) {
  final asked = recorder.requests.any(
    (request) => request['operation'] == 'help_query',
  );
  final help = result.help;
  final entry = asked ? recorder.responses.last['help'] : null;
  return {
    'outcome': switch (result.outcome) {
      HelpOutcome.help => 'help',
      HelpOutcome.symbol => 'symbol',
      HelpOutcome.noHelp => 'no_help',
      HelpOutcome.invalidPosition => 'invalid_position',
      HelpOutcome.failure => 'failure',
    },
    'request_sent': asked,
    'document_changed': false,
    if (asked) 'source': 'API.MODEL',
    if (help?.card != null) 'title': help!.card!.title,
    if (help?.card != null) 'summary': help!.card!.summary,
    if (help != null) 'range_utf16': [help.range.start, help.range.end],
    if (entry is Map && result.outcome == HelpOutcome.symbol) ...{
      'identifier': entry['identifier'],
      'type_name': entry['type_name'],
    },
  };
}

final class _RecordingTransport implements RustTransport {
  final RustTransport delegate;
  final List<Map<String, Object?>> requests = [];
  final List<Map<String, Object?>> responses = [];

  _RecordingTransport(this.delegate);

  @override
  Object? call(String operation, Map<String, Object?> arguments) {
    requests.add({'operation': operation, ...arguments});
    final response = delegate.call(operation, arguments);
    if (operation == 'help_query' && response is Map<String, Object?>) {
      responses.add(response);
    }
    return response;
  }

  @override
  void close() => delegate.close();
}

final class _PhysicalEntry implements TextEntryModality {
  const _PhysicalEntry();

  @override
  bool get hasOnscreenTextEntry => false;
}

final class _FixedClock implements Clock {
  const _FixedClock();

  @override
  DateTime now() => DateTime.utc(2026);
}

final class _UnusedRepository implements DocumentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
