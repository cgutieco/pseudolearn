import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_callout_kind.dart';
import 'package:pseudolearn_app/data/reference/bundled_reference_repository.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_block.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_index.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_section.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

const _spanish = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

BundledReferenceRepository _fromFiles() => BundledReferenceRepository(
  assetLoader: (path) async => File(path).readAsString(),
);

BundledReferenceRepository _fromMap(Map<String, String> assets) =>
    BundledReferenceRepository(
      assetLoader: (path) async {
        final text = assets[path];
        if (text == null) throw StateError(path);
        return text;
      },
    );

void main() {
  group('BundledReferenceRepository over the generated bundle', () {
    for (final language in [UiLanguageId.spanish, UiLanguageId.english]) {
      for (final profile in SyntaxProfileId.values) {
        final edition = ReferenceEdition(language: language, profile: profile);
        test('parses every section of ${edition.directory}', () async {
          final repository = _fromFiles();
          final index = await repository.loadIndex(edition);
          expect(index, isA<ContentLoaded<ReferenceIndex>>());
          final sections = (index as ContentLoaded<ReferenceIndex>).value.sections;
          expect(sections, isNotEmpty);
          for (final entry in sections) {
            final loaded = await repository.loadSection(edition, entry.id);
            expect(loaded, isA<ContentLoaded<ReferenceSection>>(), reason: entry.id);
          }
          expect(await repository.loadSearch(edition), isA<ContentLoaded<Object?>>());
          expect(await repository.loadLinks(edition), isA<ContentLoaded<Object?>>());
        });
      }
    }
  });

  group('BundledReferenceRepository failures', () {
    test('a missing asset is reported, not thrown', () async {
      final result = await _fromMap({}).loadSection(_spanish, 'nada');
      expect(result, isA<ContentLoadFailed<ReferenceSection>>());
      expect((result as ContentLoadFailed<ReferenceSection>).failure, ContentLoadFailure.assetMissing);
    });

    test('a malformed section is reported as malformed', () async {
      final repository = _fromMap({'assets/reference/es/keywords-es/sections/mala.json': '{"id": 1}'});
      final result = await repository.loadSection(_spanish, 'mala');
      expect((result as ContentLoadFailed<ReferenceSection>).failure, ContentLoadFailure.malformedReference);
    });

    test('an unknown block or category is malformed', () async {
      const unknownBlock = '{"id":"a","number":"1","kind":"concepto","title":[],"phrase":[],"blocks":[{"type":"video"}]}';
      const unknownCategory = '{"id":"a","number":"1","kind":"concepto","title":[{"type":"code","tokens":[["x","color"]]}],"phrase":[],"blocks":[]}';
      final repository = _fromMap({
        'assets/reference/es/keywords-es/sections/bloque.json': unknownBlock,
        'assets/reference/es/keywords-es/sections/categoria.json': unknownCategory,
      });
      expect(await repository.loadSection(_spanish, 'bloque'), isA<ContentLoadFailed<ReferenceSection>>());
      expect(await repository.loadSection(_spanish, 'categoria'), isA<ContentLoadFailed<ReferenceSection>>());
    });

    test('parses programs, figures and callouts', () async {
      const section = '{"id":"a","number":"1","kind":"construccion","title":[{"type":"text","text":"T"}],"phrase":[],"blocks":['
          '{"type":"program","id":"p","title":"P","source":"x","lines":[[["Si","keywordStructured"],[" "]]],"executed":true,"output":"1\\n","termination":"completed","diagnostics":[]},'
          '{"type":"figure","id":"f","number":"1-1","alt":"A","description":"D","caption":[],"svg":"<svg/>","layers":[{"from_step":1,"svg":"<g/>"}],"steps":[{"runs":[]}],"panels":[]},'
          '{"type":"callout","kind":"inside","collapsible":true,"blocks":[{"type":"intermediate","program":"p","lines":["ret"]}]}]}';
      final loaded = await _fromMap({'assets/reference/es/keywords-es/sections/a.json': section}).loadSection(_spanish, 'a');
      final blocks = (loaded as ContentLoaded<ReferenceSection>).value.blocks;
      expect(blocks[0], isA<ReferenceProgramBlock>());
      expect((blocks[0] as ReferenceProgramBlock).program.completed, isTrue);
      expect((blocks[1] as ReferenceFigureBlock).figure.layers.single.untilStep, isNull);
      expect((blocks[2] as ReferenceCallout).collapsible, isTrue);
    });

    test('parses an anatomy into code parts with their labels', () async {
      const section = '{"id":"a","number":"1","kind":"tipo","title":[],"phrase":[],"blocks":['
          '{"type":"anatomy","parts":['
          '{"tokens":[["Dimension","keywordStructured"]],"label":[{"type":"text","text":"palabra"}]},'
          '{"tokens":[["notas","identifier"],["["],["4","literalNumber"],["]"]],"label":[{"type":"code","tokens":[["Como"]]}]}]}]}';
      final loaded = await _fromMap({'assets/reference/es/keywords-es/sections/a.json': section}).loadSection(_spanish, 'a');
      final anatomy = (loaded as ContentLoaded<ReferenceSection>).value.blocks.single as ReferenceAnatomy;
      expect(anatomy.parts, hasLength(2));
      expect(anatomy.parts.first.tokens.single.text, 'Dimension');
      expect(anatomy.parts.last.tokens.map((token) => token.text).join(), 'notas[4]');
      expect(anatomy.parts.last.label.single.plainText, 'Como');
    });

    test('an anatomy without parts or labels is malformed', () async {
      const withoutParts = '{"id":"a","number":"1","kind":"tipo","title":[],"phrase":[],"blocks":[{"type":"anatomy"}]}';
      const withoutLabel = '{"id":"b","number":"1","kind":"tipo","title":[],"phrase":[],"blocks":[{"type":"anatomy","parts":[{"tokens":[["x"]]}]}]}';
      final repository = _fromMap({
        'assets/reference/es/keywords-es/sections/a.json': withoutParts,
        'assets/reference/es/keywords-es/sections/b.json': withoutLabel,
      });
      for (final id in ['a', 'b']) {
        final result = await repository.loadSection(_spanish, id);
        expect((result as ContentLoadFailed<ReferenceSection>).failure, ContentLoadFailure.malformedReference);
      }
    });

    test('a rails block is no longer published and is malformed', () async {
      const section = '{"id":"a","number":"1","kind":"tipo","title":[],"phrase":[],"blocks":[{"type":"rails","svg":"<svg/>","alt":"A"}]}';
      final result = await _fromMap({'assets/reference/es/keywords-es/sections/a.json': section}).loadSection(_spanish, 'a');
      expect(result, isA<ContentLoadFailed<ReferenceSection>>());
    });

    test('a callout kind that is no longer published reads as a note', () async {
      const section = '{"id":"a","number":"1","kind":"concepto","title":[],"phrase":[],"blocks":['
          '{"type":"callout","kind":"teachers","collapsible":true,"blocks":[]},'
          '{"type":"callout","kind":"limit","collapsible":false,"blocks":[]}]}';
      final loaded = await _fromMap({'assets/reference/es/keywords-es/sections/a.json': section}).loadSection(_spanish, 'a');
      final blocks = (loaded as ContentLoaded<ReferenceSection>).value.blocks;
      expect((blocks[0] as ReferenceCallout).kind, ReferenceCalloutKind.note);
      expect((blocks[1] as ReferenceCallout).kind, ReferenceCalloutKind.limit);
    });
  });
}
