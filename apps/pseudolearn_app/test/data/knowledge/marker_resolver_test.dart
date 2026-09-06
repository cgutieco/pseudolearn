import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/content_assets.dart';
import 'package:pseudolearn_app/data/knowledge/referenced_content_ids.dart';
import 'package:pseudolearn_app/data/knowledge/marker_resolver.dart';
import 'package:pseudolearn_app/domain/model/analysis/app_diagnostic.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/knowledge/syntax_reference_generator.dart';

ContentLoadResult<List<ContentBlock>> _resolve(
  List<ContentBlock> blocks, {
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
  UiLanguageId languageId = UiLanguageId.spanish,
  Map<String, String> examples = const {},
}) {
  const resolver = MarkerResolver(reference: SyntaxReferenceGenerator());
  return resolver.resolveAll(
    blocks: blocks,
    profileId: profileId,
    languageId: languageId,
    assets: ContentAssets(exampleSources: examples),
  );
}

List<ContentBlock> _resolved(
  List<ContentBlock> blocks, {
  SyntaxProfileId profileId = SyntaxProfileId.classicSpanish,
  UiLanguageId languageId = UiLanguageId.spanish,
  Map<String, String> examples = const {},
}) {
  final result = _resolve(
    blocks,
    profileId: profileId,
    languageId: languageId,
    examples: examples,
  );
  return (result as ContentLoaded<List<ContentBlock>>).value;
}

void main() {
  group('inline markers', () {
    test('a lexeme marker is replaced by the lexeme of the active profile', () {
      final spanish = _resolved(
        const [ParagraphBlock(text: 'Se escribe {{lexema:whileKeyword}} para repetir.')],
      );
      final english = _resolved(
        const [ParagraphBlock(text: 'Se escribe {{lexema:whileKeyword}} para repetir.')],
        profileId: SyntaxProfileId.english,
        languageId: UiLanguageId.english,
      );

      expect((spanish.single as ParagraphBlock).text, 'Se escribe Mientras para repetir.');
      expect((english.single as ParagraphBlock).text, 'Se escribe while para repetir.');
    });

    test('a signature marker is replaced by the signature of the built-in', () {
      final blocks = _resolved(
        const [ParagraphBlock(text: 'La firma es {{firma:length}}.')],
      );

      expect((blocks.single as ParagraphBlock).text, contains('Longitud('));
    });

    test('markers inside a heading and inside a list item are replaced too', () {
      final blocks = _resolved(const [
        HeadingBlock(level: 2, text: 'La palabra {{lexema:whileKeyword}}'),
        ListBlock(items: ['Se abre con {{lexema:ifKeyword}}']),
      ]);

      expect((blocks.first as HeadingBlock).text, 'La palabra Mientras');
      expect((blocks.last as ListBlock).items.single, contains('Si'));
    });

    test('several markers in one paragraph are all replaced', () {
      final blocks = _resolved(
        const [ParagraphBlock(text: '{{lexema:ifKeyword}} y {{lexema:whileKeyword}}')],
      );

      expect((blocks.single as ParagraphBlock).text, 'Si y Mientras');
    });

    test('text without markers passes through untouched', () {
      final blocks = _resolved(const [ParagraphBlock(text: 'Sin marcadores.')]);

      expect((blocks.single as ParagraphBlock).text, 'Sin marcadores.');
    });
  });

  group('standalone markers become blocks', () {
    test('a table marker becomes a table block', () {
      final blocks = _resolved(const [ParagraphBlock(text: '{{tabla:precedence}}')]);

      expect(blocks.single, isA<TableBlock>());
      expect((blocks.single as TableBlock).rows.length, 8);
    });

    test('the primitive types table names the types of the active profile', () {
      final blocks = _resolved(const [ParagraphBlock(text: '{{tabla:primitiveTypes}}')]);

      expect((blocks.single as TableBlock).rows.first.single, 'entero');
    });

    test('the built-in functions table has one row per catalogued function', () {
      final blocks = _resolved(const [ParagraphBlock(text: '{{tabla:builtinFunctions}}')]);

      expect((blocks.single as TableBlock).rows.length, 18);
    });

    test('an example marker becomes a code block with the real program', () {
      final blocks = _resolved(
        const [ParagraphBlock(text: '{{ejemplo:example-sum}}')],
        examples: {'example-sum': 'Algoritmo S\nFinAlgoritmo'},
      );

      expect(blocks.single, isA<CodeBlock>());
      expect((blocks.single as CodeBlock).code, contains('Algoritmo S'));
    });

    test('a figure marker becomes a figure block captioned by the catalogue', () {
      const resolver = MarkerResolver(reference: SyntaxReferenceGenerator());
      final result = resolver.resolveAll(
        blocks: const [ParagraphBlock(text: '{{figura:cajas-memoria}}')],
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
        assets: const ContentAssets(
          illustrationTitles: {'cajas-memoria': 'Cajas de memoria'},
        ),
      );
      final blocks = (result as ContentLoaded<List<ContentBlock>>).value;

      expect(blocks.single, isA<FigureBlock>());
      expect((blocks.single as FigureBlock).caption, 'Cajas de memoria');
    });

    test('a diagram marker becomes a diagram block with its program and notation', () {
      final blocks = _resolved(
        const [ParagraphBlock(text: '{{diagrama:example-sum#ordinograma}}')],
        examples: {'example-sum': 'Algoritmo S\nFinAlgoritmo'},
      );

      expect(blocks.single, isA<DiagramBlock>());
      expect((blocks.single as DiagramBlock).notation, DiagramNotation.flowchart);
    });

    test('a diagram marker with an unknown notation is a named load failure', () {
      final result = _resolve(
        const [ParagraphBlock(text: '{{diagrama:example-sum#mapa}}')],
        examples: {'example-sum': 'Algoritmo S'},
      );

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('a figure the catalogue does not have is a named load failure', () {
      final result = _resolve(const [ParagraphBlock(text: '{{figura:ausente}}')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('a diagnostic marker becomes a diagnostic block with code, message and severity', () {
      final blocksSpanish = _resolved(
        const [ParagraphBlock(text: '{{diagnostico:expectedAlgorithmStart}}')],
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final blocksEnglish = _resolved(
        const [ParagraphBlock(text: '{{diagnostico:expectedAlgorithmStart}}')],
        profileId: SyntaxProfileId.english,
        languageId: UiLanguageId.english,
      );

      expect(blocksSpanish.single, isA<DiagnosticBlock>());
      final diagSpanish = blocksSpanish.single as DiagnosticBlock;
      expect(diagSpanish.code, 'expectedAlgorithmStart');
      expect(diagSpanish.severity, AppSeverity.error);
      expect(diagSpanish.message, contains('inicio del algoritmo'));

      expect(blocksEnglish.single, isA<DiagnosticBlock>());
      final diagEnglish = blocksEnglish.single as DiagnosticBlock;
      expect(diagEnglish.code, 'expectedAlgorithmStart');
      expect(diagEnglish.severity, AppSeverity.error);
      expect(diagEnglish.message, contains('Expected algorithm start'));
    });
  });

  group('markers that do not resolve', () {
    test('a lexeme the language does not have is a named load failure', () {
      final result = _resolve(
        const [ParagraphBlock(text: 'Se escribe {{lexema:goto}}.')],
      );

      final failed = result as ContentLoadFailed<List<ContentBlock>>;
      expect(failed.failure, ContentLoadFailure.unresolvedMarker);
      expect(failed.detail, '{{lexema:goto}}');
    });

    test('a table that does not exist is a named load failure', () {
      final result = _resolve(const [ParagraphBlock(text: '{{tabla:conversiones}}')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('a diagnostic code the engine does not have is a named load failure', () {
      final result = _resolve(const [ParagraphBlock(text: '{{diagnostico:tabError}}')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('an example with no source is a named load failure', () {
      final result = _resolve(const [ParagraphBlock(text: '{{ejemplo:ausente}}')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('a malformed marker is a named load failure, not an empty string', () {
      final result = _resolve(const [ParagraphBlock(text: 'Roto {{lexema}} aqui.')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });

    test('an unknown marker kind is a named load failure', () {
      final result = _resolve(const [ParagraphBlock(text: 'Roto {{simbolo:x}} aqui.')]);

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });
  });

  group('edge cases', () {
    test('no blocks resolve to no blocks', () {
      expect(_resolved(const []), isEmpty);
    });

    test('a code block is never scanned for markers', () {
      final blocks = _resolved(
        const [CodeBlock(code: 'Escribir "{{lexema:goto}}"')],
      );

      expect((blocks.single as CodeBlock).code, contains('{{lexema:goto}}'));
    });

    test('the content identifiers a document references are reported before resolution', () {
      const resolver = MarkerResolver(reference: SyntaxReferenceGenerator());
      final markers = resolver.markersIn(const [
        ParagraphBlock(text: '{{ejemplo:uno}}'),
        ParagraphBlock(text: 'Texto {{figura:cajas}} mas texto'),
        ParagraphBlock(text: '{{diagrama:dos#ordinograma}}'),
        ParagraphBlock(text: '{{lexema:ifKeyword}}'),
      ]);

      expect(referencedContentIds(markers), {'uno', 'cajas', 'dos'});
    });
  });
}
