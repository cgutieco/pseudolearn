import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/knowledge/bundled_knowledge_repository.dart';
import 'package:pseudolearn_app/data/knowledge/marker_resolver.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/knowledge/syntax_reference_generator.dart';

const String _manifest = '''
{
  "manifestVersion": 2,
  "contentVersion": 1,
  "modules": [
    {
      "id": "CON-B1",
      "track": "B",
      "order": 1,
      "title": "Datos",
      "summary": "Tipos y variables.",
      "path": "modules/CON-B1_es.md"
    }
  ],
  "examples": [
    {
      "id": "example-sum",
      "title": "Suma",
      "summary": "Suma dos valores.",
      "path": "examples/sum_es.pseudo",
      "profile": "classic_spanish"
    }
  ]
}
''';

const String _module = '''
:::parte pregunta
Por que hace falta guardar valores.

:::parte modelo-maquina
La memoria tiene nombres.

:::parte desarrollo
Se escribe {{lexema:whileKeyword}} para repetir.

{{ejemplo:example-sum}}

:::parte prediccion
Que valor tiene a en el paso 4.

:::parte errores-frecuentes
Leer una variable sin asignarla.

:::parte especificacion
- ESP-I, datos

:::parte ejercicios
- CON-B1-E1
''';

const String _exercise = '''
{
  "id": "CON-B1-E1",
  "title": "Cuadrado",
  "statement": "Lee un entero y escribe su cuadrado.",
  "level": 1,
  "kind": "crear",
  "visibleCases": [
    {"inputs": ["4"], "expectedOutputs": ["16"], "expected": "numerico"}
  ],
  "hiddenCases": []
}
''';

const KnowledgeEntry _moduleEntry = KnowledgeEntry(
  id: 'CON-B1',
  type: KnowledgeEntryType.module,
  title: 'Datos',
  summary: 'Tipos y variables.',
  path: 'modules/CON-B1_es.md',
  track: LearningTrack.imperative,
  order: 1,
);

BundledKnowledgeRepository _repository({Map<String, String> assets = const {}}) {
  return BundledKnowledgeRepository(
    markers: const MarkerResolver(reference: SyntaxReferenceGenerator()),
    assetLoader: (path) async {
      final source = assets[path];
      if (source == null) throw Exception('Asset not found: $path');
      return source;
    },
  );
}

const Map<String, String> _assets = {
  'assets/knowledge/manifest_es.json': _manifest,
  'assets/knowledge/modules/CON-B1_es.md': _module,
  'assets/knowledge/examples/sum_es.pseudo': 'Algoritmo Suma\nFinAlgoritmo',
  'assets/knowledge/exercises/CON-B1-E1_es.json': _exercise,
};

void main() {
  group('BundledKnowledgeRepository entries', () {
    test('serves the manifest v2 entries', () async {
      final result = await _repository(assets: _assets).getEntries(UiLanguageId.spanish);
      final entries = (result as ContentLoaded<List<KnowledgeEntry>>).value;

      expect(entries.length, 2);
      expect(entries.first.type, KnowledgeEntryType.module);
      expect(entries.first.track, LearningTrack.imperative);
    });

    test('a missing manifest is a named failure, never an exception', () async {
      final result = await _repository().getEntries(UiLanguageId.spanish);

      expect(
        (result as ContentLoadFailed<List<KnowledgeEntry>>).failure,
        ContentLoadFailure.assetMissing,
      );
    });

    test('a manifest that does not decode is a named failure', () async {
      final result = await _repository(
        assets: {'assets/knowledge/manifest_es.json': '{ not json'},
      ).getEntries(UiLanguageId.spanish);

      expect(
        (result as ContentLoadFailed<List<KnowledgeEntry>>).failure,
        ContentLoadFailure.malformedManifest,
      );
    });
  });

  group('BundledKnowledgeRepository modules', () {
    test('reads a module with its seven parts and resolves its markers', () async {
      final result = await _repository(assets: _assets).getModule(
        entry: _moduleEntry,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );
      final module = (result as ContentLoaded<LearningModule>).value;

      expect(module.id, 'CON-B1');
      expect(module.track, LearningTrack.imperative);
      expect(module.sections.length, 7);

      final development = module.sectionOf(ModulePart.development)!;
      expect(
        (development.blocks.first as ParagraphBlock).text,
        contains('Mientras'),
      );
      expect(development.blocks.last, isA<CodeBlock>());
      expect((development.blocks.last as CodeBlock).code, contains('Algoritmo Suma'));
      expect((development.blocks.last as CodeBlock).title, 'Suma');
    });

    test('a module whose file is absent is a named failure', () async {
      final result = await _repository(assets: {
        'assets/knowledge/manifest_es.json': _manifest,
      }).getModule(
        entry: _moduleEntry,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(
        (result as ContentLoadFailed<LearningModule>).failure,
        ContentLoadFailure.assetMissing,
      );
    });

    test('a module entry with no declared track is a named failure', () async {
      const withoutTrack = KnowledgeEntry(
        id: 'CON-B1',
        type: KnowledgeEntryType.module,
        title: 'Datos',
        summary: '',
        path: 'modules/CON-B1_es.md',
      );

      final result = await _repository(assets: _assets).getModule(
        entry: withoutTrack,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(
        (result as ContentLoadFailed<LearningModule>).failure,
        ContentLoadFailure.malformedManifest,
      );
    });

    test('a module with an unresolvable marker is a named failure', () async {
      final broken = _module.replaceAll('{{lexema:whileKeyword}}', '{{lexema:goto}}');
      final result = await _repository(assets: {
        ..._assets,
        'assets/knowledge/modules/CON-B1_es.md': broken,
      }).getModule(
        entry: _moduleEntry,
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(
        (result as ContentLoadFailed<LearningModule>).failure,
        ContentLoadFailure.unresolvedMarker,
      );
    });
  });

  group('BundledKnowledgeRepository exercises and raw content', () {
    test('reads an exercise document', () async {
      final result = await _repository(assets: _assets)
          .getExercise('exercises/CON-B1-E1_es.json');

      expect((result as ContentLoaded<Exercise>).value.id, 'CON-B1-E1');
    });

    test('a missing exercise is a named failure', () async {
      final result = await _repository().getExercise('exercises/absent.json');

      expect(
        (result as ContentLoadFailed<Exercise>).failure,
        ContentLoadFailure.assetMissing,
      );
    });

    test('raw content of a missing asset is empty, not an exception', () async {
      expect(await _repository().getRawContent('examples/absent.pseudo'), isEmpty);
      expect(await _repository().getRawContent(''), isEmpty);
    });

    test('serves the raw source of an example', () async {
      final source = await _repository(assets: _assets)
          .getRawContent('examples/sum_es.pseudo');

      expect(source, contains('Algoritmo Suma'));
    });
  });

  group('BundledKnowledgeRepository documents', () {
    test('serves a plain markdown document with its markers resolved', () async {
      final result = await _repository(assets: {
        'assets/knowledge/manifest_es.json': _manifest,
        'assets/knowledge/support/contact_es.md': '# Contacto\n\nEscribe a soporte.',
      }).getDocumentBlocks(
        path: 'support/contact_es.md',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect((result as ContentLoaded<List<ContentBlock>>).value.length, 2);
    });

    test('a missing document is a named failure', () async {
      final result = await _repository().getDocumentBlocks(
        path: 'support/absent.md',
        profileId: SyntaxProfileId.classicSpanish,
        languageId: UiLanguageId.spanish,
      );

      expect(
        (result as ContentLoadFailed<List<ContentBlock>>).failure,
        ContentLoadFailure.assetMissing,
      );
    });
  });
}
