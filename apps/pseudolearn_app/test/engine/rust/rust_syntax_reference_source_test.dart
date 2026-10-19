import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/marker_resolution.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/rust/rust_syntax_reference_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import '../../fakes/fake_rust_transport.dart';

FakeRustTransport _transport() => FakeRustTransport({
  'editor_vocabulary': (_) => {
    'keywords': [
      ['algorithm', 'Proceso'],
      ['integerType', 'Entero'],
      ['realType', 'Real'],
      ['booleanType', 'Logico'],
      ['characterType', 'Caracter'],
      ['stringType', 'Cadena'],
      ['plus', '+'],
      ['minus', '-'],
      ['not', 'NO'],
      ['power', '^'],
    ],
  },
  'reference_vocabulary': (_) => {
    'identifier_label': 'identificador',
    'builtins': [
      {
        'identity': 'squareRoot',
        'lexeme': 'Raiz',
        'parameters': ['numeric'],
        'returns': 'real',
      },
      {
        'identity': 'shallowCopy',
        'lexeme': 'Copiar',
        'parameters': ['anyClass'],
        'returns': 'sameAsFirstArgument',
      },
    ],
    'precedence': [
      {
        'level': 1,
        'operators': ['plus', 'minus', 'not'],
        'right_associative': true,
      },
      {
        'level': 2,
        'operators': ['power'],
        'right_associative': true,
      },
    ],
  },
  'diagnostic_template': (arguments) {
    if (arguments['code'] != 'undeclaredVariable') {
      throw const RustBridgeFailure(family: 'usage', detail: 'unknown code');
    }
    return {
      'code': 'undeclaredVariable',
      'template': 'Variable no declarada: {name}',
      'severity': 'warning',
    };
  },
});

MarkerResolution? _resolve(
  RustSyntaxReferenceSource source,
  ContentMarkerKind kind,
  String argument,
) => source.resolveMarker(
  marker: ContentMarker(kind: kind, argument: argument),
  profileId: SyntaxProfileId.classicSpanish,
  languageId: UiLanguageId.spanish,
);

void main() {
  late RustSyntaxReferenceSource source;

  setUp(() => source = RustSyntaxReferenceSource(_transport()));

  test('lists one reference entry per profile', () {
    final entries = source.getReferenceEntries();

    expect(entries, hasLength(2));
    expect(entries.every((e) => e.type == KnowledgeEntryType.reference), isTrue);
  });

  test('builds blocks from the generated vocabulary', () {
    final blocks = source.getBlocksForProfile(SyntaxProfileId.classicSpanish);
    final items = blocks.whereType<ListBlock>().expand((l) => l.items).toList();

    expect(blocks.whereType<HeadingBlock>(), hasLength(4));
    expect(items, containsAll(['Entero', 'Proceso', 'Raiz', 'Copiar']));
  });

  test('returns no blocks when the transport fails', () {
    final failing = RustSyntaxReferenceSource(FakeRustTransport({}));

    expect(failing.getBlocksForProfile(SyntaxProfileId.english), isEmpty);
  });

  test('resolves lexeme markers and rejects unknown identities', () {
    expect(
      _resolve(source, ContentMarkerKind.lexeme, 'algorithm'),
      const ResolvedMarkerText('Proceso'),
    );
    expect(_resolve(source, ContentMarkerKind.lexeme, 'missing'), isNull);
  });

  test('renders signatures with profile type names', () {
    expect(
      _resolve(source, ContentMarkerKind.signature, 'squareRoot'),
      const ResolvedMarkerText('Raiz(Entero | Real)'),
    );
    expect(
      _resolve(source, ContentMarkerKind.signature, 'shallowCopy'),
      const ResolvedMarkerText('Copiar(identificador)'),
    );
    expect(_resolve(source, ContentMarkerKind.signature, 'missing'), isNull);
  });

  test('renders the type, precedence and function tables', () {
    final types =
        _resolve(source, ContentMarkerKind.table, 'primitiveTypes')
            as ResolvedMarkerTable;
    final precedence =
        _resolve(source, ContentMarkerKind.table, 'precedence')
            as ResolvedMarkerTable;
    final functions =
        _resolve(source, ContentMarkerKind.table, 'builtinFunctions')
            as ResolvedMarkerTable;

    expect(types.rows, hasLength(5));
    expect(precedence.rows.first, ['1', '+ - NO', 'derecha']);
    expect(functions.rows.last, ['Copiar(identificador)', 'identificador']);
    expect(_resolve(source, ContentMarkerKind.table, 'missing'), isNull);
  });

  test('fills diagnostic placeholders and maps severity', () {
    final resolved =
        _resolve(source, ContentMarkerKind.diagnostic, 'undeclaredVariable')
            as ResolvedMarkerDiagnostic;

    expect(resolved.message, 'Variable no declarada: ...');
    expect(resolved.severity, AppSeverity.warning);
  });

  test('rejects unknown diagnostic codes', () {
    expect(_resolve(source, ContentMarkerKind.diagnostic, 'nope'), isNull);
  });
}
